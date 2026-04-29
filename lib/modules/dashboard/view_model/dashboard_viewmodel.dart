import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';
import '/config/theme/flutter_flow_util.dart';
import '/modules/ride_management/view/ride_party_fetch.dart';
import '/core/services/cache_service.dart';
import '/core/services/cache_policy.dart';
import '/core/utils/view_state.dart';
import 'dashboard_state.dart';

export 'dashboard_state.dart';

/// Riverpod [StateNotifier] that drives the dashboard screen.
/// Replaces the old [DashboardCubit]; all logic is identical —
/// only [emit()] → [state =] and BLoC types removed.
class DashboardViewModel extends StateNotifier<DashboardState> {
  DashboardViewModel() : super(const DashboardState());

  static const String _cacheKey = CachePolicy.dashboardKey;
  static const Duration _cacheTtl = CachePolicy.dashboardTtl;
  static const Duration _pollInterval = Duration(seconds: 45);
  static const List<String> earningsPeriodOptions = [
    'weekly',
    'monthly',
    'yearly'
  ];

  // ── Internal non-observable fields ────────────────────────
  Timer? _pollTimer;
  Future<void>? _inFlightLoad;
  List<dynamic> _allRides = [];
  bool _ridesWeekFromAnalytics = false;
  bool _disposed = false;

  /// Guards every [state] write so that in-flight async calls cannot
  /// update state after the provider has been disposed, which would
  /// cause a Riverpod listener to call [markNeedsBuild] on a defunct
  /// widget element.
  void _safeSet(DashboardState newState) {
    if (!_disposed && mounted) state = newState;
  }

  // ── Lifecycle ─────────────────────────────────────────────

  Future<void> initialize() async {
    await _hydrateFromCache();
    final age = await CacheService.getCacheAge(_cacheKey);
    final shouldRefresh =
        age == null || age > _cacheTtl || !state.hasPreviewData;
    if (shouldRefresh) {
      await loadAll(backgroundRefresh: true);
    }
  }

  void startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      unawaited(refreshHeadlineStats());
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void dispose() {
    _disposed = true;
    stopPolling();
    super.dispose();
  }

  // ── Public commands ───────────────────────────────────────

  Future<void> loadAll({bool backgroundRefresh = false}) async {
    if (_inFlightLoad != null) return _inFlightLoad;
    _inFlightLoad = _loadAllInternal(backgroundRefresh: backgroundRefresh);
    try {
      await _inFlightLoad;
    } finally {
      _inFlightLoad = null;
    }
  }

  Future<void> refreshHeadlineStats() async {
    final token = currentAuthenticationToken;
    if (token == null || token.isEmpty) return;
    try {
      final results = await Future.wait([
        DashBoardCall.call(token: token),
        AllUsersCall.call(token: token),
        GetDriversCall.call(token: token),
      ]);
      final patch = _patchDashboard(results[0], state);
      final userPatch = _patchAllUsersStats(results[1], patch);
      final driverPatch = _patchDrivers(results[2], userPatch);
      _safeSet(driverPatch);
    } catch (_) {
      // Silent: background poll only.
    }
  }

  Future<void> setChartEarningsPeriod(String period) async {
    if (state.chartEarningsPeriod == period) return;
    _safeSet(state.copyWith(chartEarningsPeriod: period));
    await refreshEarningsChart();
  }

  Future<void> setChartVehicleFilter(int? vehicleId) async {
    if (state.chartVehicleId == vehicleId) return;
    if (vehicleId == null) {
      _safeSet(state.copyWith(clearChartVehicleId: true));
    } else {
      _safeSet(state.copyWith(chartVehicleId: vehicleId));
    }
    await refreshEarningsChart();
  }

  Future<void> refreshEarningsChart() async {
    final token = currentAuthenticationToken;
    if (token == null || token.isEmpty) {
      _safeSet(state.copyWith(
        chartRefreshing: false,
        errorMessage: 'Session expired. Please log in again.',
      ));
      return;
    }
    _safeSet(state.copyWith(chartRefreshing: true));
    try {
      final resp = await EarningsAnalyticsCall.call(
        token: token,
        period: state.chartEarningsPeriod,
        vehicleId: state.chartVehicleId,
      );
      final (series, labels, lastWeek) = _extractEarningsSeries(resp.jsonBody);
      var ew = series.isNotEmpty ? series : state.earningsWeekly;
      var ewl = series.isNotEmpty
          ? (labels.isEmpty ? _labelsForLength(series.length) : labels)
          : state.earningsWeeklyLabels;
      if (ew.isEmpty && state.totalEarnings > 0) {
        ew = List<double>.filled(7, state.totalEarnings / 7);
        ewl = const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      }
      await _persistCache(_toCacheMap(state.copyWith(
        earningsWeekly: ew,
        earningsLastWeek:
            lastWeek.isNotEmpty ? lastWeek : state.earningsLastWeek,
        earningsWeeklyLabels: ewl,
      )));
      if (mounted) {
        _safeSet(state.copyWith(
          chartRefreshing: false,
          earningsWeekly: ew,
          earningsLastWeek: lastWeek.isNotEmpty ? lastWeek : null,
          earningsWeeklyLabels: ewl,
          chartRevision: state.chartRevision + 1,
        ));
      }
    } catch (_) {
      _safeSet(state.copyWith(chartRefreshing: false));
    }
  }

