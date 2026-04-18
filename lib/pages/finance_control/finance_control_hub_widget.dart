import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/admin_pop_scope.dart';
import '/components/admin_scaffold.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'widgets/finance_ops_overview_tab.dart';
import 'widgets/finance_payments_recon_tab.dart';
import 'widgets/finance_risk_tab.dart';
import 'widgets/ledger_explorer_tab.dart';

/// Finance control center with optional drill-through query params:
/// `tab` (0–3), `rideId`, `userId`, `driverId` for ledger pre-fill.
class FinanceControlHubWidget extends StatefulWidget {
  const FinanceControlHubWidget({
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
  State<FinanceControlHubWidget> createState() => _FinanceControlHubWidgetState();
}

class _FinanceControlHubWidgetState extends State<FinanceControlHubWidget> with SingleTickerProviderStateMixin {
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
                  Tab(text: 'Operations', icon: Icon(Icons.dashboard_rounded, size: 18)),
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
                  const FinanceOpsOverviewTab(),
                  LedgerExplorerTab(
                    initialRideId: widget.initialRideId,
                    initialUserId: widget.initialUserId,
                    initialDriverId: widget.initialDriverId,
                  ),
                  const FinanceRiskTab(),
                  const FinancePaymentsReconTab(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                'Drill-through: append ?tab=1&rideId= or &userId= or &driverId= to this route.',
                style: GoogleFonts.inter(fontSize: 11, color: theme.secondaryText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
