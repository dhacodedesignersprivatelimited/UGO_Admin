import 'dart:async';

import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';
import '/config/theme/flutter_flow_util.dart';
import '/modules/ride_management/view/ride_party_fetch.dart';
import 'package:flutter/foundation.dart';
import '/core/services/cache_service.dart';
import '/core/services/cache_policy.dart';

/// Dashboard ViewModel (MVVM): manages dashboard UI state and data orchestration.
class DashboardPageModel extends ChangeNotifier {
  static const String _cacheKey = CachePolicy.dashboardKey;
  static const Duration _cacheTtl = CachePolicy.dashboardTtl;

  bool isLoading = false;
  bool isBackgroundRefreshing = false;
  bool chartRefreshing = false;
  String? errorMessage;
  DateTime? lastUpdatedAt;

  int totalRides = 0;
  int totalUsers = 0;
  int totalDrivers = 0;
  int onlineDrivers = 0;

  /// From all-users list (or dashboard keys when list missing).
  int usersActive = 0;
  int usersInactive = 0;
  int usersBlocked = 0;

  /// From full drivers list (KYC + active flags).
  int driversActiveAccounts = 0;
  int driversPendingKyc = 0;
  int driversBlockedAccounts = 0;
  int ridesCompletedToday = 0;
  int newUsersToday = 0;

  double totalEarnings = 0;
  double adminWallet = 0;

  List<double> earningsWeekly = [];
  List<double> earningsLastWeek = [];
  List<double> ridesWeekly = [];
  List<String> earningsWeeklyLabels = [];
  List<String> ridesWeeklyLabels = [];

  double completedPct = 0;
  double ongoingPct = 0;
  double cancelledPct = 0;

  /// Raw counts for the current status filter (pie tooltips).
  int statusCompletedCount = 0;
  int statusOngoingCount = 0;
  int statusCancelledCount = 0;

  List<dynamic> recentRides = [];
  List<dynamic> topDrivers = [];
  List<dynamic> pendingPayouts = [];

  List<dynamic> _allRides = [];
  bool _ridesWeekFromAnalytics = false;

  /// From [GetUserByIdCall] / [GetDriverByIdCall] for [recentRides] rows.
  Map<int, Map<String, dynamic>> recentRideUserById = {};
  Map<int, Map<String, dynamic>> recentRideDriverById = {};

  /// Bumps when chart series change so the UI can replay enter animations.
  int chartRevision = 0;
  String _lastUiFingerprint = '';
  Future<void>? _inFlightLoad;

  String chartEarningsPeriod = 'weekly';

  /// `null` = all admin vehicles; otherwise `data[].id` from [GetAllVehiclesCall].
  int? chartVehicleId;
  List<Map<String, dynamic>> chartAdminVehicles = [];

  /// 7 = one bar per day for last 7 days; 30 = 10 bars over 30 days.
  int chartRideBarDays = 7;

  /// 0 = all time; else last N days for status pie.
  int chartStatusDays = 0;

  /// Rows that still need admin action (excludes completed / paid / failed).
  int get pendingPayoutCount {
    var n = 0;
    for (final raw in pendingPayouts) {
      if (raw is! Map) continue;
      final s = (raw['status']?.toString() ?? '').toLowerCase();
      if (s.contains('completed') ||
          s.contains('paid') ||
          s.contains('success')) {
        continue;
      }
      if (s.contains('fail') || s.contains('reject') || s.contains('error')) {
        continue;
      }
      n++;
    }
    return n;
  }

  /// Background refresh for user/driver stats cards (lightweight vs [loadAll]).
  Timer? _userDriverStatsTimer;
  static const Duration userDriverStatsPollInterval = Duration(seconds: 45);

  static const List<String> earningsPeriodOptions = [
    'weekly',
    'monthly',
    'yearly',
  ];

  /// Label for earnings chart tooltips / filters.
  String get chartSelectedVehicleLabel {
    if (chartVehicleId == null) return 'All vehicles';
    for (final v in chartAdminVehicles) {
      if (_parseInt(v['id']) == chartVehicleId) {
        return v['vehicle_name']?.toString() ?? 'Vehicle #$chartVehicleId';
      }
    }
    return 'All vehicles';
  }