  void setChartRideBarDays(int days) {
    final d = days == 30 ? 30 : 7;
    if (state.chartRideBarDays == d) return;
    final rw = d <= 7
        ? _bucketRidesLast7Days(_allRides)
        : _bucketRidesOverDays(_allRides, 30, 10);
    final rwl = d <= 7
        ? _labelsForLast7Days()
        : List<String>.generate(10, (i) => '${i + 1}');
    state = state.copyWith(
      chartRideBarDays: d,
      ridesWeekly: rw,
      ridesWeeklyLabels: rwl,
      chartRevision: state.chartRevision + 1,
    );
  }

  void setChartStatusWindow(int days) {
    if (state.chartStatusDays == days) return;
    final rides =
        days <= 0 ? _allRides : _filterRidesWithinLastDays(_allRides, days);
    final counts = _computeStatusCounts(rides);
    final total = counts.$1 + counts.$2 + counts.$3;
    state = state.copyWith(
      chartStatusDays: days,
      statusCompletedCount: counts.$1,
      statusOngoingCount: counts.$2,
      statusCancelledCount: counts.$3,
      completedPct: total > 0 ? counts.$1 / total : 0,
      ongoingPct: total > 0 ? counts.$2 / total : 0,
      cancelledPct: total > 0 ? counts.$3 / total : 0,
      chartRevision: state.chartRevision + 1,
    );
  }

  // ── Private load orchestration ────────────────────────────

  Future<void> _loadAllInternal({bool backgroundRefresh = false}) async {
    final hasPreview = state.hasPreviewData;
    _safeSet(state.copyWith(
      status: (!hasPreview && !backgroundRefresh)
          ? LoadStatus.loading
          : state.status,
      isBackgroundRefreshing: hasPreview || backgroundRefresh,
      clearError: true,
    ));

    final token = currentAuthenticationToken;
    if (token == null || token.isEmpty) {
      _safeSet(state.copyWith(
        status: LoadStatus.failure,
        isBackgroundRefreshing: false,
        errorMessage: 'Session expired. Please log in again.',
      ));
      return;
    }

    try {
      final results = await Future.wait([
        DashBoardCall.call(token: token),
        CompanyWalletCall.call(token: token),
        EarningsAnalyticsCall.call(
          token: token,
          period: state.chartEarningsPeriod,
          vehicleId: state.chartVehicleId,
        ),
        RidesAnalyticsCall.call(token: token),
        GetRidesCall.call(token: token),
        GetDriversCall.call(token: token),
        GetAdminPendingPayoutsCall.call(
          token: token,
          limit: 25,
          includeStatusParam: false,
        ),
        AllUsersCall.call(token: token),
        GetAllVehiclesCall.call(token: token),
      ]);

      DashboardState s = state;

      s = _patchDashboard(results[0], s);
      s = _patchCompanyWallet(results[1], s);

      final (series, labels, lastWeek) =
          _extractEarningsSeries(results[2].jsonBody);
      if (series.isNotEmpty) {
        s = s.copyWith(
          earningsWeekly: series,
          earningsWeeklyLabels:
              labels.isEmpty ? _labelsForLength(series.length) : labels,
          earningsLastWeek: lastWeek,
        );
      }

      s = _patchRidesAnalytics(results[3], s);

      final ridesList = _parseRidesList(results[4]);
      _allRides = ridesList;
      s = _patchRidesDerived(ridesList, s);

      final (userById, driverById) =
          await _enrichRideParties(s.recentRides, token);
      s = s.copyWith(
        recentRideUserById: userById,
        recentRideDriverById: driverById,
      );

      s = _patchDrivers(results[5], s);

      final payouts =
          GetAdminPendingPayoutsCall.payoutsList(results[6].jsonBody);
      if (results[6].succeeded) s = s.copyWith(pendingPayouts: payouts);

      s = _patchAllUsersStats(results[7], s);

      final (vehicles, vehicleStale) =
          _parseVehicles(results[8], s.chartVehicleId);
      int? clearedVehicleId;
      bool clearVehicle = false;
      if (vehicleStale) {
        clearVehicle = true;
        clearedVehicleId = null;
      }
      s = s.copyWith(
        chartAdminVehicles: vehicles,
        clearChartVehicleId: clearVehicle,
      );

      if (vehicleStale) {
        final redo = await EarningsAnalyticsCall.call(
          token: token,
          period: s.chartEarningsPeriod,
          vehicleId: clearedVehicleId,
        );
        final (rs, rl, rlw) = _extractEarningsSeries(redo.jsonBody);
        if (rs.isNotEmpty) {
          s = s.copyWith(
            earningsWeekly: rs,
            earningsWeeklyLabels: rl.isEmpty ? _labelsForLength(rs.length) : rl,
            earningsLastWeek: rlw,
          );
        }
      }

      if (s.earningsWeekly.isEmpty && s.totalEarnings > 0) {
        s = s.copyWith(
          earningsWeekly: List<double>.filled(7, s.totalEarnings / 7),
          earningsWeeklyLabels: const [
            'Sun',
            'Mon',
            'Tue',
            'Wed',
            'Thu',
            'Fri',
            'Sat'
          ],
        );
      }

      final errorMsg = (!results[0].succeeded)
          ? 'Failed to load dashboard (${results[0].statusCode})'
          : null;

      final now = DateTime.now();
      await _persistCache(_toCacheMap(s));

      _safeSet(s.copyWith(
        status: LoadStatus.success,
        isBackgroundRefreshing: false,
        chartRefreshing: false,
        errorMessage: errorMsg,
        chartRevision: s.chartRevision + 1,
        lastUpdatedAt: now,
      ));
    } catch (e) {
      _safeSet(state.copyWith(
        status: LoadStatus.failure,
        isBackgroundRefreshing: false,
        errorMessage: e.toString(),
      ));
    }
  }

