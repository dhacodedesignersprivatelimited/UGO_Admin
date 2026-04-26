import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../config/routes/nav.dart';
import '/shared/widgets/admin_pop_scope.dart';
import '/shared/widgets/admin_drawer.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/index.dart';

import '../viewmodels/finance_dashboard_viewmodel.dart';
import 'earnings_screen.dart';
import 'driver_payouts_screen.dart';
import 'finance_reports_screen.dart';

class FinanceControlHubScreen extends ConsumerStatefulWidget {
  const FinanceControlHubScreen({
    super.key,
    this.initialTabIndex = 0,
    this.initialRideId,
    this.initialUserId,
    this.initialDriverId,
  });

  final int initialTabIndex;
  final int? initialRideId;
  final int? initialUserId;
  final int? initialDriverId;

  static String routeName = 'FinanceControlHub';
  static String routePath = '/finance-control';

  @override
  ConsumerState<FinanceControlHubScreen> createState() => _FinanceControlHubScreenState();
}

class _FinanceControlHubScreenState extends ConsumerState<FinanceControlHubScreen> with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final dashboardAsync = ref.watch(financeDashboardProvider);

    return AdminPopScope(
      child: Scaffold(
        key: scaffoldKey,
        drawer: buildAdminDrawer(context),
        backgroundColor: theme.primaryBackground,
        appBar: AppBar(
          backgroundColor: theme.primary,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
          centerTitle: true,
          title: Text(
            'Finance control center',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                  color: Colors.white,
                  fontSize: 22,
                ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => ref.refresh(financeDashboardProvider),
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async => ref.refresh(financeDashboardProvider),
          color: theme.primary,
          child: dashboardAsync.when(
            loading: () => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 180),
                Center(child: CircularProgressIndicator()),
              ],
            ),
            error: (err, stack) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [
                Icon(Icons.error_outline, size: 48, color: theme.error),
                const SizedBox(height: 16),
                Text(
                  'Failed to load finance dashboard',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '$err',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodySmall,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.refresh(financeDashboardProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
            data: (state) {
              final inr = NumberFormat('#,##0.00', 'en_IN');
              final txCount = state.recentTransactions.length;

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                itemCount: txCount + 3,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(
                        '$txCount recent transaction${txCount == 1 ? '' : 's'}',
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                              font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                      ),
                    );
                  }

                  if (index == 1) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Financial Overview',
                              style: FlutterFlowTheme.of(context).titleMedium.override(
                                    font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _metricTile(
                                  theme,
                                  'Total Earnings',
                                  '₹${inr.format(state.totalEarnings)}',
                                  'Computed from rides',
                                  Icons.show_chart_rounded,
                                ),
                                _metricTile(
                                  theme,
                                  'Pending Payouts',
                                  '${state.pendingPayoutsCount}',
                                  '₹${inr.format(state.pendingPayoutsAmount)}',
                                  Icons.account_balance_wallet_rounded,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (index == txCount + 2) {
                    return Card(
                      margin: const EdgeInsets.only(top: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick Links',
                              style: FlutterFlowTheme.of(context).labelLarge.override(
                                    font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                  ),
                            ),
                            const SizedBox(height: 8),
                            _linkTile(
                              context,
                              icon: Icons.money_rounded,
                              text: 'Earnings module',
                              onTap: () => context.pushNamedAuth(EarningsScreen.routeName, context.mounted),
                            ),
                            _linkTile(
                              context,
                              icon: Icons.payments_rounded,
                              text: 'Driver payouts queue',
                              onTap: () => context.pushNamedAuth(DriverPayoutsScreen.routeName, context.mounted),
                            ),
                            _linkTile(
                              context,
                              icon: Icons.table_chart_rounded,
                              text: 'Finance reports & CSV',
                              onTap: () => context.pushNamedAuth(FinanceReportsScreen.routeName, context.mounted),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final tx = state.recentTransactions[index - 2];
                  final type = (tx['transaction_type'] ?? tx['type'] ?? 'Transaction').toString();
                  final date = (tx['date'] ?? tx['created_at'] ?? '').toString();
                  final desc = (tx['description'] ?? '').toString();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: theme.primary.withValues(alpha: 0.12),
                                child: Icon(Icons.receipt_long_rounded, color: theme.primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      type,
                                      style: FlutterFlowTheme.of(context).titleSmall.override(
                                            font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      date,
                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                            color: FlutterFlowTheme.of(context).secondaryText,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'TX',
                                  style: FlutterFlowTheme.of(context).labelSmall.override(
                                        font: GoogleFonts.inter(),
                                        color: theme.primary,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          if (desc.isNotEmpty) ...[
                            const Divider(height: 22),
                            Text(
                              desc,
                              style: FlutterFlowTheme.of(context).bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }


  Widget _metricTile(
    FlutterFlowTheme theme,
    String title,
    String value,
    String sub,
    IconData icon,
  ) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.primary),
          const SizedBox(height: 6),
          Text(title, style: theme.bodySmall),
          const SizedBox(height: 2),
          Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
          Text(sub, style: theme.bodySmall),
        ],
      ),
    );
  }

  Widget _linkTile(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: FlutterFlowTheme.of(context).primary),
            const SizedBox(width: 10),
            Expanded(child: Text(text)),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
          ],
        ),
      ),
    );
  }

}
