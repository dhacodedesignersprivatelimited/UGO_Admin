import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/components/admin_scaffold.dart';
import 'wallet_management_model.dart';
export 'wallet_management_model.dart';

class WalletManagementWidget extends StatefulWidget {
  const WalletManagementWidget({super.key});

  static String routeName = 'WalletManagement';
  static String routePath = '/wallet-management';

  @override
  State<WalletManagementWidget> createState() => _WalletManagementWidgetState();
}

class _WalletManagementWidgetState extends State<WalletManagementWidget> {
  late WalletManagementModel _model;
  int _selectedTab = 0;
  dynamic _companyWallet;
  List<dynamic> _wallets = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WalletManagementModel());
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final companyResp = await CompanyWalletCall.call(token: currentAuthenticationToken);
      final walletsResp = await GetWalletsCall.call(token: currentAuthenticationToken);
      setState(() {
        _companyWallet = companyResp.succeeded ? companyResp.jsonBody : null;
        _wallets = GetWalletsCall.data(walletsResp.jsonBody)?.toList() ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final data = _companyWallet != null ? getJsonField(_companyWallet, r'''$.data''') : null;
    final riderBal = getJsonField(data ?? _companyWallet, r'''$.rider_total''') ?? getJsonField(_companyWallet, r'''$.balance''') ?? 0;
    final driverBal = getJsonField(data ?? _companyWallet, r'''$.driver_total''') ?? getJsonField(data ?? _companyWallet, r'''$.total''') ?? 0;

    return AdminScaffold(
      title: 'Wallet Management',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _tabCard('Riders', _parseAmount(riderBal), 0, theme),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _tabCard('Drivers', _parseAmount(driverBal), 1, theme),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        Text('Wallets', style: theme.titleMedium.override(font: GoogleFonts.inter())),
                        const SizedBox(height: 12),
                        if (_wallets.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text('No wallet data', style: theme.bodyMedium),
                            ),
                          )
                        else
                          ...List.generate(_wallets.length.clamp(0, 10), (i) {
                            final w = _wallets[i];
                            final bal = getJsonField(w, r'''$.balance''') ?? getJsonField(w, r'''$.total''');
                            return _transactionItem(i, theme, bal: bal, label: 'Wallet #${i + 1}');
                          }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  int _parseAmount(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  Widget _tabCard(String label, int amount, int index, FlutterFlowTheme theme) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => safeSetState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [theme.primary, theme.tertiary]
                : [theme.secondaryBackground, theme.primary.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.primary.withOpacity(isSelected ? 0.3 : 0.1),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isSelected ? theme.primary : theme.alternate,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.labelMedium.override(
              font: GoogleFonts.inter(),
              color: isSelected ? theme.primaryBackground : theme.secondaryText,
            )),
            const SizedBox(height: 8),
            Text('₹$amount', style: theme.headlineSmall.override(
              font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
              color: isSelected ? theme.primaryBackground : theme.primary,
            )),
          ],
        ),
      ),
    );
  }

  Widget _transactionItem(int i, FlutterFlowTheme theme, {dynamic bal, String label = 'Wallet'}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.secondaryBackground, theme.primary.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: theme.primary.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.primary.withOpacity(0.2),
            child: Icon(Icons.account_balance_wallet, color: theme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.titleSmall.override(font: GoogleFonts.inter())),
                Text('₹${bal ?? 0}', style: theme.bodySmall.override(font: GoogleFonts.inter(), color: theme.primary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Text('₹${(i + 1) * 50}', style: theme.titleMedium.override(font: GoogleFonts.inter(), color: theme.primary)),
        ],
      ),
    );
  }
}