  // ── State patch helpers ───────────────────────────────────

  static DashboardState _patchDashboard(ApiCallResponse r, DashboardState s) {
    if (!r.succeeded || r.jsonBody is! Map) return s;
    final root = Map<String, dynamic>.from(r.jsonBody as Map);
    final data = root['data'];
    final m = data is Map
        ? Map<String, dynamic>.from(data)
        : Map<String, dynamic>.from(root);

    final uStats = m['user_statistics'] is Map
        ? Map<String, dynamic>.from(m['user_statistics'] as Map)
        : const <String, dynamic>{};
    final dStats = m['driver_statistics'] is Map
        ? Map<String, dynamic>.from(m['driver_statistics'] as Map)
        : const <String, dynamic>{};

    return s.copyWith(
      totalRides:
          _firstInt(m, const ['total_rides', 'rides_total', 'totalRides']) ??
              s.totalRides,
      totalUsers:
          _firstInt(m, const ['total_users', 'users_total', 'totalUsers']) ??
          _firstInt(uStats, const ['total']) ??
              s.totalUsers,
      totalDrivers: _firstInt(
              m, const ['total_drivers', 'drivers_total', 'totalDrivers']) ??
          _firstInt(dStats, const ['total']) ??
          s.totalDrivers,
      onlineDrivers: _firstInt(m,
              const ['active_drivers', 'online_drivers', 'drivers_online']) ??
          s.onlineDrivers,
      ridesCompletedToday: _firstInt(
              m, const ['rides_completed_today', 'today_completed_rides']) ??
          s.ridesCompletedToday,
      newUsersToday:
          _firstInt(m, const ['new_users_today', 'today_new_users']) ??
              s.newUsersToday,
      totalEarnings: _firstDouble(
              m, const ['total_earnings', 'earnings_total', 'totalEarnings']) ??
          s.totalEarnings,
      usersActive:
          _firstInt(m, const ['active_users', 'user_active', 'users_active']) ??
          _firstInt(uStats, const ['active']) ??
              s.usersActive,
      usersInactive: _firstInt(
              m, const ['inactive_users', 'user_inactive', 'users_inactive']) ??
          _firstInt(uStats, const ['inactive']) ??
          s.usersInactive,
      usersBlocked: _firstInt(
              m, const ['blocked_users', 'blockedUsers', 'users_blocked']) ??
          _firstInt(uStats, const ['blocked']) ??
          s.usersBlocked,
      driversActiveAccounts: _firstInt(m, const [
            'active_driver_accounts',
            'drivers_active',
            'active_drivers_count'
          ]) ??
          _firstInt(dStats, const ['active']) ??
          s.driversActiveAccounts,
      driversInactiveAccounts: (_firstInt(m, const ['total_drivers', 'drivers_total', 'totalDrivers']) ?? _firstInt(dStats, const ['total']) ?? s.totalDrivers) - 
          (_firstInt(m, const ['active_driver_accounts', 'drivers_active', 'active_drivers_count']) ?? _firstInt(dStats, const ['active']) ?? s.driversActiveAccounts),
      driversPendingKyc:
          _firstInt(m, const ['pending_drivers', 'drivers_pending']) ??
          _firstInt(dStats, const ['pending']) ??
              s.driversPendingKyc,
      driversBlockedAccounts:
          _firstInt(m, const ['blocked_drivers', 'drivers_blocked']) ??
          _firstInt(dStats, const ['blocked']) ??
              s.driversBlockedAccounts,
      adminWallet: _firstDouble(m, const [
            'admin_wallet',
            'admin_wallet_balance',
            'company_wallet',
            'platform_balance',
            'wallet_balance'
          ]) ??
          s.adminWallet,
    );
  }

