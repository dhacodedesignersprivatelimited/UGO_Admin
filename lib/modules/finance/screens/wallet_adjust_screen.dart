import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';
import '/shared/widgets/admin_pop_scope.dart';
import '/shared/widgets/admin_drawer.dart';
import '/config/theme/flutter_flow_theme.dart';

class WalletAdjustScreen extends ConsumerStatefulWidget {
  const WalletAdjustScreen({super.key});

  static String routeName = 'WalletAdjustScreen';
  static String routePath = '/wallet-adjust';

  @override
  ConsumerState<WalletAdjustScreen> createState() => _WalletAdjustScreenState();
}

class _WalletAdjustScreenState extends ConsumerState<WalletAdjustScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  static final _inr = NumberFormat('#,##0.00', 'en_IN');

  // Wallets state
  List<Map<String, dynamic>> _wallets = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  String? _loadError;

  // Selection
  Map<String, dynamic>? _selected;

  // Adjust state
  String _adjustType = 'credit'; // 'credit' | 'debit'
  bool _submitting = false;
  String? _submitResult;
  bool _submitSuccess = false;

  // Recent adjustments in this session
  final List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadWallets();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _reasonCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadWallets() async {
    setState(() { _loading = true; _loadError = null; });
    try {
      final res = await GetWalletsCall.call(token: currentAuthenticationToken);
      if (!res.succeeded) throw Exception('Failed to load wallets (${res.statusCode})');
      final list = (GetWalletsCall.walletsList(res.jsonBody) ?? [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      setState(() {
        _wallets = list;
        _filtered = list;
        _loading = false;
      });
    } catch (e) {
      setState(() { _loading = false; _loadError = e.toString(); });
    }
  }

  void _onSearch(String q) {
    final lower = q.toLowerCase().trim();
    setState(() {
      _filtered = lower.isEmpty
          ? _wallets
          : _wallets.where((w) {
              final uid = w['user_id']?.toString() ?? '';
              final did = w['driver_id']?.toString() ?? '';
              final aid = w['admin_id']?.toString() ?? '';
              return uid.contains(lower) || did.contains(lower) || aid.contains(lower);
            }).toList();
    });
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  String _walletLabel(Map<String, dynamic> w) {
    if (w['user_id'] != null) return 'User #${w['user_id']}';
    if (w['driver_id'] != null) return 'Driver #${w['driver_id']}';
    if (w['admin_id'] != null) return 'Admin #${w['admin_id']}';
    return 'Wallet #${w['id']}';
  }

  String _walletSubLabel(Map<String, dynamic> w) {
    if (w['user_id'] != null) return 'User wallet';
    if (w['driver_id'] != null) return 'Driver wallet';
    if (w['admin_id'] != null) return 'Admin wallet';
    return '';
  }

  IconData _walletIcon(Map<String, dynamic> w) {
    if (w['driver_id'] != null) return Icons.local_taxi_rounded;
    if (w['admin_id'] != null) return Icons.admin_panel_settings_rounded;
    return Icons.person_rounded;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a wallet first.')));
      return;
    }

    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    final reason = _reasonCtrl.text.trim();
    final finalAmount = _adjustType == 'credit' ? amount.abs() : -amount.abs();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Adjustment'),
        content: Text(
          'Apply ${_adjustType == 'credit' ? '+' : '-'}₹${_inr.format(amount)} '
          'to ${_walletLabel(_selected!)}?\n\nReason: $reason',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B35)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() { _submitting = true; _submitResult = null; });

    try {
      final idempotencyKey = 'adj_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(99999)}';
      final res = await PostAdminWalletAdjustCall.call(
        token: currentAuthenticationToken,
        userId: _selected!['user_id'] as int?,
        driverId: _selected!['driver_id'] as int?,
        amount: finalAmount,
        reason: reason,
        idempotencyKey: idempotencyKey,
      );

      if (!res.succeeded) {
        final msg = res.jsonBody is Map
            ? (res.jsonBody['message']?.toString() ?? 'Failed')
            : 'Failed (${res.statusCode})';
        throw Exception(msg);
      }

      _history.insert(0, {
        'wallet': _walletLabel(_selected!),
        'type': _adjustType,
        'amount': amount,
        'reason': reason,
        'time': DateTime.now().toLocal().toIso8601String(),
      });

      setState(() {
        _submitting = false;
        _submitSuccess = true;
        _submitResult = 'Adjustment applied successfully!';
        _amountCtrl.clear();
        _reasonCtrl.clear();
        _selected = null;
      });
      _loadWallets(); // refresh balances
    } catch (e) {
      setState(() {
        _submitting = false;
        _submitSuccess = false;
        _submitResult = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final creditColor = const Color(0xFF2E7D32);
    final debitColor = const Color(0xFFC62828);

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
            'Wallet Adjust',
            style: theme.headlineMedium.override(
              font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
              color: Colors.white,
              fontSize: 22,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loading ? null : _loadWallets,
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: _loading
            ? Center(child: CircularProgressIndicator(color: theme.primary))
            : _loadError != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline_rounded, size: 48, color: theme.error),
                        const SizedBox(height: 12),
                        Text(_loadError!, style: TextStyle(color: theme.error)),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _loadWallets,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primary, foregroundColor: Colors.white),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      // ── Wallet selector ────────────────────────────
                      Text('1. Select Wallet', style: theme.titleMedium.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                      )),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _searchCtrl,
                        onChanged: _onSearch,
                        decoration: InputDecoration(
                          hintText: 'Search by user/driver/admin ID...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    _onSearch('');
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: theme.secondaryBackground,
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 220,
                        decoration: BoxDecoration(
                          color: theme.secondaryBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.alternate),
                        ),
                        child: _filtered.isEmpty
                            ? Center(child: Text('No wallets found', style: theme.bodySmall))
                            : ListView.separated(
                                padding: const EdgeInsets.all(6),
                                itemCount: _filtered.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (ctx, i) {
                                  final w = _filtered[i];
                                  final isSelected = _selected == w;
                                  final bal = _toDouble(w['wallet_balance']);
                                  return ListTile(
                                    dense: true,
                                    selected: isSelected,
                                    selectedTileColor: theme.primary.withOpacity(0.08),
                                    leading: Icon(_walletIcon(w),
                                        size: 20,
                                        color: isSelected ? theme.primary : theme.secondaryText),
                                    title: Text(_walletLabel(w),
                                        style: GoogleFonts.inter(
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                                            fontSize: 13)),
                                    subtitle: Text(
                                        '${_walletSubLabel(w)}  ·  Bal: ₹${_inr.format(bal)}',
                                        style: theme.labelSmall.override(fontSize: 11)),
                                    trailing: isSelected
                                        ? Icon(Icons.check_circle_rounded, color: theme.primary, size: 18)
                                        : null,
                                    onTap: () => setState(() {
                                      _selected = isSelected ? null : w;
                                      _submitResult = null;
                                    }),
                                  );
                                },
                              ),
                      ),

                      // ── Selected wallet summary ───────────────────
                      if (_selected != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.primary.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: theme.primary.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(_walletIcon(_selected!), color: theme.primary),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_walletLabel(_selected!),
                                      style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14)),
                                  Text(
                                    'Balance: ₹${_inr.format(_toDouble(_selected!['wallet_balance']))}  ·  '
                                    'Cashback: ₹${_inr.format(_toDouble(_selected!['cashback_balance']))}',
                                    style: theme.bodySmall.override(color: theme.secondaryText),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // ── Adjust form ───────────────────────────────
                      Text('2. Adjustment Details', style: theme.titleMedium.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                      )),
                      const SizedBox(height: 12),

                      // Type toggle
                      Row(
                        children: [
                          Expanded(
                            child: _TypeToggle(
                              label: 'Credit (+)',
                              icon: Icons.add_circle_rounded,
                              selected: _adjustType == 'credit',
                              color: creditColor,
                              onTap: () => setState(() { _adjustType = 'credit'; _submitResult = null; }),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _TypeToggle(
                              label: 'Debit (−)',
                              icon: Icons.remove_circle_rounded,
                              selected: _adjustType == 'debit',
                              color: debitColor,
                              onTap: () => setState(() { _adjustType = 'debit'; _submitResult = null; }),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _amountCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                              decoration: InputDecoration(
                                labelText: 'Amount (₹)',
                                prefixIcon: const Icon(Icons.currency_rupee_rounded),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                filled: true,
                                fillColor: theme.secondaryBackground,
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Enter an amount';
                                final n = double.tryParse(v.trim());
                                if (n == null || n <= 0) return 'Enter a valid positive amount';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _reasonCtrl,
                              maxLines: 2,
                              decoration: InputDecoration(
                                labelText: 'Reason / Note',
                                prefixIcon: const Icon(Icons.notes_rounded),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                filled: true,
                                fillColor: theme.secondaryBackground,
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Provide a reason';
                                if (v.trim().length < 5) return 'Reason too short';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Submit result
                      if (_submitResult != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _submitSuccess
                                ? creditColor.withOpacity(0.1)
                                : debitColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _submitSuccess
                                  ? creditColor.withOpacity(0.4)
                                  : debitColor.withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _submitSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
                                color: _submitSuccess ? creditColor : debitColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _submitResult!,
                                  style: TextStyle(
                                    color: _submitSuccess ? creditColor : debitColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _submitting || _selected == null ? null : _submit,
                          icon: _submitting
                              ? const SizedBox(width: 18, height: 18,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Icon(_adjustType == 'credit'
                                  ? Icons.add_circle_rounded
                                  : Icons.remove_circle_rounded),
                          label: Text(_submitting ? 'Processing...' : 'Apply Adjustment'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _adjustType == 'credit' ? creditColor : debitColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                        ),
                      ),

                      // ── Session history ───────────────────────────
                      if (_history.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        Text('This session', style: theme.titleSmall.override(
                          font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          color: theme.secondaryText,
                        )),
                        const SizedBox(height: 8),
                        ...(_history.take(5).map((h) {
                          final isCredit = h['type'] == 'credit';
                          final col = isCredit ? creditColor : debitColor;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.secondaryBackground,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: theme.alternate),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                  color: col, size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${h['wallet']}  ·  ${isCredit ? '+' : '-'}₹${_inr.format(h['amount'])}',
                                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                                      Text(h['reason']?.toString() ?? '',
                                          style: theme.bodySmall.override(color: theme.secondaryText),
                                          maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                Text(
                                  (h['time']?.toString() ?? '').substring(11, 16),
                                  style: theme.labelSmall.override(color: theme.secondaryText, fontSize: 10),
                                ),
                              ],
                            ),
                          );
                        })),
                      ],
                    ],
                  ),
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : Colors.white,
          border: Border.all(color: selected ? color : const Color(0xFFE0E0E0), width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? color : Colors.grey, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                color: selected ? color : Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

