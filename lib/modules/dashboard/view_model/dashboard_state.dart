import 'package:equatable/equatable.dart';

import '/core/utils/view_state.dart';

/// Immutable state for [DashboardViewModel].
/// This is the canonical definition; the old cubit/dashboard_state.dart
/// re-exports from here for backward compatibility.
class DashboardState extends Equatable with LoadStateMixin {
  const DashboardState({
    this.status = LoadStatus.initial,
    this.errorMessage,
    this.isBackgroundRefreshing = false,
    this.chartRefreshing = false,
    this.lastUpdatedAt,
    // ── Headline totals ─────────────────────────────────────
    this.totalRides = 0,
    this.totalUsers = 0,
    this.totalDrivers = 0,
    this.onlineDrivers = 0,
    // ── User buckets ─────────────────────────────────────────
    this.usersActive = 0,
    this.usersInactive = 0,
    this.usersBlocked = 0,
    // ── Driver buckets ───────────────────────────────────────
    this.driversActiveAccounts = 0,
    this.driversInactiveAccounts = 0,
    this.driversPendingKyc = 0,
    this.driversBlockedAccounts = 0,
    // ── Today stats ──────────────────────────────────────────
    this.ridesCompletedToday = 0,
    this.newUsersToday = 0,
    // ── Financials ───────────────────────────────────────────
    this.totalEarnings = 0,
    this.adminWallet = 0,
    // ── Chart series ─────────────────────────────────────────
    this.earningsWeekly = const [],
    this.earningsLastWeek = const [],
    this.ridesWeekly = const [],
    this.earningsWeeklyLabels = const [],
    this.ridesWeeklyLabels = const [],
    // ── Ride status pie ──────────────────────────────────────
    this.completedPct = 0,
    this.ongoingPct = 0,
    this.cancelledPct = 0,
    this.statusCompletedCount = 0,
    this.statusOngoingCount = 0,
    this.statusCancelledCount = 0,
    // ── Lists ────────────────────────────────────────────────
    this.recentRides = const [],
    this.topDrivers = const [],
    this.pendingPayouts = const [],
    this.recentRideUserById = const {},
    this.recentRideDriverById = const {},
    // ── Chart controls ───────────────────────────────────────
    this.chartRevision = 0,
    this.chartEarningsPeriod = 'weekly',
    this.chartVehicleId,
    this.chartAdminVehicles = const [],
    this.chartRideBarDays = 7,
    this.chartStatusDays = 0,
  });

  @override
  final LoadStatus status;
  @override
  final String? errorMessage;

  final bool isBackgroundRefreshing;
  final bool chartRefreshing;
  final DateTime? lastUpdatedAt;

  final int totalRides;
  final int totalUsers;
  final int totalDrivers;
  final int onlineDrivers;

  final int usersActive;
  final int usersInactive;
  final int usersBlocked;

  final int driversActiveAccounts;
  final int driversInactiveAccounts;
  final int driversPendingKyc;
  final int driversBlockedAccounts;

  final int ridesCompletedToday;
  final int newUsersToday;

  final double totalEarnings;
  final double adminWallet;

  final List<double> earningsWeekly;
  final List<double> earningsLastWeek;
  final List<double> ridesWeekly;
  final List<String> earningsWeeklyLabels;
  final List<String> ridesWeeklyLabels;

  final double completedPct;
  final double ongoingPct;
  final double cancelledPct;
  final int statusCompletedCount;
  final int statusOngoingCount;
  final int statusCancelledCount;

  final List<dynamic> recentRides;
  final List<dynamic> topDrivers;
  final List<dynamic> pendingPayouts;
  final Map<int, Map<String, dynamic>> recentRideUserById;
  final Map<int, Map<String, dynamic>> recentRideDriverById;

  final int chartRevision;
  final String chartEarningsPeriod;
  final int? chartVehicleId;
  final List<Map<String, dynamic>> chartAdminVehicles;
  final int chartRideBarDays;
  final int chartStatusDays;

  // ── Derived getters ───────────────────────────────────────

  int get pendingPayoutCount {
    var n = 0;
    for (final raw in pendingPayouts) {
      if (raw is! Map) continue;
      final s = (raw['status']?.toString() ?? '').toLowerCase();
      if (s.contains('completed') ||
          s.contains('paid') ||
          s.contains('success')) continue;
      if (s.contains('fail') ||
          s.contains('reject') ||
          s.contains('error')) continue;
      n++;
    }
    return n;
  }

  bool get hasPreviewData =>
      totalRides > 0 ||
      totalUsers > 0 ||
      earningsWeekly.isNotEmpty ||
      recentRides.isNotEmpty;

  String get chartSelectedVehicleLabel {
    if (chartVehicleId == null) return 'All vehicles';
    for (final v in chartAdminVehicles) {
      final id = v['id'];
      final parsed = id is int ? id : int.tryParse(id?.toString() ?? '');
      if (parsed == chartVehicleId) {
        return v['vehicle_name']?.toString() ?? 'Vehicle #$chartVehicleId';
      }
    }
    return 'All vehicles';
  }