  static DashboardState _patchCompanyWallet(
      ApiCallResponse r, DashboardState s) {
    if (!r.succeeded) return s;
    final w = _adminWalletFromCompanyBody(r.jsonBody);
    if (w != null && w > 0) return s.copyWith(adminWallet: w);
    return s;
  }

  static DashboardState _patchRidesAnalytics(
      ApiCallResponse r, DashboardState s) {
    if (!r.succeeded || r.jsonBody is! Map) return s;
    final root = Map<String, dynamic>.from(r.jsonBody as Map);
    final data = root['data'];
    if (data is! Map) return s;
    final week = data['week'];
    if (week is! List || week.isEmpty) return s;

    final values = <double>[];
    final labels = <String>[];
    for (final item in week.whereType<Map>()) {
      final row = Map<String, dynamic>.from(item);
      final completed = _parseDouble(row['completed']) ?? 0;
      final cancelled = _parseDouble(row['cancelled']) ?? 0;
      values.add(completed + cancelled);
      labels.add(
        row['day']?.toString() ??
            _dayLabelFromDate(row['date']) ??
            '${labels.length + 1}',
      );
    }
    if (values.isNotEmpty) {
      return s.copyWith(ridesWeekly: values, ridesWeeklyLabels: labels);
    }
    return s;
  }

  DashboardState _patchRidesDerived(List<dynamic> allRides, DashboardState s) {
    final sorted = List<dynamic>.from(allRides)
      ..sort((a, b) {
        final da = _parseRideDate(a);
        final db = _parseRideDate(b);
        if (da != null && db != null) return db.compareTo(da);
        final ia = _parseInt(a is Map ? a['id'] : null);
        final ib = _parseInt(b is Map ? b['id'] : null);
        if (ia != null && ib != null) return ib.compareTo(ia);
        return 0;
      });
    final recentRides = sorted.take(10).toList();

    final statusDays = s.chartStatusDays;
    final ridesForStatus = statusDays <= 0
        ? allRides
        : _filterRidesWithinLastDays(allRides, statusDays);
    final counts = _computeStatusCounts(ridesForStatus);
    final total = counts.$1 + counts.$2 + counts.$3;

    final rw = s.chartRideBarDays <= 7
        ? _bucketRidesLast7Days(allRides)
        : _bucketRidesOverDays(allRides, 30, 10);
    final rwl = s.chartRideBarDays <= 7
        ? _labelsForLast7Days()
        : List<String>.generate(10, (i) => '${i + 1}');
    _ridesWeekFromAnalytics = false;

    return s.copyWith(
      recentRides: recentRides,
      statusCompletedCount: counts.$1,
      statusOngoingCount: counts.$2,
      statusCancelledCount: counts.$3,
      completedPct: total > 0 ? counts.$1 / total : 0,
      ongoingPct: total > 0 ? counts.$2 / total : 0,
      cancelledPct: total > 0 ? counts.$3 / total : 0,
      ridesWeekly: rw,
      ridesWeeklyLabels: rwl,
    );
  }

