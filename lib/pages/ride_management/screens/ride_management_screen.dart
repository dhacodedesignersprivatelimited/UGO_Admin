import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/components/admin_scaffold.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '../../dashboard_page/dashboard/widgets/top_drivers_list.dart';
import '../models/ride_model.dart';
import '../ride_party_fetch.dart';
import '../ride_row_data.dart';
import '../widgets/analytics/analytics_section.dart';
import '../widgets/filters/filter_bar.dart';
import '../widgets/recent_cancelled_rides_list.dart';
import '../widgets/ride_list/ride_list.dart';
import '../widgets/stats/stats_grid.dart';

class RideManagementScreen extends StatefulWidget {
  const RideManagementScreen({super.key});

  static String routeName = 'RideManagement';
  static String routePath = '/ride-management';

  @override
  State<RideManagementScreen> createState() => _RideManagementScreenState();
}

class _RideManagementScreenState extends State<RideManagementScreen> {
  Future<_RideManagementData>? _future;
  /// Bumped so [RideList] can switch to the Cancelled tab (e.g. recent widget "View All").
  int _rideListCancelTabRequest = 0;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_RideManagementData> _load() async {
    final token = currentAuthenticationToken ?? '';
    if (token.isEmpty) {
      throw Exception('Not authenticated');
    }

    final statsResp = await GetRideStatusStatsCall.call(token: token);
    if (!statsResp.succeeded) {
      throw Exception('Failed to load ride stats (${statsResp.statusCode})');
    }

    final ridesResp = await GetRidesCall.call(token: token);
    if (!ridesResp.succeeded) {
      throw Exception('Failed to load rides (${ridesResp.statusCode})');
    }

    ApiCallResponse? dashResp;
    try {
      final d = await DashBoardCall.call(token: token);
      if (d.succeeded) dashResp = d;
    } catch (_) {}

    final rideStatusMap =
        GetRideStatusStatsCall.rideStatus(statsResp.jsonBody);
    final stats = _rideStatsMap(statsResp.jsonBody, rideStatusMap, dashResp);

    final ridesRaw = _ridesListFromResponse(ridesResp);

    final userIds = <int>{};
    final driverIds = <int>{};
    RidePartyFetch.collectIdsFromRides(ridesRaw, userIds, driverIds);
    final usersById = await RidePartyFetch.fetchUsersByIds(userIds, token);
    final driversById = await RidePartyFetch.fetchDriversByIds(driverIds, token);

    final rows = <RideRowData>[];
    for (final r in ridesRaw) {
      final tmp = RideRowData.tryParse(r);
      if (tmp == null) continue;
      rows.add(RideRowData.tryParse(
            r,
            userDetail:
                tmp.riderUserId != null ? usersById[tmp.riderUserId!] : null,
            driverDetail:
                tmp.linkedDriverId != null ? driversById[tmp.linkedDriverId!] : null,
          ) ??
          tmp);
    }

    rows.sort((a, b) {
      final da = a.requestedAt;
      final db = b.requestedAt;
      if (da != null && db != null) return db.compareTo(da);
      final ia = a.rideId ?? 0;
      final ib = b.rideId ?? 0;
      return ib.compareTo(ia);
    });

    List<dynamic> topDrivers = [];
    try {
      final driversResp = await GetDriversCall.call(token: token);
      if (driversResp.succeeded) {
        topDrivers = _computeTopDrivers(driversResp);
      }
    } catch (_) {}

    return _RideManagementData(
      stats: stats,
      rows: rows,
      topDrivers: topDrivers,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Ride management',
      child: FutureBuilder<_RideManagementData>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      snap.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _future = _load();
                      }),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snap.data!;
          final mq = MediaQuery.of(context);
          final sw = mq.size.width;
          final padH = sw < 360 ? 12.0 : (sw < 600 ? 16.0 : (sw < 900 ? 20.0 : 24.0));
          final padV = sw < 360 ? 12.0 : 16.0;
          final sectionGap = sw < 380 ? 12.0 : 16.0;

