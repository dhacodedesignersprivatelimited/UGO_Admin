// import 'dart:async';
//
// import '/auth/custom_auth/auth_util.dart';
// import '/backend/api_requests/api_calls.dart';
// import '/flutter_flow/flutter_flow_util.dart';
// import '/pages/ride_management/ride_party_fetch.dart';
// import 'package:flutter/foundation.dart';
//
// class DashboardViewModel extends ChangeNotifier {
//   bool isLoading = false;
//   bool chartRefreshing = false;
//   String? errorMessage;
//
//   int totalRides = 0;
//   int totalUsers = 0;
//   int totalDrivers = 0;
//   int onlineDrivers = 0;
//
//   /// From all-users list (or dashboard keys when list missing).
//   int usersActive = 0;
//   int usersInactive = 0;
//   int usersBlocked = 0;
//
//   /// From full drivers list (KYC + active flags).
//   int driversActiveAccounts = 0;
//   int driversPendingKyc = 0;
//   int driversBlockedAccounts = 0;
//   int ridesCompletedToday = 0;
//   int newUsersToday = 0;
//
//   double totalEarnings = 0;
//   double adminWallet = 0;
//
//   List<double> earningsWeekly = [];
//   List<double> ridesWeekly = [];
//
//   double completedPct = 0;
//   double ongoingPct = 0;
//   double cancelledPct = 0;
//
//   /// Raw counts for the current status filter (pie tooltips).
//   int statusCompletedCount = 0;
//   int statusOngoingCount = 0;
//   int statusCancelledCount = 0;
//
//   List<dynamic> recentRides = [];
//   List<dynamic> topDrivers = [];
//   List<dynamic> pendingPayouts = [];
//
//   List<dynamic> _allRides = [];
//
//   /// From [GetUserByIdCall] / [GetDriverByIdCall] for [recentRides] rows.
//   Map<int, Map<String, dynamic>> recentRideUserById = {};
//   Map<int, Map<String, dynamic>> recentRideDriverById = {};
//
//   /// Bumps when chart series change so the UI can replay enter animations.
//   int chartRevision = 0;
//
//   String chartEarningsPeriod = 'weekly';
//   /// `null` = all admin vehicles; otherwise `data[].id` from [GetAllVehiclesCall].
//   int? chartVehicleId;
//   List<Map<String, dynamic>> chartAdminVehicles = [];
//   /// 7 = one bar per day for last 7 days; 30 = 10 bars over 30 days.
//   int chartRideBarDays = 7;
//   /// 0 = all time; else last N days for status pie.
//   int chartStatusDays = 0;
//
//   /// Rows that still need admin action (excludes completed / paid / failed).
//   int get pendingPayoutCount {
//     var n = 0;
//     for (final raw in pendingPayouts) {
//       if (raw is! Map) continue;
//       final s = (raw['status']?.toString() ?? '').toLowerCase();
//       if (s.contains('completed') ||
//           s.contains('paid') ||
//           s.contains('success')) {
//         continue;
//       }
//       if (s.contains('fail') || s.contains('reject') || s.contains('error')) {
//         continue;
//       }
//       n++;
//     }
//     return n;
//   }
//
//   /// Background refresh for user/driver stats cards (lightweight vs [loadAll]).
//   Timer? _userDriverStatsTimer;
//   static const Duration userDriverStatsPollInterval = Duration(seconds: 45);
//
//   static const List<String> earningsPeriodOptions = [
//     'weekly',
//     'monthly',
//     'yearly',
//   ];
//
//   /// Label for earnings chart tooltips / filters.
//   String get chartSelectedVehicleLabel {
//     if (chartVehicleId == null) return 'All vehicles';
//     for (final v in chartAdminVehicles) {
//       if (_parseInt(v['id']) == chartVehicleId) {
//         return v['vehicle_name']?.toString() ?? 'Vehicle #$chartVehicleId';
//       }
//     }
//     return 'All vehicles';
//   }
//
//   void _bumpChartRevision() {
//     chartRevision++;
//     notifyListeners();
//   }
//
//   /// Polls dashboard + users + drivers to keep stat gauges fresh without a full reload.
//   void startUserDriverStatsPolling() {
//     _userDriverStatsTimer?.cancel();
//     _userDriverStatsTimer =
//         Timer.periodic(userDriverStatsPollInterval, (_) {
//       unawaited(refreshUserDriverStats());
//     });
//   }
//
//   void stopUserDriverStatsPolling() {
//     _userDriverStatsTimer?.cancel();
//     _userDriverStatsTimer = null;
//   }
//
//   /// Updates headline totals, user buckets, driver buckets, and top-drivers list.
//   Future<void> refreshUserDriverStats() async {
//     final token = currentAuthenticationToken;
//     if (token == null || token.isEmpty) return;
//     try {
//       final r = await Future.wait([
//         DashBoardCall.call(token: token),
//         AllUsersCall.call(token: token),
//         GetDriversCall.call(token: token),
//       ]);
//       _applyDashboardResponse(r[0]);
//       _applyAllUsersStatsResponse(r[1]);
//       _applyDriversResponse(r[2]);
//       notifyListeners();
//     } catch (_) {
//       // Silent: avoid spamming errors for background poll
//     }
//   }
//
//   @override
//   @mustCallSuper
//   void dispose() {
//     stopUserDriverStatsPolling();
//     super.dispose();
//   }
//
//   Future<void> loadAll() async {
//     isLoading = true;
//     errorMessage = null;
//     earningsWeekly = [];
//     ridesWeekly = [];
//     recentRides = [];
//     topDrivers = [];
//     pendingPayouts = [];
//     _allRides = [];
//     recentRideUserById = {};
//     recentRideDriverById = {};
//     usersActive = 0;
//     usersInactive = 0;
//     usersBlocked = 0;
//     driversActiveAccounts = 0;
//     driversPendingKyc = 0;
//     driversBlockedAccounts = 0;
//     notifyListeners();
//
//     final token = currentAuthenticationToken;
//
//     try {
//       final results = await Future.wait([
//         DashBoardCall.call(token: token),
//         CompanyWalletCall.call(token: token),
//         EarningsAnalyticsCall.call(
//           token: token,
//           period: chartEarningsPeriod,
//           vehicleId: chartVehicleId,
//         ),
//         GetRidesCall.call(token: token),
//         GetDriversCall.call(token: token),
//         GetAdminPendingPayoutsCall.call(
//           token: token,
//           limit: 25,
//           includeStatusParam: false,
//         ),
//         AllUsersCall.call(token: token),
//         GetAllVehiclesCall.call(token: token),
//       ]);
//
//       _applyDashboardResponse(results[0]);
//       _applyCompanyWalletResponse(results[1]);
//       _applyEarningsAnalyticsResponse(results[2]);
//
//       final ridesList = _parseRidesList(results[3]);
//       _applyRidesDerivedData(ridesList);
//
//       await _enrichRecentRideParties(token ?? '');
//
//       _applyDriversResponse(results[4]);
//       _applyPayoutsResponse(results[5]);
//       _applyAllUsersStatsResponse(results[6]);
//
//       final earningsStale = _applyChartVehiclesResponse(results[7]);
//       if (earningsStale) {
//         final redo = await EarningsAnalyticsCall.call(
//           token: token,
//           period: chartEarningsPeriod,
//           vehicleId: chartVehicleId,
//         );
//         earningsWeekly = [];
//         _applyEarningsAnalyticsResponse(redo);
//       }
//
//       if (earningsWeekly.isEmpty && totalEarnings > 0) {
//         final n = chartEarningsPeriod == 'yearly' ? 12 : 7;
//         earningsWeekly = List<double>.filled(n, totalEarnings / n);
//       }
//
//       if (errorMessage == null && !results[0].succeeded) {
//         errorMessage = 'Failed to load dashboard (${results[0].statusCode})';
//       }
//     } catch (e) {
//       errorMessage = e.toString();
//     } finally {
//       isLoading = false;
//       chartRevision++;
//       notifyListeners();
//     }
//   }
//
//   Future<void> setChartEarningsPeriod(String period) async {
//     if (chartEarningsPeriod == period) return;
//     chartEarningsPeriod = period;
//     notifyListeners();
//     await refreshEarningsChartFromApi();
//   }
//
//   Future<void> setChartVehicleFilter(int? vehicleId) async {
//     if (chartVehicleId == vehicleId) return;
//     chartVehicleId = vehicleId;
//     notifyListeners();
//     await refreshEarningsChartFromApi();
//   }
//
//   Future<void> refreshEarningsChartFromApi() async {
//     chartRefreshing = true;
//     notifyListeners();
//     try {
//       final resp = await EarningsAnalyticsCall.call(
//         token: currentAuthenticationToken,
//         period: chartEarningsPeriod,
//         vehicleId: chartVehicleId,
//       );
//       earningsWeekly = [];
//       _applyEarningsAnalyticsResponse(resp);
//       if (earningsWeekly.isEmpty && totalEarnings > 0) {
//         final n = chartEarningsPeriod == 'yearly' ? 12 : 7;
//         earningsWeekly = List<double>.filled(n, totalEarnings / n);
//       }
//     } finally {
//       chartRefreshing = false;
//       _bumpChartRevision();
//     }
//   }
//
//   void setChartRideBarDays(int days) {
//     final d = days == 30 ? 30 : 7;
//     if (chartRideBarDays == d) return;
//     chartRideBarDays = d;
//     _recomputeRidesBarFromCache();
//     _bumpChartRevision();
//   }
//
//   void setChartStatusWindow(int days) {
//     if (chartStatusDays == days) return;
//     chartStatusDays = days;
//     _recomputeStatusFromCache();
//     _bumpChartRevision();
//   }
//
//   Future<void> _enrichRecentRideParties(String token) async {
//     if (token.isEmpty) return;
//     recentRideUserById = {};
//     recentRideDriverById = {};
//     if (recentRides.isEmpty) return;
//     final uIds = <int>{};
//     final dIds = <int>{};
//     RidePartyFetch.collectIdsFromRides(recentRides, uIds, dIds);
//     recentRideUserById = await RidePartyFetch.fetchUsersByIds(uIds, token);
//     recentRideDriverById = await RidePartyFetch.fetchDriversByIds(dIds, token);
//     notifyListeners();
//   }
//
//   void _recomputeRidesBarFromCache() {
//     if (chartRideBarDays <= 7) {
//       ridesWeekly = _bucketRidesLast7Days(_allRides);
//     } else {
//       ridesWeekly = _bucketRidesOverDays(_allRides, 30, 10);
//     }
//   }
//
//   void _recomputeStatusFromCache() {
//     final rides = chartStatusDays <= 0
//         ? _allRides
//         : _filterRidesWithinLastDays(_allRides, chartStatusDays);
//     _applyStatusCounts(rides);
//   }
//
//   List<dynamic> _filterRidesWithinLastDays(List<dynamic> rides, int days) {
//     final now = DateTime.now();
//     final cutoff = DateTime(now.year, now.month, now.day)
//         .subtract(Duration(days: days - 1));
//     return rides.where((r) {
//       final dt = _parseRideDate(r);
//       if (dt == null) return false;
//       final day = DateTime(dt.year, dt.month, dt.day);
//       return !day.isBefore(cutoff);
//     }).toList();
//   }
//
//   void _applyDashboardResponse(ApiCallResponse response) {
//     if (!response.succeeded || response.jsonBody is! Map) return;
//     final root = Map<String, dynamic>.from(response.jsonBody as Map);
//     final data = root['data'];
//     if (data is! Map) return;
//     final m = Map<String, dynamic>.from(data);
//
//     totalRides = _parseInt(m['total_rides']) ?? 0;
//     totalUsers = _parseInt(m['total_users']) ?? 0;
//     totalDrivers = _parseInt(m['total_drivers']) ?? 0;
//     onlineDrivers = _parseInt(m['active_drivers']) ?? 0;
//     ridesCompletedToday = _parseInt(m['rides_completed_today']) ?? 0;
//     newUsersToday = _parseInt(m['new_users_today']) ?? 0;
//     totalEarnings = _parseDouble(m['total_earnings']) ?? 0;
//
//     final ua = _parseInt(m['active_users']) ?? _parseInt(m['user_active']);
//     final ui = _parseInt(m['inactive_users']) ?? _parseInt(m['user_inactive']);
//     final ub = _parseInt(m['blocked_users']) ?? _parseInt(m['blockedUsers']);
//     if (ua != null) usersActive = ua;
//     if (ui != null) usersInactive = ui;
//     if (ub != null) usersBlocked = ub;
//
//     final da =
//         _parseInt(m['active_driver_accounts']) ?? _parseInt(m['drivers_active']);
//     final dp = _parseInt(m['pending_drivers']) ?? _parseInt(m['drivers_pending']);
//     final db =
//         _parseInt(m['blocked_drivers']) ?? _parseInt(m['drivers_blocked']);
//     if (da != null) driversActiveAccounts = da;
//     if (dp != null) driversPendingKyc = dp;
//     if (db != null) driversBlockedAccounts = db;
//
//     final w = _parseDouble(m['admin_wallet']) ??
//         _parseDouble(m['company_wallet']) ??
//         _parseDouble(m['platform_balance']) ??
//         _parseDouble(m['wallet_balance']);
//     if (w != null) adminWallet = w;
//   }
//
//   void _applyCompanyWalletResponse(ApiCallResponse response) {
//     if (!response.succeeded) return;
//     final w = _adminWalletFromCompanyBody(response.jsonBody);
//     if (w != null && w > 0) adminWallet = w;
//   }
//
//   /// Parses admin vehicles list. Returns true if [chartVehicleId] was cleared
//   /// (stale selection) so earnings analytics should be requested again.
//   bool _applyChartVehiclesResponse(ApiCallResponse response) {
//     chartAdminVehicles = [];
//     if (!response.succeeded) return false;
//     final body = response.jsonBody;
//     if (body is! Map) return false;
//     final data = body['data'];
//     if (data is! List) return false;
//
//     final beforeId = chartVehicleId;
//     for (final item in data) {
//       if (item is Map) {
//         chartAdminVehicles.add(Map<String, dynamic>.from(item));
//       }
//     }
//     chartAdminVehicles.sort((a, b) {
//       final na = a['vehicle_name']?.toString() ?? '';
//       final nb = b['vehicle_name']?.toString() ?? '';
//       return na.compareTo(nb);
//     });
//
//     _validateChartVehicleSelection();
//     return beforeId != chartVehicleId;
//   }
//
//   void _validateChartVehicleSelection() {
//     if (chartVehicleId == null) return;
//     final exists =
//         chartAdminVehicles.any((v) => _parseInt(v['id']) == chartVehicleId);
//     if (!exists) {
//       chartVehicleId = null;
//     }
//   }
//
//   double? _adminWalletFromCompanyBody(dynamic body) {
//     final data = body is Map ? getJsonField(body, r'''$.data''') : null;
//     final rider = _parseDouble(getJsonField(data ?? body, r'''$.rider_total'''));
//     final driver = _parseDouble(getJsonField(data ?? body, r'''$.driver_total'''));
//     final total = _parseDouble(getJsonField(data ?? body, r'''$.total''')) ??
//         _parseDouble(getJsonField(data ?? body, r'''$.balance''')) ??
//         _parseDouble(getJsonField(data ?? body, r'''$.company_balance'''));
//     if (total != null) return total;
//     if (rider != null || driver != null) return (rider ?? 0) + (driver ?? 0);
//     return null;
//   }
//
//   void _applyEarningsAnalyticsResponse(ApiCallResponse response) {
//     if (!response.succeeded) return;
//     final series = _extractNumericSeries(response.jsonBody);
//     if (series.isNotEmpty) {
//       earningsWeekly = series;
//     }
//   }
//
//   List<double> _extractNumericSeries(dynamic body) {
//     final out = <double>[];
//     if (body is! Map) return out;
//     dynamic data = body['data'];
//
//     void addFromList(List list) {
//       for (final item in list) {
//         if (item is num) {
//           out.add(item.toDouble());
//         } else if (item is Map) {
//           final v = _parseDouble(item['amount']) ??
//               _parseDouble(item['value']) ??
//               _parseDouble(item['earnings']) ??
//               _parseDouble(item['total']) ??
//               _parseDouble(item['count']) ??
//               _parseDouble(item['rides']);
//           if (v != null) out.add(v);
//         }
//       }
//     }
//
//     if (data is List) {
//       addFromList(data);
//       return out;
//     }
//     if (data is Map) {
//       for (final key in [
//         'weekly_earnings',
//         'monthly_earnings',
//         'yearly_earnings',
//         'series',
//         'breakdown',
//         'chart_data',
//         'data_points',
//         'values',
//         'daily_rides',
//         'rides_per_day',
//         'labels_data',
//       ]) {
//         final v = data[key];
//         if (v is List && v.isNotEmpty) {
//           addFromList(v);
//           if (out.isNotEmpty) return out;
//         }
//       }
//       data.forEach((key, value) {
//         if (out.isNotEmpty) return;
//         if (value is List && value.isNotEmpty && value.first is num) {
//           addFromList(value);
//         }
//       });
//     }
//     return out;
//   }
//
//   List<dynamic> _parseRidesList(ApiCallResponse response) {
//     if (!response.succeeded) return [];
//     final raw = GetRidesCall.data(response.jsonBody);
//     if (raw is List) return List<dynamic>.from(raw);
//     if (response.jsonBody is Map) {
//       final d = (response.jsonBody as Map)['data'];
//       if (d is List) return List<dynamic>.from(d);
//     }
//     return [];
//   }
//
//   void _applyRidesDerivedData(List<dynamic> allRides) {
//     _allRides = List<dynamic>.from(allRides);
//
//     final sorted = List<dynamic>.from(allRides);
//     sorted.sort((a, b) {
//       final da = _parseRideDate(a);
//       final db = _parseRideDate(b);
//       if (da != null && db != null) return db.compareTo(da);
//       final ia = _parseInt(a is Map ? a['id'] : null);
//       final ib = _parseInt(b is Map ? b['id'] : null);
//       if (ia != null && ib != null) return ib.compareTo(ia);
//       return 0;
//     });
//     recentRides = sorted.take(10).toList();
//
//     _recomputeStatusFromCache();
//     _recomputeRidesBarFromCache();
//   }
//
//   void _applyStatusCounts(List<dynamic> rides) {
//     int completed = 0;
//     int ongoing = 0;
//     int cancelled = 0;
//
//     for (final r in rides) {
//       final s = _rideStatus(r);
//       if (s.contains('cancel')) {
//         cancelled++;
//       } else if (s == 'completed') {
//         completed++;
//       } else {
//         ongoing++;
//       }
//     }
//
//     statusCompletedCount = completed;
//     statusOngoingCount = ongoing;
//     statusCancelledCount = cancelled;
//
//     final total = completed + ongoing + cancelled;
//     if (total > 0) {
//       completedPct = completed / total;
//       ongoingPct = ongoing / total;
//       cancelledPct = cancelled / total;
//     } else {
//       completedPct = ongoingPct = cancelledPct = 0;
//     }
//   }
//
//   List<double> _bucketRidesLast7Days(List<dynamic> rides) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final start = today.subtract(const Duration(days: 6));
//     final counts = List<double>.filled(7, 0);
//
//     for (final r in rides) {
//       final dt = _parseRideDate(r);
//       if (dt == null) continue;
//       final day = DateTime(dt.year, dt.month, dt.day);
//       final idx = day.difference(start).inDays;
//       if (idx >= 0 && idx < 7) counts[idx] += 1;
//     }
//     return counts;
//   }
//
//   List<double> _bucketRidesOverDays(
//     List<dynamic> rides,
//     int totalDays,
//     int numBuckets,
//   ) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final start = today.subtract(Duration(days: totalDays - 1));
//     final counts = List<double>.filled(numBuckets, 0);
//     final span = totalDays / numBuckets;
//
//     for (final r in rides) {
//       final dt = _parseRideDate(r);
//       if (dt == null) continue;
//       final day = DateTime(dt.year, dt.month, dt.day);
//       if (day.isBefore(start) || day.isAfter(today)) continue;
//       final dayIndex = day.difference(start).inDays;
//       var idx = (dayIndex / span).floor();
//       if (idx < 0) idx = 0;
//       if (idx >= numBuckets) idx = numBuckets - 1;
//       counts[idx] += 1;
//     }
//     return counts;
//   }
//
//   void _applyDriversResponse(ApiCallResponse response) {
//     driversActiveAccounts = 0;
//     driversPendingKyc = 0;
//     driversBlockedAccounts = 0;
//     if (!response.succeeded) return;
//     var list = GetDriversCall.data(response.jsonBody);
//     list ??= getJsonField(response.jsonBody, r'''$.data.drivers''') as List?;
//     list ??= getJsonField(response.jsonBody, r'''$.drivers''') as List?;
//     if (list == null || list.isEmpty) return;
//
//     final scored = List<Map<String, dynamic>>.from(
//       list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
//     );
//
//     for (final d in scored) {
//       final kyc = (d['kyc_status']?.toString() ?? '').toLowerCase().trim();
//       final active =
//           _parseBool(d['is_active']) || _parseBool(d['active_driver']);
//       final blockedFlag = _parseBool(d['is_blocked']) ||
//           (d['account_status']?.toString().toLowerCase() == 'blocked') ||
//           (d['status']?.toString().toLowerCase() == 'blocked');
//       if (kyc == 'pending') {
//         driversPendingKyc++;
//       } else if (blockedFlag ||
//           !active ||
//           kyc == 'rejected' ||
//           kyc == 'declined') {
//         driversBlockedAccounts++;
//       } else {
//         driversActiveAccounts++;
//       }
//     }
//
//     double score(Map<String, dynamic> d) {
//       for (final k in [
//         'total_earnings',
//         'lifetime_earnings',
//         'wallet_balance',
//         'balance',
//         'total_trips',
//         'completed_rides',
//         'ride_count',
//       ]) {
//         final v = _parseDouble(d[k]);
//         if (v != null && v > 0) return v;
//       }
//       return 0;
//     }
//
//     scored.sort((a, b) => score(b).compareTo(score(a)));
//     topDrivers = scored.take(8).toList();
//   }
//
//   void _applyPayoutsResponse(ApiCallResponse response) {
//     if (!response.succeeded) return;
//     pendingPayouts = GetAdminPendingPayoutsCall.payoutsList(response.jsonBody);
//   }
//
//   void _applyAllUsersStatsResponse(ApiCallResponse response) {
//     if (!response.succeeded) return;
//     var list = AllUsersCall.usersdata(response.jsonBody);
//     list ??= getJsonField(response.jsonBody, r'''$.data.users''') as List?;
//     list ??= getJsonField(response.jsonBody, r'''$.users''') as List?;
//     if (list == null || list.isEmpty) return;
//
//     var a = 0, i = 0, b = 0;
//     for (final u in list.whereType<Map>()) {
//       final m = Map<String, dynamic>.from(u);
//       final blocked = _parseBool(m['is_blocked']) ||
//           (m['status']?.toString().toLowerCase() == 'blocked') ||
//           (m['account_status']?.toString().toLowerCase() == 'blocked');
//       final active = _parseBool(m['is_active']) || _parseBool(m['active']);
//       if (blocked) {
//         b++;
//       } else if (active) {
//         a++;
//       } else {
//         i++;
//       }
//     }
//     usersActive = a;
//     usersInactive = i;
//     usersBlocked = b;
//   }
//
//   static bool _parseBool(dynamic v) {
//     if (v is bool) return v;
//     if (v is num) return v != 0;
//     if (v is String) {
//       final s = v.toLowerCase();
//       return s == 'true' || s == '1' || s == 'yes';
//     }
//     return false;
//   }
//
//   static int? _parseInt(dynamic v) {
//     if (v == null) return null;
//     if (v is int) return v;
//     if (v is double) return v.round();
//     return int.tryParse(v.toString());
//   }
//
//   static double? _parseDouble(dynamic v) {
//     if (v == null) return null;
//     if (v is double) return v;
//     if (v is int) return v.toDouble();
//     return double.tryParse(v.toString());
//   }
//
//   static String _rideStatus(dynamic r) {
//     final s = r is Map ? r['ride_status'] : null;
//     return s?.toString().toLowerCase() ?? '';
//   }
//
//   static DateTime? _parseRideDate(dynamic r) {
//     if (r is! Map) return null;
//     for (final key in ['created_at', 'ride_date', 'updated_at', 'scheduled_at']) {
//       final raw = r[key];
//       if (raw == null) continue;
//       final s = raw.toString();
//       try {
//         return DateTime.parse(s);
//       } catch (_) {}
//     }
//     return null;
//   }
// }