  static DashboardState _patchDrivers(ApiCallResponse r, DashboardState s) {
    if (!r.succeeded) return s;
    var list = GetDriversCall.data(r.jsonBody);
    list ??= getJsonField(r.jsonBody, r'''$.data.drivers''') as List?;
    list ??= getJsonField(r.jsonBody, r'''$.drivers''') as List?;
    if (list == null || list.isEmpty) return s;

    final scored = List<Map<String, dynamic>>.from(
      list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
    );

    var active = 0, pending = 0, blocked = 0;
    for (final d in scored) {
      final kyc = (d['kyc_status']?.toString() ?? '').toLowerCase().trim();
      final isActive =
          _parseBool(d['is_active']) || _parseBool(d['active_driver']);
      final isBlocked = _parseBool(d['is_blocked']) ||
          (d['account_status']?.toString().toLowerCase() == 'blocked') ||
          (d['status']?.toString().toLowerCase() == 'blocked');
      if (kyc == 'pending') {
        pending++;
      } else if (isBlocked ||
          !isActive ||
          kyc == 'rejected' ||
          kyc == 'declined') {
        blocked++;
      } else {
        active++;
      }
    }

    double driverScore(Map<String, dynamic> d) {
      for (final k in [
        'total_earnings',
        'lifetime_earnings',
        'wallet_balance',
        'balance',
        'total_trips',
        'completed_rides',
        'ride_count',
      ]) {
        final v = _parseDouble(d[k]);
        if (v != null && v > 0) return v;
      }
      return 0;
    }

    scored.sort((a, b) => driverScore(b).compareTo(driverScore(a)));
    final topDrivers = scored.take(8).toList();

    int dActive = s.driversActiveAccounts;
    int dPending = s.driversPendingKyc;
    int dBlocked = s.driversBlockedAccounts;

    if (dActive == 0 && dPending == 0 && dBlocked == 0) {
      dActive = active;
      dPending = pending;
      dBlocked = blocked;
    }

    return s.copyWith(
      driversActiveAccounts: dActive,
      driversPendingKyc: dPending,
      driversBlockedAccounts: dBlocked,
      topDrivers: topDrivers,
    );
  }

  static DashboardState _patchAllUsersStats(
      ApiCallResponse r, DashboardState s) {
    if (!r.succeeded) return s;
    var list = AllUsersCall.usersdata(r.jsonBody);
    list ??= getJsonField(r.jsonBody, r'''$.data.users''') as List?;
    list ??= getJsonField(r.jsonBody, r'''$.users''') as List?;
    if (list == null || list.isEmpty) return s;

    var a = 0, i = 0, b = 0;
    for (final u in list.whereType<Map>()) {
      final m = Map<String, dynamic>.from(u);
      final blocked = _parseBool(m['is_blocked']) ||
          (m['status']?.toString().toLowerCase() == 'blocked') ||
          (m['account_status']?.toString().toLowerCase() == 'blocked');
      final active = _parseBool(m['is_active']) || _parseBool(m['active']);
      if (blocked) {
        b++;
      } else if (active) {
        a++;
      } else {
        i++;
      }
    }

    int uActive = s.usersActive;
    int uInactive = s.usersInactive;
    int uBlocked = s.usersBlocked;

    if (uActive == 0 && uInactive == 0 && uBlocked == 0) {
      uActive = a;
      uInactive = i;
      uBlocked = b;
    }

    return s.copyWith(usersActive: uActive, usersInactive: uInactive, usersBlocked: uBlocked);
  }

  // ── Parsing helpers ───────────────────────────────────────

  static (List<Map<String, dynamic>>, bool) _parseVehicles(
      ApiCallResponse r, int? currentVehicleId) {
    final vehicles = <Map<String, dynamic>>[];
    if (!r.succeeded || r.jsonBody is! Map) return (vehicles, false);
    final data = (r.jsonBody as Map)['data'];
    if (data is! List) return (vehicles, false);
    for (final item in data) {
      if (item is Map) vehicles.add(Map<String, dynamic>.from(item));
    }
    vehicles.sort((a, b) {
      final na = a['vehicle_name']?.toString() ?? '';
      final nb = b['vehicle_name']?.toString() ?? '';
      return na.compareTo(nb);
    });
    if (currentVehicleId != null) {
      final exists =
          vehicles.any((v) => _parseInt(v['id']) == currentVehicleId);
      return (vehicles, !exists);
    }
    return (vehicles, false);
  }

  static List<dynamic> _parseRidesList(ApiCallResponse r) {
    if (!r.succeeded) return [];
    final raw = GetRidesCall.data(r.jsonBody);
    if (raw is List) return List<dynamic>.from(raw);
    if (r.jsonBody is Map) {
      final root = r.jsonBody as Map;
      final d = root['data'];
      if (d is List) return List<dynamic>.from(d);
      if (d is Map) {
        final rides = d['rides'];
        if (rides is List) return List<dynamic>.from(rides);
      }
      final top = root['rides'];
      if (top is List) return List<dynamic>.from(top);
    }
    return [];
  }