  void _bumpChartRevision() {
    chartRevision++;
    notifyListeners();
  }

  /// Polls dashboard + users + drivers to keep stat gauges fresh without a full reload.
  void startUserDriverStatsPolling() {
    _userDriverStatsTimer?.cancel();
    _userDriverStatsTimer = Timer.periodic(userDriverStatsPollInterval, (_) {
      unawaited(refreshUserDriverStats());
    });
  }

  void stopUserDriverStatsPolling() {
    _userDriverStatsTimer?.cancel();
    _userDriverStatsTimer = null;
  }

  /// Updates headline totals, user buckets, driver buckets, and top-drivers list.
  Future<void> refreshUserDriverStats() async {
    final token = currentAuthenticationToken;
    if (token == null || token.isEmpty) return;
    try {
      final r = await Future.wait([
        DashBoardCall.call(token: token),
        AllUsersCall.call(token: token),
        GetDriversCall.call(token: token),
      ]);
      _applyDashboardResponse(r[0]);
      _applyAllUsersStatsResponse(r[1]);
      _applyDriversResponse(r[2]);
      notifyListeners();
    } catch (_) {
      // Silent: avoid spamming errors for background poll.
    }
  }

  @override
  @mustCallSuper
  void dispose() {
    stopUserDriverStatsPolling();
    super.dispose();
  }

  Future<void> initialize() async {
    await _hydrateFromCache();
    final age = await CacheService.getCacheAge(_cacheKey);
    final shouldRefresh =
        age == null || age > _cacheTtl || !_hasPreviewData();
    if (shouldRefresh) {
      await loadAll(backgroundRefresh: true);
    }
  }

  Future<void> loadAll({bool backgroundRefresh = false}) async {
    if (_inFlightLoad != null) {
      return _inFlightLoad;
    }
    _inFlightLoad = _loadAllInternal(backgroundRefresh: backgroundRefresh);
    try {
      await _inFlightLoad;
    } finally {
      _inFlightLoad = null;
    }
  }