          final recentCancelled = data.rows
              .where((r) => r.humanStatus == 'Cancelled')
              .take(3)
              .toList();
          final driversInsights = sw >= 900
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TopDriversList(
                        drivers: data.topDrivers,
                        isLoading: false,
                        maxRows: 5,
                      ),
                    ),
                    SizedBox(width: sectionGap),
                    Expanded(
                      child: RecentCancelledRidesList(
                        rows: recentCancelled,
                        onViewAll: () => setState(
                              () => _rideListCancelTabRequest++,
                            ),
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TopDriversList(
                      drivers: data.topDrivers,
                      isLoading: false,
                      maxRows: 5,
                    ),
                    SizedBox(height: sectionGap),
                    RecentCancelledRidesList(
                      rows: recentCancelled,
                      onViewAll: () => setState(
                            () => _rideListCancelTabRequest++,
                          ),
                    ),
                  ],
                );

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              padH,
              padV,
              padH,
              padV + mq.padding.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StatsGrid(stats: data.stats),
                SizedBox(height: sectionGap),
                const FilterBar(),
                SizedBox(height: sectionGap),
                driversInsights,
                SizedBox(height: sectionGap),
                RideList(
                  rides: data.allRideModels,
                  cancelTabRequestVersion: _rideListCancelTabRequest,
                ),
                SizedBox(height: sectionGap),
                const AnalyticsSection(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RideManagementData {
  const _RideManagementData({
    required this.stats,
    required this.rows,
    required this.topDrivers,
  });

  final Map<String, String> stats;
  final List<RideRowData> rows;
  final List<dynamic> topDrivers;

  List<RideModel> get allRideModels =>
      rows.map(_rideModelFromRow).toList();
}

RideModel _rideModelFromRow(RideRowData e) {
  return RideModel(
    id: (e.rideId ?? 0).toString(),
    displayId: e.rideIdLabel,
    dateSubtitle: e.rideSubtitle,
    userName: e.riderName,
    userPhone: e.riderPhone,
    driverName: e.driverName,
    driverPhone: e.driverPhone,
    pickup: e.pickup,
    drop: e.drop,
    status: e.humanStatus,
    fare: e.fare,
    paymentMethod: e.paymentLabel,
    distanceDuration: e.distanceDurationLine,
    riderAvatarUrl: e.riderImageUrl,
    driverAvatarUrl: e.driverImageUrl,
  );
}

double? _parseDoubleForTopDrivers(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  return double.tryParse(v.toString());
}

/// Same fallback ranking as [DashboardPageModel._applyDriversResponse] when
/// daily earnings ranking is unavailable.
List<dynamic> _computeTopDrivers(ApiCallResponse response) {
  var list = GetDriversCall.data(response.jsonBody);
  if (list == null || list.isEmpty) {
    final body = response.jsonBody;
    if (body is Map) {
      final d = body['data'];
      if (d is List) list = d;
      final alt = body['drivers'];
      if (alt is List) list = alt;
    }
  }
  if (list == null || list.isEmpty) return [];

  final scored = List<Map<String, dynamic>>.from(
    list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
  );

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
      final v = _parseDoubleForTopDrivers(d[k]);
      if (v != null && v > 0) return v;
    }
    return 0;
  }

  scored.sort((a, b) => score(b).compareTo(score(a)));
  return scored.take(8).toList();
}

Map<String, String> _rideStatsMap(
  dynamic statsBody,
  Map<String, dynamic>? rideStatusMap,
  ApiCallResponse? dashResp,
) {
  final total = GetRideStatusStatsCall.total(statsBody) ?? 0;
  final cCompleted =
      GetRideStatusStatsCall.statusCount(rideStatusMap, 'completed') ?? 0;
  final cOngoing =
      GetRideStatusStatsCall.statusCount(rideStatusMap, 'ongoing') ?? 0;
  final cCancelled =
      GetRideStatusStatsCall.statusCount(rideStatusMap, 'cancelled') ?? 0;

  final pCompleted =
      GetRideStatusStatsCall.statusPercentage(rideStatusMap, 'completed') ??
          0.0;
  final pOngoing =
      GetRideStatusStatsCall.statusPercentage(rideStatusMap, 'ongoing') ??
          0.0;
  final pCancelled =
      GetRideStatusStatsCall.statusPercentage(rideStatusMap, 'cancelled') ??
          0.0;

  String fmtInt(int n) {
    try {
      return NumberFormat.decimalPattern('en_IN').format(n);
    } catch (_) {
      return '$n';
    }
  }

  String fmtPct(double p) => '${p.toStringAsFixed(1)}%';

  final todayRides = dashResp != null
      ? DashBoardCall.todayrides(dashResp.jsonBody)
      : null;
  final totalFooterLeft = todayRides != null ? 'Today · $todayRides' : 'Today';

  final earnings = dashResp != null
      ? DashBoardCall.totalearnings(dashResp.jsonBody)
      : null;
  final earnStr = earnings == null
      ? '—'
      : NumberFormat.currency(
          locale: 'en_IN',
          symbol: '₹',
          decimalDigits: 2,
        ).format(earnings);

  return {
    'total_value': fmtInt(total),
    'completed_value': fmtInt(cCompleted),
    'ongoing_value': fmtInt(cOngoing),
    'cancelled_value': fmtInt(cCancelled),
    'completed_footer_left': fmtPct(pCompleted),
    'ongoing_footer_left': fmtPct(pOngoing),
    'cancelled_footer_left': fmtPct(pCancelled),
    'total_footer_left': totalFooterLeft,
    'earnings_value': earnStr,
    'earnings_footer_left': 'Today',
    // Wire when API returns period deltas, e.g. `+ 12.5%`
    'total_trend': '',
    'completed_trend': '',
    'ongoing_trend': '',
    'cancelled_trend': '',
    'earnings_trend': '',
  };
}

/// Same shape handling as [DashboardPageModel._parseRidesList].
List<dynamic> _ridesListFromResponse(ApiCallResponse response) {
  final raw = GetRidesCall.data(response.jsonBody);
  if (raw is List) return List<dynamic>.from(raw);
  final body = response.jsonBody;
  if (body is Map) {
    final d = body['data'];
    if (d is List) return List<dynamic>.from(d);
    if (d is Map && d['rides'] is List) {
      return List<dynamic>.from(d['rides'] as List);
    }
    final top = body['rides'];
    if (top is List) return List<dynamic>.from(top);
  }
  return [];
}