  DashboardState copyWith({
    LoadStatus? status,
    String? errorMessage,
    bool clearError = false,
    bool? isBackgroundRefreshing,
    bool? chartRefreshing,
    DateTime? lastUpdatedAt,
    int? totalRides,
    int? totalUsers,
    int? totalDrivers,
    int? onlineDrivers,
    int? usersActive,
    int? usersInactive,
    int? usersBlocked,
    int? driversActiveAccounts,
    int? driversInactiveAccounts,
    int? driversPendingKyc,
    int? driversBlockedAccounts,
    int? ridesCompletedToday,
    int? newUsersToday,
    double? totalEarnings,
    double? adminWallet,
    List<double>? earningsWeekly,
    List<double>? earningsLastWeek,
    List<double>? ridesWeekly,
    List<String>? earningsWeeklyLabels,
    List<String>? ridesWeeklyLabels,
    double? completedPct,
    double? ongoingPct,
    double? cancelledPct,
    int? statusCompletedCount,
    int? statusOngoingCount,
    int? statusCancelledCount,
    List<dynamic>? recentRides,
    List<dynamic>? topDrivers,
    List<dynamic>? pendingPayouts,
    Map<int, Map<String, dynamic>>? recentRideUserById,
    Map<int, Map<String, dynamic>>? recentRideDriverById,
    int? chartRevision,
    String? chartEarningsPeriod,
    int? chartVehicleId,
    bool clearChartVehicleId = false,
    List<Map<String, dynamic>>? chartAdminVehicles,
    int? chartRideBarDays,
    int? chartStatusDays,
  }) {
    return DashboardState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isBackgroundRefreshing:
          isBackgroundRefreshing ?? this.isBackgroundRefreshing,
      chartRefreshing: chartRefreshing ?? this.chartRefreshing,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      totalRides: totalRides ?? this.totalRides,
      totalUsers: totalUsers ?? this.totalUsers,
      totalDrivers: totalDrivers ?? this.totalDrivers,
      onlineDrivers: onlineDrivers ?? this.onlineDrivers,
      usersActive: usersActive ?? this.usersActive,
      usersInactive: usersInactive ?? this.usersInactive,
      usersBlocked: usersBlocked ?? this.usersBlocked,
      driversActiveAccounts:
          driversActiveAccounts ?? this.driversActiveAccounts,
      driversInactiveAccounts:
          driversInactiveAccounts ?? this.driversInactiveAccounts,
      driversPendingKyc: driversPendingKyc ?? this.driversPendingKyc,
      driversBlockedAccounts:
          driversBlockedAccounts ?? this.driversBlockedAccounts,
      ridesCompletedToday: ridesCompletedToday ?? this.ridesCompletedToday,
      newUsersToday: newUsersToday ?? this.newUsersToday,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      adminWallet: adminWallet ?? this.adminWallet,
      earningsWeekly: earningsWeekly ?? this.earningsWeekly,
      earningsLastWeek: earningsLastWeek ?? this.earningsLastWeek,
      ridesWeekly: ridesWeekly ?? this.ridesWeekly,
      earningsWeeklyLabels: earningsWeeklyLabels ?? this.earningsWeeklyLabels,
      ridesWeeklyLabels: ridesWeeklyLabels ?? this.ridesWeeklyLabels,
      completedPct: completedPct ?? this.completedPct,
      ongoingPct: ongoingPct ?? this.ongoingPct,
      cancelledPct: cancelledPct ?? this.cancelledPct,
      statusCompletedCount: statusCompletedCount ?? this.statusCompletedCount,
      statusOngoingCount: statusOngoingCount ?? this.statusOngoingCount,
      statusCancelledCount: statusCancelledCount ?? this.statusCancelledCount,
      recentRides: recentRides ?? this.recentRides,
      topDrivers: topDrivers ?? this.topDrivers,
      pendingPayouts: pendingPayouts ?? this.pendingPayouts,
      recentRideUserById: recentRideUserById ?? this.recentRideUserById,
      recentRideDriverById: recentRideDriverById ?? this.recentRideDriverById,
      chartRevision: chartRevision ?? this.chartRevision,
      chartEarningsPeriod: chartEarningsPeriod ?? this.chartEarningsPeriod,
      chartVehicleId:
          clearChartVehicleId ? null : (chartVehicleId ?? this.chartVehicleId),
      chartAdminVehicles: chartAdminVehicles ?? this.chartAdminVehicles,
      chartRideBarDays: chartRideBarDays ?? this.chartRideBarDays,
      chartStatusDays: chartStatusDays ?? this.chartStatusDays,
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        isBackgroundRefreshing,
        chartRefreshing,
        lastUpdatedAt,
        totalRides,
        totalUsers,
        totalDrivers,
        onlineDrivers,
        usersActive,
        usersInactive,
        usersBlocked,
        driversActiveAccounts,
        driversInactiveAccounts,
        driversPendingKyc,
        driversBlockedAccounts,
        ridesCompletedToday,
        newUsersToday,
        totalEarnings,
        adminWallet,
        earningsWeekly,
        earningsLastWeek,
        ridesWeekly,
        earningsWeeklyLabels,
        ridesWeeklyLabels,
        completedPct,
        ongoingPct,
        cancelledPct,
        statusCompletedCount,
        statusOngoingCount,
        statusCancelledCount,
        recentRides,
        topDrivers,
        pendingPayouts,
        recentRideUserById,
        recentRideDriverById,
        chartRevision,
        chartEarningsPeriod,
        chartVehicleId,
        chartAdminVehicles,
        chartRideBarDays,
        chartStatusDays,
      ];
}