  static (List<double>, List<String>, List<double>) _extractEarningsSeries(
      dynamic body) {
    final out = <double>[];
    final labels = <String>[];
    final lastWeek = <double>[];
    if (body is! Map) return (out, labels, lastWeek);
    dynamic data = body['data'] ?? body;

    void addFromList(List list, {bool collectDateLabels = false}) {
      for (final item in list) {
        if (item is num) {
          out.add(item.toDouble());
        } else if (item is Map) {
          final v = _parseDouble(item['amount']) ??
              _parseDouble(item['value']) ??
              _parseDouble(item['earnings']) ??
              _parseDouble(item['total']) ??
              _parseDouble(item['count']) ??
              _parseDouble(item['rides']);
          if (v != null) {
            out.add(v);
            if (collectDateLabels) {
              labels.add(
                _dayLabelFromDate(item['date']) ??
                    item['day']?.toString() ??
                    '${labels.length + 1}',
              );
            }
          }
        }
      }
    }

    if (data is List) {
      addFromList(data, collectDateLabels: true);
      return (out, labels, lastWeek);
    }
    if (data is Map) {
      final thisWeek = data['this_week'];
      if (thisWeek is Map) {
        final daily = thisWeek['daily_earnings'];
        if (daily is List && daily.isNotEmpty) {
          addFromList(daily, collectDateLabels: true);
          if (out.isNotEmpty) {
            final lw = data['last_week'];
            if (lw is Map) {
              final lwDaily = lw['daily_earnings'];
              if (lwDaily is List && lwDaily.isNotEmpty) {
                for (final item in lwDaily.whereType<Map>()) {
                  final val = _parseDouble(
                          Map<String, dynamic>.from(item)['earnings']) ??
                      0;
                  lastWeek.add(val);
                }
              }
            }
            return (out, labels, lastWeek);
          }
        }
      }
      for (final key in [
        'weekly_earnings',
        'monthly_earnings',
        'yearly_earnings',
        'series',
        'breakdown',
        'chart_data',
        'data_points',
        'values',
        'daily_rides',
        'rides_per_day',
        'labels_data',
      ]) {
        final v = data[key];
        if (v is List && v.isNotEmpty) {
          addFromList(v, collectDateLabels: true);
          if (out.isNotEmpty) return (out, labels, lastWeek);
        }
      }
    }
    if (labels.isEmpty && out.isNotEmpty) {
      labels.addAll(_labelsForLength(out.length));
    }
    return (out, labels, lastWeek);
  }

  static (int, int, int) _computeStatusCounts(List<dynamic> rides) {
    int completed = 0, ongoing = 0, cancelled = 0;
    for (final r in rides) {
      final s =
          r is Map ? (r['ride_status']?.toString().toLowerCase() ?? '') : '';
      if (s.contains('cancel')) {
        cancelled++;
      } else if (s == 'completed') {
        completed++;
      } else {
        ongoing++;
      }
    }
    return (completed, ongoing, cancelled);
  }

