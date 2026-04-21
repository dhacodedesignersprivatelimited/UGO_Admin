import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../config/routes/nav.dart';
import '/shared/widgets/admin_pop_scope.dart';
import '/shared/widgets/admin_scaffold.dart';
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
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    final idx = widget.initialTabIndex.clamp(0, 3);
    _tabs = TabController(length: 4, vsync: this, initialIndex: idx);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return AdminPopScope(
      child: AdminScaffold(
        title: 'Finance control center',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              color: theme.secondaryBackground,
              child: TabBar(
                controller: _tabs,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Dashboard', icon: Icon(Icons.dashboard_rounded, size: 18)),
                  // Stubs for legacy tabs - or we could directly embed them if migrated
                  Tab(text: 'Ledger', icon: Icon(Icons.receipt_long_rounded, size: 18)),
                  Tab(text: 'Risk', icon: Icon(Icons.shield_rounded, size: 18)),
                  Tab(text: 'Payments', icon: Icon(Icons.account_balance_rounded, size: 18)),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _buildDashboardTab(context),
                  const Center(child: Text('Ledger Explorer (Refer to LedgerExplorerTab)')),
                  const Center(child: Text('Risk Tab')),
                  const Center(child: Text('Payments Recon Tab')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final dashboardAsync = ref.watch(financeDashboardProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(financeDashboardProvider),
      child: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $err', style: TextStyle(color: theme.error)),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.refresh(financeDashboardProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (state) {
          final inr = NumberFormat('#,##0.00', 'en_IN');
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Financial Overview', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
                  IconButton(onPressed: () => ref.refresh(financeDashboardProvider), icon: const Icon(Icons.refresh_rounded)),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _metricCard(theme, 'Total Earnings', '₹${inr.format(state.totalEarnings)}', 'Computed from rides'),
                  _metricCard(theme, 'Pending Payouts', '${state.pendingPayoutsCount}', '₹${inr.format(state.pendingPayoutsAmount)}'),
                ],
              ),
              const SizedBox(height: 20),
              
              Text('Recent Transactions', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              Text('From Payments API', style: theme.bodySmall),
              if (state.recentTransactions.isEmpty)
                Text('No transactions.', style: theme.bodySmall)
              else
                ...state.recentTransactions.map((tx) {
                  return ListTile(
                    dense: true,
                    title: Text('${tx['transaction_type'] ?? tx['type'] ?? 'tx'} · User/Driver', style: GoogleFonts.jetBrainsMono(fontSize: 11)),
                    subtitle: Text('${tx['date'] ?? tx['created_at'] ?? ''} · ${tx['description'] ?? ''}'),
                  );
                }),
                
              const SizedBox(height: 16),
              
              Text('Quick links', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ListTile(
                leading: const Icon(Icons.money_rounded),
                title: const Text('Earnings module'),
                onTap: () => context.pushNamedAuth(EarningsScreen.routeName, context.mounted),
              ),
              ListTile(
                leading: const Icon(Icons.payments_rounded),
                title: const Text('Driver payouts queue'),
                onTap: () => context.pushNamedAuth(DriverPayoutsScreen.routeName, context.mounted),
              ),
              ListTile(
                leading: const Icon(Icons.table_chart_rounded),
                title: const Text('Finance reports & CSV'),
                onTap: () => context.pushNamedAuth(FinanceReportsScreen.routeName, context.mounted),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _metricCard(FlutterFlowTheme theme, String title, String value, String sub) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.bodySmall),
              const SizedBox(height: 4),
              Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
              Text(sub, style: theme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