  Future<void> _loadAllInternal({bool backgroundRefresh = false}) async {
    final hasPreview = _hasPreviewData();
    isLoading = !hasPreview && !backgroundRefresh;
    isBackgroundRefreshing = hasPreview || backgroundRefresh;
    errorMessage = null;
    if (!hasPreview) {
      earningsWeekly = [];
      earningsLastWeek = [];
      ridesWeekly = [];
      earningsWeeklyLabels = [];
      ridesWeeklyLabels = [];
      recentRides = [];
      topDrivers = [];
      pendingPayouts = [];
      _allRides = [];
      _ridesWeekFromAnalytics = false;
      recentRideUserById = {};
      recentRideDriverById = {};
      usersActive = 0;
      usersInactive = 0;
      usersBlocked = 0;
      driversActiveAccounts = 0;
      driversPendingKyc = 0;
      driversBlockedAccounts = 0;
    }
    notifyListeners();

    final token = currentAuthenticationToken;
    if (token == null || token.isEmpty) {
      isLoading = false;
      isBackgroundRefreshing = false;
      errorMessage = 'Session expired. Please log in again.';
      notifyListeners();
      return;
    }

    try {
      final results = await Future.wait([
        DashBoardCall.call(token: token),
        CompanyWalletCall.call(token: token),
        EarningsAnalyticsCall.call(
          token: token,
          period: chartEarningsPeriod,
          vehicleId: chartVehicleId,
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

      _applyDashboardResponse(results[0]);
      _applyCompanyWalletResponse(results[1]);
      _applyEarningsAnalyticsResponse(results[2]);
      _applyRidesAnalyticsResponse(results[3]);

      final ridesList = _parseRidesList(results[4]);
      _applyRidesDerivedData(ridesList);

      await _enrichRecentRideParties(token);

      _applyDriversResponse(results[5]);
      _applyPayoutsResponse(results[6]);
      _applyAllUsersStatsResponse(results[7]);

      final earningsStale = _applyChartVehiclesResponse(results[8]);
      if (earningsStale) {
        final redo = await EarningsAnalyticsCall.call(
          token: token,
          period: chartEarningsPeriod,
          vehicleId: chartVehicleId,
        );
        earningsWeekly = [];
        earningsLastWeek = [];
        _applyEarningsAnalyticsResponse(redo);
      }

      if (earningsWeekly.isEmpty && totalEarnings > 0) {
        earningsWeekly = List<double>.filled(7, totalEarnings / 7);
        earningsWeeklyLabels =
            const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      }

      if (errorMessage == null && !results[0].succeeded) {
        errorMessage = 'Failed to load dashboard (${results[0].statusCode})';
      }
      await _persistCache();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      isBackgroundRefreshing = false;
      chartRevision++;
      _notifyIfChanged(force: true);
    }
  }

  Future<void> setChartEarningsPeriod(String period) async {
    if (chartEarningsPeriod == period) return;
    chartEarningsPeriod = period;
    notifyListeners();
    await refreshEarningsChartFromApi();
  }

  Future<void> setChartVehicleFilter(int? vehicleId) async {
    if (chartVehicleId == vehicleId) return;
    chartVehicleId = vehicleId;
    notifyListeners();
    await refreshEarningsChartFromApi();
  }

  Future<void> refreshEarningsChartFromApi() async {
    final token = currentAuthenticationToken;
    if (token == null || token.isEmpty) {
      chartRefreshing = false;
      errorMessage = 'Session expired. Please log in again.';
      notifyListeners();
      return;
    }
    chartRefreshing = true;
    notifyListeners();
    try {
      final resp = await EarningsAnalyticsCall.call(
        token: token,
        period: chartEarningsPeriod,
        vehicleId: chartVehicleId,
      );
      earningsWeekly = [];
      earningsLastWeek = [];
      earningsWeeklyLabels = [];
      _applyEarningsAnalyticsResponse(resp);
      if (earningsWeekly.isEmpty && totalEarnings > 0) {
        earningsWeekly = List<double>.filled(7, totalEarnings / 7);
        earningsWeeklyLabels =
            const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      }
      await _persistCache();
    } finally {
      chartRefreshing = false;
      _bumpChartRevision();
    }
  }

  void setChartRideBarDays(int days) {
    final d = days == 30 ? 30 : 7;
    if (chartRideBarDays == d) return;
    chartRideBarDays = d;
    _recomputeRidesBarFromCache();
    _bumpChartRevision();
  }

  void setChartStatusWindow(int days) {
    if (chartStatusDays == days) return;
    chartStatusDays = days;
    _recomputeStatusFromCache();
    _bumpChartRevision();
  }

  Future<void> _enrichRecentRideParties(String token) async {
    if (token.isEmpty) return;
    recentRideUserById = {};
    recentRideDriverById = {};
    if (recentRides.isEmpty) return;
    final uIds = <int>{};
    final dIds = <int>{};
    RidePartyFetch.collectIdsFromRides(recentRides, uIds, dIds);
    recentRideUserById = await RidePartyFetch.fetchUsersByIds(uIds, token);
    recentRideDriverById = await RidePartyFetch.fetchDriversByIds(dIds, token);
    notifyListeners();
  }

  void _recomputeRidesBarFromCache() {
    if (chartRideBarDays <= 7 &&
        _ridesWeekFromAnalytics &&
        ridesWeekly.isNotEmpty) {
      return;
    }
    if (chartRideBarDays <= 7) {
      ridesWeekly = _bucketRidesLast7Days(_allRides);
      ridesWeeklyLabels = _labelsForLast7Days();
      _ridesWeekFromAnalytics = false;
    } else {
      ridesWeekly = _bucketRidesOverDays(_allRides, 30, 10);
      ridesWeeklyLabels = List<String>.generate(10, (i) => '${i + 1}');
      _ridesWeekFromAnalytics = false;
    }
  }

  void _recomputeStatusFromCache() {
    final rides = chartStatusDays <= 0
        ? _allRides
        : _filterRidesWithinLastDays(_allRides, chartStatusDays);
    _applyStatusCounts(rides);
  }

  List<dynamic> _filterRidesWithinLastDays(List<dynamic> rides, int days) {
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

  void _applyDashboardResponse(ApiCallResponse response) {
    if (!response.succeeded || response.jsonBody is! Map) return;
    final root = Map<String, dynamic>.from(response.jsonBody as Map);
    final data = root['data'];
    final m = data is Map
        ? Map<String, dynamic>.from(data)
        : Map<String, dynamic>.from(root);

    totalRides = _firstInt(
          m,
          const ['total_rides', 'rides_total', 'totalRides'],
        ) ??
        0;
    totalUsers = _firstInt(
          m,
          const ['total_users', 'users_total', 'totalUsers'],
        ) ??
        0;
    totalDrivers = _firstInt(
          m,
          const ['total_drivers', 'drivers_total', 'totalDrivers'],
        ) ??
        0;
    onlineDrivers = _firstInt(
          m,
          const ['active_drivers', 'online_drivers', 'drivers_online'],
        ) ??
        0;
    ridesCompletedToday = _firstInt(
          m,
          const ['rides_completed_today', 'today_completed_rides'],
        ) ??
        0;
    newUsersToday = _firstInt(
          m,
          const ['new_users_today', 'today_new_users'],
        ) ??
        0;
    totalEarnings = _firstDouble(
          m,
          const ['total_earnings', 'earnings_total', 'totalEarnings'],
        ) ??
        0;

    final ua =
        _firstInt(m, const ['active_users', 'user_active', 'users_active']);
    final ui = _firstInt(
        m, const ['inactive_users', 'user_inactive', 'users_inactive']);
    final ub =
        _firstInt(m, const ['blocked_users', 'blockedUsers', 'users_blocked']);
    if (ua != null) usersActive = ua;
    if (ui != null) usersInactive = ui;
    if (ub != null) usersBlocked = ub;

    final da = _firstInt(
      m,
      const ['active_driver_accounts', 'drivers_active', 'active_drivers_count'],
    );
    final dp = _firstInt(
      m,
      const ['pending_drivers', 'drivers_pending'],
    );
    final db = _firstInt(
      m,
      const ['blocked_drivers', 'drivers_blocked'],
    );
    if (da != null) driversActiveAccounts = da;
    if (dp != null) driversPendingKyc = dp;
    if (db != null) driversBlockedAccounts = db;

    final w = _firstDouble(
      m,
      const [
        'admin_wallet',
        'admin_wallet_balance',
        'company_wallet',
        'platform_balance',
        'wallet_balance',
      ],
    );
    if (w != null) adminWallet = w;
  }

  void _applyCompanyWalletResponse(ApiCallResponse response) {
    if (!response.succeeded) return;
    final w = _adminWalletFromCompanyBody(response.jsonBody);
    if (w != null && w > 0) adminWallet = w;
  }

  /// Parses admin vehicles list. Returns true if [chartVehicleId] was cleared
  /// (stale selection) so earnings analytics should be requested again.
  bool _applyChartVehiclesResponse(ApiCallResponse response) {
    chartAdminVehicles = [];
    if (!response.succeeded) return false;
    final body = response.jsonBody;
    if (body is! Map) return false;
    final data = body['data'];
    if (data is! List) return false;

    final beforeId = chartVehicleId;
    for (final item in data) {
      if (item is Map) {
        chartAdminVehicles.add(Map<String, dynamic>.from(item));
      }
    }
    chartAdminVehicles.sort((a, b) {
      final na = a['vehicle_name']?.toString() ?? '';
      final nb = b['vehicle_name']?.toString() ?? '';
      return na.compareTo(nb);
    });

    _validateChartVehicleSelection();
    return beforeId != chartVehicleId;
  }

  void _validateChartVehicleSelection() {
    if (chartVehicleId == null) return;
    final exists =
        chartAdminVehicles.any((v) => _parseInt(v['id']) == chartVehicleId);
    if (!exists) {
      chartVehicleId = null;
    }
  }

  double? _adminWalletFromCompanyBody(dynamic body) {
    final data = body is Map ? getJsonField(body, r'''$.data''') : null;
    final rider = _parseDouble(getJsonField(data ?? body, r'''$.rider_total'''));
    final driver =
        _parseDouble(getJsonField(data ?? body, r'''$.driver_total'''));
    final total = _parseDouble(getJsonField(data ?? body, r'''$.total''')) ??
        _parseDouble(getJsonField(data ?? body, r'''$.balance''')) ??
        _parseDouble(getJsonField(data ?? body, r'''$.company_balance'''));
    if (total != null) return total;
    if (rider != null || driver != null) return (rider ?? 0) + (driver ?? 0);
    return null;
  }

  void _applyEarningsAnalyticsResponse(ApiCallResponse response) {
    if (!response.succeeded) return;
    final parsed = _extractEarningsSeriesAndLabels(response.jsonBody);
    final series = parsed.$1;
    final labels = parsed.$2;
    final lastWeek = parsed.$3;
    if (series.isNotEmpty) {
      earningsWeekly = series;
      earningsWeeklyLabels =
          labels.isEmpty ? _labelsForLength(series.length) : labels;
    }
    earningsLastWeek = lastWeek;
  }

  (List<double>, List<String>, List<double>) _extractEarningsSeriesAndLabels(
    dynamic body,
  ) {
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
                lastWeek.clear();
                for (final item in lwDaily.whereType<Map>()) {
                  final row = Map<String, dynamic>.from(item);
                  final val = _parseDouble(row['earnings']) ?? 0;
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
      data.forEach((key, value) {
        if (out.isNotEmpty) return;
        if (value is List && value.isNotEmpty && value.first is num) {
          addFromList(value);
        }
      });
      if (out.isEmpty) {
        final mapNums = <MapEntry<String, double>>[];
        data.forEach((key, value) {
          final numVal = _parseDouble(value);
          if (numVal != null) {
            mapNums.add(MapEntry(key.toString(), numVal));
          }
        });
        if (mapNums.length >= 2) {
          mapNums.sort((a, b) => a.key.compareTo(b.key));
          out.addAll(mapNums.map((e) => e.value));
        }
      }
    }
    if (labels.isEmpty && out.isNotEmpty) {
      labels.addAll(_labelsForLength(out.length));
    }
    return (out, labels, lastWeek);
  }

  void _applyRidesAnalyticsResponse(ApiCallResponse response) {
    if (!response.succeeded || response.jsonBody is! Map) return;
    final root = Map<String, dynamic>.from(response.jsonBody as Map);
    final data = root['data'];
    if (data is! Map) return;
    final week = data['week'];
    if (week is! List || week.isEmpty) return;

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
      ridesWeekly = values;
      ridesWeeklyLabels = labels;
      _ridesWeekFromAnalytics = true;
    }
  }

  List<dynamic> _parseRidesList(ApiCallResponse response) {
    if (!response.succeeded) return [];
    final raw = GetRidesCall.data(response.jsonBody);
    if (raw is List) return List<dynamic>.from(raw);
    if (response.jsonBody is Map) {
      final root = response.jsonBody as Map;
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

  void _applyRidesDerivedData(List<dynamic> allRides) {
    _allRides = List<dynamic>.from(allRides);

    final sorted = List<dynamic>.from(allRides);
    sorted.sort((a, b) {
      final da = _parseRideDate(a);
      final db = _parseRideDate(b);
      if (da != null && db != null) return db.compareTo(da);
      final ia = _parseInt(a is Map ? a['id'] : null);
      final ib = _parseInt(b is Map ? b['id'] : null);
      if (ia != null && ib != null) return ib.compareTo(ia);
      return 0;
    });
    recentRides = sorted.take(10).toList();

    _recomputeStatusFromCache();
    _recomputeRidesBarFromCache();
  }

  void _applyStatusCounts(List<dynamic> rides) {
    int completed = 0;
    int ongoing = 0;
    int cancelled = 0;

    for (final r in rides) {
      final s = _rideStatus(r);
      if (s.contains('cancel')) {
        cancelled++;
      } else if (s == 'completed') {
        completed++;
      } else {
        ongoing++;
      }
    }

    statusCompletedCount = completed;
    statusOngoingCount = ongoing;
    statusCancelledCount = cancelled;

    final total = completed + ongoing + cancelled;
    if (total > 0) {
      completedPct = completed / total;
      ongoingPct = ongoing / total;
      cancelledPct = cancelled / total;
    } else {
      completedPct = ongoingPct = cancelledPct = 0;
    }
  }

  List<double> _bucketRidesLast7Days(List<dynamic> rides) {
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

  List<String> _labelsForLast7Days() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: 6));
    return List<String>.generate(7, (i) {
      final day = start.add(Duration(days: i));
      return _weekdayAbbr(day.weekday);
    });
  }

  List<double> _bucketRidesOverDays(
    List<dynamic> rides,
    int totalDays,
    int numBuckets,
  ) {
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
      final dayIndex = day.difference(start).inDays;
      var idx = (dayIndex / span).floor();
      if (idx < 0) idx = 0;
      if (idx >= numBuckets) idx = numBuckets - 1;
      counts[idx] += 1;
    }
    return counts;
  }

  void _applyDriversResponse(ApiCallResponse response) {
    driversActiveAccounts = 0;
    driversPendingKyc = 0;
    driversBlockedAccounts = 0;
    if (!response.succeeded) return;
    var list = GetDriversCall.data(response.jsonBody);
    list ??= getJsonField(response.jsonBody, r'''$.data.drivers''') as List?;
    list ??= getJsonField(response.jsonBody, r'''$.drivers''') as List?;
    if (list == null || list.isEmpty) return;

    final scored = List<Map<String, dynamic>>.from(
      list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
    );

    for (final d in scored) {
      final kyc = (d['kyc_status']?.toString() ?? '').toLowerCase().trim();
      final active =
          _parseBool(d['is_active']) || _parseBool(d['active_driver']);
      final blockedFlag = _parseBool(d['is_blocked']) ||
          (d['account_status']?.toString().toLowerCase() == 'blocked') ||
          (d['status']?.toString().toLowerCase() == 'blocked');
      if (kyc == 'pending') {
        driversPendingKyc++;
      } else if (blockedFlag ||
          !active ||
          kyc == 'rejected' ||
          kyc == 'declined') {
        driversBlockedAccounts++;
      } else {
        driversActiveAccounts++;
      }
    }

    double score(Map<String, dynamic> d) {
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

    final rankedByToday = _rankTopDriversByDailyEarnings(scored);
    if (rankedByToday.isNotEmpty) {
      topDrivers = rankedByToday.take(8).toList();
      return;
    }

    scored.sort((a, b) => score(b).compareTo(score(a)));
    topDrivers = scored.take(8).toList();
  }

  List<Map<String, dynamic>> _rankTopDriversByDailyEarnings(
    List<Map<String, dynamic>> drivers,
  ) {
    if (drivers.isEmpty || _allRides.isEmpty) return [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final byDriverId = <int, Map<String, dynamic>>{};
    for (final d in drivers) {
      final id = _parseInt(d['id']);
      if (id != null) byDriverId[id] = d;
    }
    if (byDriverId.isEmpty) return [];

    final todayEarn = <int, double>{};
    final ydayEarn = <int, double>{};
    final todayRides = <int, int>{};

    for (final raw in _allRides) {
      if (raw is! Map) continue;
      final ride = Map<String, dynamic>.from(raw);
      final dt = _parseRideDate(ride);
      if (dt == null) continue;
      final day = DateTime(dt.year, dt.month, dt.day);
      if (day != today && day != yesterday) continue;

      final driverId = _rideDriverId(ride);
      if (driverId == null || !byDriverId.containsKey(driverId)) continue;

      final earn = _rideEarning(ride);
      if (earn == null || earn <= 0) continue;

      if (day == today) {
        todayEarn[driverId] = (todayEarn[driverId] ?? 0) + earn;
        todayRides[driverId] = (todayRides[driverId] ?? 0) + 1;
      } else {
        ydayEarn[driverId] = (ydayEarn[driverId] ?? 0) + earn;
      }
    }

    final out = <Map<String, dynamic>>[];
    for (final entry in byDriverId.entries) {
      final id = entry.key;
      final t = todayEarn[id] ?? 0;
      final y = ydayEarn[id] ?? 0;
      final rides = todayRides[id] ?? 0;
      if (t <= 0 && y <= 0 && rides <= 0) continue;

      final row = Map<String, dynamic>.from(entry.value);
      row['today_earnings'] = t;
      row['previous_day_earnings'] = y;
      row['today_rides'] = rides;
      out.add(row);
    }

    out.sort((a, b) {
      final ta = _parseDouble(a['today_earnings']) ?? 0;
      final tb = _parseDouble(b['today_earnings']) ?? 0;
      final byToday = tb.compareTo(ta);
      if (byToday != 0) return byToday;
      final ya = _parseDouble(a['previous_day_earnings']) ?? 0;
      final yb = _parseDouble(b['previous_day_earnings']) ?? 0;
      return yb.compareTo(ya);
    });
    return out;
  }

  void _applyPayoutsResponse(ApiCallResponse response) {
    if (!response.succeeded) return;
    pendingPayouts = GetAdminPendingPayoutsCall.payoutsList(response.jsonBody);
  }

  void _applyAllUsersStatsResponse(ApiCallResponse response) {
    if (!response.succeeded) return;
    var list = AllUsersCall.usersdata(response.jsonBody);
    list ??= getJsonField(response.jsonBody, r'''$.data.users''') as List?;
    list ??= getJsonField(response.jsonBody, r'''$.users''') as List?;
    if (list == null || list.isEmpty) return;

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
    usersActive = a;
    usersInactive = i;
    usersBlocked = b;
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

  static String _rideStatus(dynamic r) {
    final s = r is Map ? r['ride_status'] : null;
    return s?.toString().toLowerCase() ?? '';
  }

  static int? _rideDriverId(Map<String, dynamic> r) {
    final direct = _parseInt(r['driver_id']) ??
        _parseInt(r['driverId']) ??
        _parseInt(r['assigned_driver_id']);
    if (direct != null) return direct;
    final driver = r['driver'];
    if (driver is Map) {
      return _parseInt(driver['id']) ?? _parseInt(driver['driver_id']);
    }
    return null;
  }

  static double? _rideEarning(Map<String, dynamic> r) {
    for (final key in [
      'driver_earning',
      'driver_earnings',
      'driver_amount',
      'fare',
      'total_fare',
      'amount',
      'total_amount',
      'final_amount',
    ]) {
      final v = _parseDouble(r[key]);
      if (v != null) return v;
    }
    return null;
  }

  static DateTime? _parseRideDate(dynamic r) {
    if (r is! Map) return null;
    for (final key in ['created_at', 'ride_date', 'updated_at', 'scheduled_at']) {
      final raw = r[key];
      if (raw == null) continue;
      final s = raw.toString();
      try {
        return DateTime.parse(s);
      } catch (_) {}
    }
    return null;
  }

  static List<String> _labelsForLength(int n) {
    if (n == 7) {
      return const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    }
    return List<String>.generate(n, (i) => '${i + 1}');
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
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
      default:
        return 'Sun';
    }
  }

  bool _hasPreviewData() {
    return totalRides > 0 ||
        totalUsers > 0 ||
        totalDrivers > 0 ||
        earningsWeekly.isNotEmpty ||
        ridesWeekly.isNotEmpty ||
        recentRides.isNotEmpty;
  }

  bool get hasPreviewData => _hasPreviewData();

  Map<String, dynamic> _toCacheMap() {
    return {
      'totalRides': totalRides,
      'totalUsers': totalUsers,
      'totalDrivers': totalDrivers,
      'onlineDrivers': onlineDrivers,
      'usersActive': usersActive,
      'usersInactive': usersInactive,
      'usersBlocked': usersBlocked,
      'driversActiveAccounts': driversActiveAccounts,
      'driversPendingKyc': driversPendingKyc,
      'driversBlockedAccounts': driversBlockedAccounts,
      'ridesCompletedToday': ridesCompletedToday,
      'newUsersToday': newUsersToday,
      'totalEarnings': totalEarnings,
      'adminWallet': adminWallet,
      'earningsWeekly': earningsWeekly,
      'earningsLastWeek': earningsLastWeek,
      'ridesWeekly': ridesWeekly,
      'earningsWeeklyLabels': earningsWeeklyLabels,
      'ridesWeeklyLabels': ridesWeeklyLabels,
      'completedPct': completedPct,
      'ongoingPct': ongoingPct,
      'cancelledPct': cancelledPct,
      'statusCompletedCount': statusCompletedCount,
      'statusOngoingCount': statusOngoingCount,
      'statusCancelledCount': statusCancelledCount,
      'recentRides': recentRides,
      'topDrivers': topDrivers,
      'pendingPayouts': pendingPayouts,
    };
  }

  Future<void> _hydrateFromCache() async {
    final cached = await CacheService.getData(_cacheKey);
    lastUpdatedAt = await CacheService.getLastUpdated(_cacheKey);
    if (cached == null) return;

    totalRides = _parseInt(cached['totalRides']) ?? totalRides;
    totalUsers = _parseInt(cached['totalUsers']) ?? totalUsers;
    totalDrivers = _parseInt(cached['totalDrivers']) ?? totalDrivers;
    onlineDrivers = _parseInt(cached['onlineDrivers']) ?? onlineDrivers;
    usersActive = _parseInt(cached['usersActive']) ?? usersActive;
    usersInactive = _parseInt(cached['usersInactive']) ?? usersInactive;
    usersBlocked = _parseInt(cached['usersBlocked']) ?? usersBlocked;
    driversActiveAccounts =
        _parseInt(cached['driversActiveAccounts']) ?? driversActiveAccounts;
    driversPendingKyc =
        _parseInt(cached['driversPendingKyc']) ?? driversPendingKyc;
    driversBlockedAccounts =
        _parseInt(cached['driversBlockedAccounts']) ?? driversBlockedAccounts;
    ridesCompletedToday =
        _parseInt(cached['ridesCompletedToday']) ?? ridesCompletedToday;
    newUsersToday = _parseInt(cached['newUsersToday']) ?? newUsersToday;
    totalEarnings = _parseDouble(cached['totalEarnings']) ?? totalEarnings;
    adminWallet = _parseDouble(cached['adminWallet']) ?? adminWallet;
    earningsWeekly = _toDoubleList(cached['earningsWeekly']);
    earningsLastWeek = _toDoubleList(cached['earningsLastWeek']);
    ridesWeekly = _toDoubleList(cached['ridesWeekly']);
    earningsWeeklyLabels = _toStringList(cached['earningsWeeklyLabels']);
    ridesWeeklyLabels = _toStringList(cached['ridesWeeklyLabels']);
    completedPct = _parseDouble(cached['completedPct']) ?? completedPct;
    ongoingPct = _parseDouble(cached['ongoingPct']) ?? ongoingPct;
    cancelledPct = _parseDouble(cached['cancelledPct']) ?? cancelledPct;
    statusCompletedCount =
        _parseInt(cached['statusCompletedCount']) ?? statusCompletedCount;
    statusOngoingCount =
        _parseInt(cached['statusOngoingCount']) ?? statusOngoingCount;
    statusCancelledCount =
        _parseInt(cached['statusCancelledCount']) ?? statusCancelledCount;
    recentRides = _toMapList(cached['recentRides']);
    topDrivers = _toMapList(cached['topDrivers']);
    pendingPayouts = _toMapList(cached['pendingPayouts']);
    _notifyIfChanged(force: true);
  }

  Future<void> _persistCache() async {
    await CacheService.saveData(_cacheKey, _toCacheMap());
    lastUpdatedAt = await CacheService.getLastUpdated(_cacheKey);
  }

  void _notifyIfChanged({bool force = false}) {
    final fingerprint = _toCacheMap().toString();
    if (force || _lastUiFingerprint != fingerprint) {
      _lastUiFingerprint = fingerprint;
      notifyListeners();
    }
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