  static List<dynamic> _filterRidesWithinLastDays(
      List<dynamic> rides, int days) {
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));
    return rides.where((r) {
      final dt = _parseRideDate(r);
      if (dt == null) return false;
      final day = DateTime(dt.year, dt.month, dt.day);
      return !day.isBefore(cutoff);
    }).toList();
  }

  static List<double> _bucketRidesLast7Days(List<dynamic> rides) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: 6));
    final counts = List<double>.filled(7, 0);
    for (final r in rides) {
      final dt = _parseRideDate(r);
      if (dt == null) continue;
      final day = DateTime(dt.year, dt.month, dt.day);
      final idx = day.difference(start).inDays;
      if (idx >= 0 && idx < 7) counts[idx] += 1;
    }
    return counts;
  }

  static List<String> _labelsForLast7Days() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: 6));
    return List<String>.generate(
        7, (i) => _weekdayAbbr(start.add(Duration(days: i)).weekday));
  }

  static List<double> _bucketRidesOverDays(
      List<dynamic> rides, int totalDays, int numBuckets) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(Duration(days: totalDays - 1));
    final counts = List<double>.filled(numBuckets, 0);
    final span = totalDays / numBuckets;
    for (final r in rides) {
      final dt = _parseRideDate(r);
      if (dt == null) continue;
      final day = DateTime(dt.year, dt.month, dt.day);
      if (day.isBefore(start) || day.isAfter(today)) continue;
      final idx = (day.difference(start).inDays / span)
          .floor()
          .clamp(0, numBuckets - 1);
      counts[idx] += 1;
    }
    return counts;
  }

  static Future<
          (Map<int, Map<String, dynamic>>, Map<int, Map<String, dynamic>>)>
      _enrichRideParties(List<dynamic> recentRides, String token) async {
    if (recentRides.isEmpty || token.isEmpty) {
      return (<int, Map<String, dynamic>>{}, <int, Map<String, dynamic>>{});
    }
    final uIds = <int>{};
    final dIds = <int>{};
    RidePartyFetch.collectIdsFromRides(recentRides, uIds, dIds);
    final userById = await RidePartyFetch.fetchUsersByIds(uIds, token);
    final driverById = await RidePartyFetch.fetchDriversByIds(dIds, token);
    return (userById, driverById);
  }

  // ── Cache helpers ─────────────────────────────────────────

  Future<void> _hydrateFromCache() async {
    final cached = await CacheService.getData(_cacheKey);
    final lastUpdatedAt = await CacheService.getLastUpdated(_cacheKey);
    if (cached == null) return;

    if (_disposed) return;

    _safeSet(state.copyWith(
      lastUpdatedAt: lastUpdatedAt,
      totalRides: _parseInt(cached['totalRides']) ?? state.totalRides,
      totalUsers: _parseInt(cached['totalUsers']) ?? state.totalUsers,
      totalDrivers: _parseInt(cached['totalDrivers']) ?? state.totalDrivers,
      onlineDrivers: _parseInt(cached['onlineDrivers']) ?? state.onlineDrivers,
      usersActive: _parseInt(cached['usersActive']) ?? state.usersActive,
      usersInactive: _parseInt(cached['usersInactive']) ?? state.usersInactive,
      usersBlocked: _parseInt(cached['usersBlocked']) ?? state.usersBlocked,
      driversActiveAccounts: _parseInt(cached['driversActiveAccounts']) ??
          state.driversActiveAccounts,
      driversPendingKyc:
          _parseInt(cached['driversPendingKyc']) ?? state.driversPendingKyc,
      driversBlockedAccounts: _parseInt(cached['driversBlockedAccounts']) ??
          state.driversBlockedAccounts,
      ridesCompletedToday:
          _parseInt(cached['ridesCompletedToday']) ?? state.ridesCompletedToday,
      newUsersToday: _parseInt(cached['newUsersToday']) ?? state.newUsersToday,
      totalEarnings:
          _parseDouble(cached['totalEarnings']) ?? state.totalEarnings,
      adminWallet: _parseDouble(cached['adminWallet']) ?? state.adminWallet,
      earningsWeekly: _toDoubleList(cached['earningsWeekly']).isNotEmpty
          ? _toDoubleList(cached['earningsWeekly'])
          : null,
      earningsLastWeek: _toDoubleList(cached['earningsLastWeek']).isNotEmpty
          ? _toDoubleList(cached['earningsLastWeek'])
          : null,
      ridesWeekly: _toDoubleList(cached['ridesWeekly']).isNotEmpty
          ? _toDoubleList(cached['ridesWeekly'])
          : null,
      earningsWeeklyLabels:
          _toStringList(cached['earningsWeeklyLabels']).isNotEmpty
              ? _toStringList(cached['earningsWeeklyLabels'])
              : null,
      ridesWeeklyLabels: _toStringList(cached['ridesWeeklyLabels']).isNotEmpty
          ? _toStringList(cached['ridesWeeklyLabels'])
          : null,
      completedPct: _parseDouble(cached['completedPct']) ?? state.completedPct,
      ongoingPct: _parseDouble(cached['ongoingPct']) ?? state.ongoingPct,
      cancelledPct: _parseDouble(cached['cancelledPct']) ?? state.cancelledPct,
      statusCompletedCount: _parseInt(cached['statusCompletedCount']) ??
          state.statusCompletedCount,
      statusOngoingCount:
          _parseInt(cached['statusOngoingCount']) ?? state.statusOngoingCount,
      statusCancelledCount: _parseInt(cached['statusCancelledCount']) ??
          state.statusCancelledCount,
      recentRides: _toMapList(cached['recentRides']).isNotEmpty
          ? _toMapList(cached['recentRides'])
          : null,
      topDrivers: _toMapList(cached['topDrivers']).isNotEmpty
          ? _toMapList(cached['topDrivers'])
          : null,
      pendingPayouts: _toMapList(cached['pendingPayouts']).isNotEmpty
          ? _toMapList(cached['pendingPayouts'])
          : null,
    ));
  }

  static Future<void> _persistCache(Map<String, dynamic> data) async {
    await CacheService.saveData(_cacheKey, data);
  }

  static Map<String, dynamic> _toCacheMap(DashboardState s) => {
        'totalRides': s.totalRides,
        'totalUsers': s.totalUsers,
        'totalDrivers': s.totalDrivers,
        'onlineDrivers': s.onlineDrivers,
        'usersActive': s.usersActive,
        'usersInactive': s.usersInactive,
        'usersBlocked': s.usersBlocked,
        'driversActiveAccounts': s.driversActiveAccounts,
        'driversPendingKyc': s.driversPendingKyc,
        'driversBlockedAccounts': s.driversBlockedAccounts,
        'ridesCompletedToday': s.ridesCompletedToday,
        'newUsersToday': s.newUsersToday,
        'totalEarnings': s.totalEarnings,
        'adminWallet': s.adminWallet,
        'earningsWeekly': s.earningsWeekly,
        'earningsLastWeek': s.earningsLastWeek,
        'ridesWeekly': s.ridesWeekly,
        'earningsWeeklyLabels': s.earningsWeeklyLabels,
        'ridesWeeklyLabels': s.ridesWeeklyLabels,
        'completedPct': s.completedPct,
        'ongoingPct': s.ongoingPct,
        'cancelledPct': s.cancelledPct,
        'statusCompletedCount': s.statusCompletedCount,
        'statusOngoingCount': s.statusOngoingCount,
        'statusCancelledCount': s.statusCancelledCount,
        'recentRides': s.recentRides,
        'topDrivers': s.topDrivers,
        'pendingPayouts': s.pendingPayouts,
      };

  // ── Utility statics ───────────────────────────────────────

  static double? _adminWalletFromCompanyBody(dynamic body) {
    final data = body is Map ? getJsonField(body, r'''$.data''') : null;
    final rider =
        _parseDouble(getJsonField(data ?? body, r'''$.rider_total'''));
    final driver =
        _parseDouble(getJsonField(data ?? body, r'''$.driver_total'''));
    final total = _parseDouble(getJsonField(data ?? body, r'''$.total''')) ??
        _parseDouble(getJsonField(data ?? body, r'''$.balance''')) ??
        _parseDouble(getJsonField(data ?? body, r'''$.company_balance'''));
    if (total != null) return total;
    if (rider != null || driver != null) return (rider ?? 0) + (driver ?? 0);
    return null;
  }

  static bool _parseBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.toLowerCase();
      return s == 'true' || s == '1' || s == 'yes';
    }
    return false;
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse(v.toString());
  }

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static int? _firstInt(Map<String, dynamic> m, List<String> keys) {
    for (final key in keys) {
      final val = _parseInt(m[key]);
      if (val != null) return val;
    }
    return null;
  }

  static double? _firstDouble(Map<String, dynamic> m, List<String> keys) {
    for (final key in keys) {
      final val = _parseDouble(m[key]);
      if (val != null) return val;
    }
    return null;
  }

  static DateTime? _parseRideDate(dynamic r) {
    if (r is! Map) return null;
    for (final key in [
      'created_at',
      'ride_date',
      'updated_at',
      'scheduled_at'
    ]) {
      final raw = r[key];
      if (raw == null) continue;
      try {
        return DateTime.parse(raw.toString());
      } catch (_) {}
    }
    return null;
  }

  static String? _dayLabelFromDate(dynamic raw) {
    if (raw == null) return null;
    try {
      final dt = DateTime.parse(raw.toString());
      return _weekdayAbbr(dt.weekday);
    } catch (_) {
      return null;
    }
  }

  static String _weekdayAbbr(int weekday) {
    const abbrs = {
      DateTime.monday: 'Mon',
      DateTime.tuesday: 'Tue',
      DateTime.wednesday: 'Wed',
      DateTime.thursday: 'Thu',
      DateTime.friday: 'Fri',
      DateTime.saturday: 'Sat',
      DateTime.sunday: 'Sun',
    };
    return abbrs[weekday] ?? 'Sun';
  }

  static List<String> _labelsForLength(int n) {
    if (n == 7) return const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return List<String>.generate(n, (i) => '${i + 1}');
  }

  static List<double> _toDoubleList(dynamic value) {
    if (value is! List) return [];
    return value.map((e) => _parseDouble(e) ?? 0).toList();
  }

  static List<String> _toStringList(dynamic value) {
    if (value is! List) return [];
    return value.map((e) => e.toString()).toList();
  }

  static List<Map<String, dynamic>> _toMapList(dynamic value) {
    if (value is! List) return [];
    return value
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}

/// The single global [DashboardViewModel] provider.
/// Auto-disposed when the dashboard subtree leaves the widget tree.
final dashboardViewModelProvider =
    StateNotifierProvider.autoDispose<DashboardViewModel, DashboardState>(
  (ref) => DashboardViewModel(),
);
