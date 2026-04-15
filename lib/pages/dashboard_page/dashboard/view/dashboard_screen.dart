import '../widgets/graphs.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dashboard_tokens.dart';
import '../models/dashboard_model.dart';
import '../widgets/dashboard_carousel_2.dart';
import '../widgets/metric_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/recent_rides_table.dart';
import '../widgets/top_drivers_list.dart';
import '../widgets/withdraw_requests.dart';

/// Scrollable dashboard body (MVVM: driven by [DashboardPageModel]).
class DashboardScreenView extends StatelessWidget {
  const DashboardScreenView({
    super.key,
    required this.model,
    required this.onRefresh,
  });

  final DashboardPageModel model;
  final Future<void> Function() onRefresh;

  String _fmtInt(int n) {
    return formatNumber(
      n,
      formatType: FormatType.decimal,
      decimalType: DecimalType.automatic,
    );
  }

  String _fmtMoney(num n) {
    return formatNumber(
      n,
      formatType: FormatType.compact,
      decimalType: DecimalType.periodDecimal,
      currency: '₹',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return ListenableBuilder(
      listenable: model,
      builder: (context, _) {
        return RefreshIndicator(
          color: DashboardTokens.primaryOrange,
          onRefresh: onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (model.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: theme.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded, color: theme.error),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      model.errorMessage!,
                                      style: GoogleFonts.inter(
                                        color: theme.error,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: onRefresh,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (!model.isLoading)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Today: ${model.ridesCompletedToday} rides completed · ${model.newUsersToday} new users',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: theme.secondaryText,
                            ),
                          ),
                        ),
                      DashboardMetricGrid(
                        children: [
                          DashboardMetricCard(
                            title: 'Total Rides',
                            value: _fmtInt(model.totalRides),
                            backgroundColor: DashboardTokens.metricRidesBg,
                            accentColor: DashboardTokens.metricRidesAccent,
                            icon: Icons.directions_car_rounded,
                            onTap: () => context.pushNamedAuth(
                              RideManagementWidget.routeName,
                              context.mounted,
                            ),
                          ),
                          DashboardMetricCard(
                            title: 'Total Users',
                            value: _fmtInt(model.totalUsers),
                            backgroundColor: DashboardTokens.metricUsersBg,
                            accentColor: DashboardTokens.metricUsersAccent,
                            icon: Icons.people_outline_rounded,
                            onTap: () => context.pushNamedAuth(
                              AllusersWidget.routeName,
                              context.mounted,
                            ),
                          ),
                          DashboardMetricCard(
                            title: 'Total Drivers',
                            value: _fmtInt(model.totalDrivers),
                            backgroundColor: DashboardTokens.metricDriversBg,
                            accentColor: DashboardTokens.metricDriversAccent,
                            icon: Icons.badge_outlined,
                            onTap: () => context.pushNamedAuth(
                              DriversWidget.routeName,
                              context.mounted,
                            ),
                          ),
                          DashboardMetricCard(
                            title: 'Total Earnings',
                            value: _fmtMoney(model.totalEarnings),
                            backgroundColor: DashboardTokens.metricEarningsBg,
                            accentColor: DashboardTokens.metricEarningsAccent,
                            icon: Icons.currency_rupee_rounded,
                            onTap: () => context.pushNamedAuth(
                              EarningsWidget.routeName,
                              context.mounted,
                            ),
                          ),
                          DashboardMetricCard(
                            title: 'Admin Wallet',
                            value: _fmtMoney(model.adminWallet),
                            backgroundColor: DashboardTokens.metricWalletBg,
                            accentColor: DashboardTokens.metricWalletAccent,
                            icon: Icons.account_balance_wallet_outlined,
                            onTap: () => context.pushNamedAuth(
                              WalletManagementWidget.routeName,
                              context.mounted,
                            ),
                          ),
                          DashboardMetricCard(
                            title: 'Online Drivers',
                            value: _fmtInt(model.onlineDrivers),
                            backgroundColor: DashboardTokens.metricOnlineBg,
                            accentColor: DashboardTokens.metricOnlineAccent,
                            icon: Icons.podcasts_rounded,
                            onTap: () => context.pushNamedAuth(
                              LiveDriverMapWidget.routeName,
                              context.mounted,
                            ),
                          ),
                        ],
                      )
                          .animate()
                          .fadeIn(duration: 400.ms, curve: Curves.easeOutCubic),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: DashboardCarousel1(model: model)
                      .animate()
                      .fadeIn(delay: 80.ms, duration: 450.ms),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: DashboardCarousel2(
                    model: model,
                    onUserTap: () => context.pushNamedAuth(
                      AllusersWidget.routeName,
                      context.mounted,
                    ),
                    onDriverTap: () => context.pushNamedAuth(
                      DriversWidget.routeName,
                      context.mounted,
                    ),
                  ).animate().fadeIn(delay: 120.ms, duration: 450.ms),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: RecentRidesTable(
                    rides: model.recentRides,
                    userById: model.recentRideUserById,
                    driverById: model.recentRideDriverById,
                    isLoading: model.isLoading && model.recentRides.isEmpty,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: WithdrawRequests(
                    payouts: model.pendingPayouts,
                    isLoading: model.isLoading && model.pendingPayouts.isEmpty,
                    maxRows: 4,
                    onViewAll: () => context.pushNamedAuth(
                      DriverPayoutsWidget.routeName,
                      context.mounted,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: TopDriversList(
                    drivers: model.topDrivers,
                    isLoading: model.isLoading && model.topDrivers.isEmpty,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Quick Actions',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: theme.primaryText,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverToBoxAdapter(
                  child: QuickActions(
                    actions: [
                      QuickActionData(
                        label: 'Add Driver',
                        icon: Icons.badge_outlined,
                        background: const Color(0xFFFFE8D6),
                        iconColor: DashboardTokens.primaryOrange,
                        onTap: () => context.pushNamedAuth(
                          AddDriverWidget.routeName,
                          context.mounted,
                        ),
                      ),
                      QuickActionData(
                        label: 'Add User',
                        icon: Icons.person_add_alt_1_outlined,
                        background: const Color(0xFFE8F5E9),
                        iconColor: const Color(0xFF2E7D32),
                        onTap: () => context.pushNamedAuth(
                          AddUserWidget.routeName,
                          context.mounted,
                        ),
                      ),
                      QuickActionData(
                        label: 'Add Vehicle',
                        icon: Icons.directions_car_outlined,
                        background: const Color(0xFFE3F2FD),
                        iconColor: const Color(0xFF1565C0),
                        onTap: () => context.pushNamedAuth(
                          AddVehicleWidget.routeName,
                          context.mounted,
                        ),
                      ),
                      QuickActionData(
                        label: 'Add City',
                        icon: Icons.location_city_outlined,
                        background: const Color(0xFFF3E5F5),
                        iconColor: const Color(0xFF6A1B9A),
                        onTap: () => context.pushNamedAuth(
                          ZoneManagementWidget.routeName,
                          context.mounted,
                        ),
                      ),
                      QuickActionData(
                        label: 'Pay Outs',
                        icon: Icons.payments_outlined,
                        background: const Color(0xFFFFEBEE),
                        iconColor: const Color(0xFFC62828),
                        onTap: () => context.pushNamedAuth(
                          DriverPayoutsWidget.routeName,
                          context.mounted,
                        ),
                      ),
                      QuickActionData(
                        label: 'Add Incentives',
                        icon: Icons.emoji_events_outlined,
                        background: const Color(0xFFFFF8E1),
                        iconColor: const Color(0xFFF9A825),
                        onTap: () => context.pushNamedAuth(
                          AddIncentiveWidget.routeName,
                          context.mounted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
            ],
          ),
        );
      },
    );
  }
}
