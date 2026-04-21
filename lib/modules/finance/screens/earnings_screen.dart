import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '/config/theme/flutter_flow_theme.dart';
import '/shared/widgets/admin_drawer.dart';
import '/shared/widgets/admin_pop_scope.dart';
import '../viewmodels/earnings_viewmodel.dart';
import '../viewmodels/finance_dashboard_viewmodel.dart';

class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  static String routeName = 'Earnings';
  static String routePath = '/earnings';

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> {
  static final _inr = NumberFormat('#,##0.00', 'en_IN');

  double _num(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  Widget _liveFinanceHeader(FlutterFlowTheme theme, AsyncValue<Map<String, dynamic>> earningsAsync) {
    return earningsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: LinearProgressIndicator(minHeight: 2),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(error.toString(), style: TextStyle(color: theme.error)),
      ),
      data: (m) {
        final pending = m['pending_payouts'];
        final pendAmt = pending is Map ? _num(pending['amount_inr']) : 0.0;
        final pendCnt = pending is Map ? (pending['count'] ?? 0) : 0;
        final ledger = m['platform_ledger_breakdown'];
        final commission = ledger is Map ? _num(ledger['total_commission_ledger_inr']) : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.alternate),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live finance (ledger)',
                  style: theme.titleMedium.override(font: GoogleFonts.inter()),
                ),
                const SizedBox(height: 8),
                Text(
                  'Company ledger: ₹${_inr.format(_num(m['company_ledger_balance_inr']))}',
                  style: theme.headlineSmall.override(
                    font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Driver wallets (liability): ₹${_inr.format(_num(m['driver_wallet_liability_inr']))}',
                  style: theme.bodyMedium,
                ),
                Text(
                  'Rider wallets (liability): ₹${_inr.format(_num(m['rider_wallet_liability_inr']))}',
                  style: theme.bodyMedium,
                ),
                Text(
                  'Pending payouts ($pendCnt): ₹${_inr.format(pendAmt)}',
                  style: theme.bodyMedium,
                ),
                Text(
                  'Platform commission (ledger window): ₹${_inr.format(commission)}',
                  style: theme.bodySmall.override(color: theme.secondaryText),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final earningsAsync = ref.watch(earningsProvider);

    return AdminPopScope(
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          drawer: buildAdminDrawer(context),
          appBar: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primary,
            automaticallyImplyLeading: true,
            title: Text(
              'Earnings',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    font: GoogleFonts.interTight(
                      fontWeight: FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                      color: Colors.white,
                      fontSize: 22.0,
                    ),
                  ),
            ),
            centerTitle: true,
            elevation: 2.0,
          ),
          body: SafeArea(
            top: true,
            child: RefreshIndicator(
              onRefresh: () async => ref.refresh(earningsProvider),
              child: ListView(
                padding: const EdgeInsets.only(top: 40.0),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _liveFinanceHeader(FlutterFlowTheme.of(context), earningsAsync),
                  ),
                  _buildMockCharts(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMockCharts(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Earnings by Period',
            style: theme.headlineSmall.override(
              font: GoogleFonts.interTight(
                fontWeight: theme.headlineSmall.fontWeight,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Wrap placeholder sections visually as they were in original widget
          // Actual backend data rendering for dates will be substituted here.
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('Chart visualizations currently pending connection to API period mappings.'),
          )
        ],
      ),
    );
  }
}
