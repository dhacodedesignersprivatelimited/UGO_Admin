import '/components/admin_drawer.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dashboard_page_model.dart';
import 'widget/CHART TABS.dart';
import 'widget/METRIC CARD.dart';
import 'widget/QUICK ACTION GRID.dart';
import 'widget/RECENT RIDES TABLE.dart';
import 'widget/TOP DRIVERS.dart';

export 'dashboard_page_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static String routeName = 'DashboardPage';
  static String routePath = '/dashboardPage';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardPageModel _model;

  @override
  void initState() {
    super.initState();
    _model = DashboardPageModel();
    _model.loadAll();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

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

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: FlutterFlowTheme.of(context).primaryText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: theme.primaryBackground,
          appBar: AppBar(
            backgroundColor: theme.primary,
            foregroundColor: Colors.white,
            elevation: 2,
            title: Text(
              'UGO Admin',
              style: theme.headlineMedium.override(
                font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                color: Colors.white,
                fontSize: 22,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () => context.pushNamedAuth(
                  NotificationsWidget.routeName,
                  context.mounted,
                ),
              ),
              const SizedBox(width: 4),
            ],
            centerTitle: false,
          ),
          drawer: buildAdminDrawer(context),
          body: RefreshIndicator(
            color: theme.primary,
            onRefresh: _model.loadAll,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_model.errorMessage != null)
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
                                        _model.errorMessage!,
                                        style: GoogleFonts.inter(
                                          color: theme.error,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: _model.loadAll,
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (!_model.isLoading)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Today: ${_model.ridesCompletedToday} rides completed · ${_model.newUsersToday} new users',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: theme.secondaryText,
                              ),
                            ),
                          ),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.3,
                          children: [
                            MetricCard(
                              title: 'Total rides',
                              value: _fmtInt(_model.totalRides),
                              icon: Icons.directions_car,
                              color: Colors.blue,
                              onTap: () => context.pushNamedAuth(
                                RideManagementWidget.routeName,
                                context.mounted,
                              ),
                            ),
                            MetricCard(
                              title: 'Total users',
                              value: _fmtInt(_model.totalUsers),
                              icon: Icons.people,
                              color: Colors.green,
                              onTap: () => context.pushNamedAuth(
                                AllusersWidget.routeName,
                                context.mounted,
                              ),
                            ),
                            MetricCard(
                              title: 'Total drivers',
                              value: _fmtInt(_model.totalDrivers),
                              icon: Icons.badge,
                              color: Colors.orange,
                              onTap: () => context.pushNamedAuth(
                                DriversWidget.routeName,
                                context.mounted,
                              ),
                            ),
                            MetricCard(
                              title: 'Admin wallet',
                              value: _fmtMoney(_model.adminWallet),
                              icon: Icons.account_balance_wallet,
                              color: Colors.purple,
                              onTap: () => context.pushNamedAuth(
                                WalletManagementWidget.routeName,
                                context.mounted,
                              ),
                            ),
                            MetricCard(
                              title: 'Total earnings',
                              value: _fmtMoney(_model.totalEarnings),
                              icon: Icons.currency_rupee,
                              color: Colors.red,
                              onTap: () => context.pushNamedAuth(
                                EarningsWidget.routeName,
                                context.mounted,
                              ),
                            ),
                            MetricCard(
                              title: 'Online drivers',
                              value: _fmtInt(_model.onlineDrivers),
                              icon: Icons.access_time,
                              color: Colors.cyan,
                              onTap: () => context.pushNamedAuth(
                                LiveDriverMapWidget.routeName,
                                context.mounted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: ChartTabs(model: _model),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: RideTable(
                      rides: _model.recentRides,
                      userById: _model.recentRideUserById,
                      driverById: _model.recentRideDriverById,
                      isLoading: _model.isLoading && _model.recentRides.isEmpty,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: TopDrivers(
                      drivers: _model.topDrivers,
                      isLoading: _model.isLoading && _model.topDrivers.isEmpty,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  sliver: SliverToBoxAdapter(child: _sectionTitle(context, 'Quick actions')),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  sliver: SliverToBoxAdapter(
                    child: QuickActionsGrid(
                      pendingPayoutCount: _model.pendingPayoutCount,
                      onAddDriver: () => context.pushNamedAuth(
                        AddDriverWidget.routeName,
                        context.mounted,
                      ),
                      onAddUser: () => context.pushNamedAuth(
                        AddUserWidget.routeName,
                        context.mounted,
                      ),
                      onReports: () => context.pushNamedAuth(
                        RideManagementWidget.routeName,
                        context.mounted,
                      ),
                      onWithdraw: () => context.pushNamedAuth(
                        DriverPayoutsWidget.routeName,
                        context.mounted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
