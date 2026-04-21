import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';
import '/shared/widgets/admin_scaffold.dart';
import '/modules/driver_management/view/driver_details/driver_details_widget.dart';
import '/modules/finance_management/view/finance_audit/finance_audit_timeline_widget.dart';
import '/modules/finance_management/view/finance_control/finance_control_hub_widget.dart';
import '/index.dart';
import '../viewmodels/payouts_viewmodel.dart';
import 'finance_control_hub_screen.dart';

class DriverPayoutsScreen extends ConsumerStatefulWidget {
  const DriverPayoutsScreen({super.key});

  static String routeName = 'DriverPayouts';
  static String routePath = '/driver-payouts';

  @override
  ConsumerState<DriverPayoutsScreen> createState() => _DriverPayoutsScreenState();
}

class _DriverPayoutsScreenState extends ConsumerState<DriverPayoutsScreen> {
  int? _payoutId(Map<String, dynamic> m) => castToType<int>(m['id']) ?? castToType<int>(m['payout_id']);

  bool _canAdminAct(Map<String, dynamic> m) {
    final s = _statusKey(m);
    return s.contains('pending') || s.contains('manual') || s.contains('approved');
  }

  Future<void> _markPaidRow(Map<String, dynamic> m) async {
    final id = _payoutId(m);
    if (id == null) return;
    
    final refCtrl = TextEditingController();
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Mark payout #$id paid'),
          content: TextField(
            controller: refCtrl,
            decoration: const InputDecoration(
              labelText: 'Payment reference (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirm')),
          ],
        ),
      );
      if (ok != true || !mounted) return;
      
      final reference = refCtrl.text.trim().isEmpty ? null : refCtrl.text.trim();
      await ref.read(payoutsProvider.notifier).markPaid(id, reference);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked paid')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      refCtrl.dispose();
    }
  }

  Future<void> _rejectRow(Map<String, dynamic> m) async {
    final id = _payoutId(m);
    if (id == null) return;
    
    final reasonCtrl = TextEditingController();
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Reject payout #$id'),
          content: TextField(
            controller: reasonCtrl,
            decoration: const InputDecoration(
              labelText: 'Reason (min 3 chars)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reject')),
          ],
        ),
      );
      if (ok != true || !mounted) return;
      
      final reason = reasonCtrl.text.trim();
      if (reason.length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reason too short')));
        return;
      }
      
      await ref.read(payoutsProvider.notifier).reject(id, reason);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rejected')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      reasonCtrl.dispose();
    }
  }

  double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString().trim());
  }

  String _fmtMoney(double? n) {
    if (n == null) return '—';
    return '₹${NumberFormat('#,##0.00', 'en_IN').format(n)}';
  }

  double? _payoutAmount(Map<String, dynamic> m) {
    for (final k in ['amount_raw', 'amount', 'requested_amount', 'withdraw_amount', 'net_amount', 'payout_amount', 'total_amount', 'gross_amount']) {
      final d = _parseDouble(m[k]);
      if (d != null) return d;
    }
    return null;
  }

  String _payoutTitle(Map<String, dynamic> m) {
    final drv = m['driver'];
    if (drv is Map) {
      final dn = drv['name']?.toString().trim();
      if (dn != null && dn.isNotEmpty && dn != 'null') {
        final wr = m['wr_id']?.toString().trim();
        if (wr != null && wr.isNotEmpty && wr != 'null') return '$wr · $dn';
        return dn;
      }
    }
    final fn = m['driver_first_name']?.toString().trim() ?? '';
    final ln = m['driver_last_name']?.toString().trim() ?? '';
    final n = '$fn $ln'.trim();
    if (n.isNotEmpty) return n;
    final name = m['driver_name']?.toString().trim() ?? m['name']?.toString().trim();
    if (name != null && name.isNotEmpty && name != 'null') {
      final wr = m['wr_id']?.toString().trim();
      if (wr != null && wr.isNotEmpty && wr != 'null') return '$wr · $name';
      return name;
    }
    final id = m['driver_id'] ?? m['user_id'];
    return id != null ? 'Payout #$id' : 'Payout';
  }

  String _statusKey(Map<String, dynamic> m) => (m['status']?.toString() ?? '').toLowerCase();

  String _statusLabel(String s) {
    if (s.contains('complete') || s.contains('paid') || s.contains('success')) return 'Approved';
    if (s.contains('fail') || s.contains('reject') || s.contains('error')) return 'Failed';
    return 'Pending';
  }

  (Color fg, Color bg) _statusColors(String s) {
    final label = _statusLabel(s);
    if (label == 'Approved') return (const Color(0xFF2E7D32), const Color(0xFFE8F5E9));
    if (label == 'Failed') return (const Color(0xFFC62828), const Color(0xFFFFEBEE));
    return (const Color(0xFFEF6C00), const Color(0xFFFFF3E0));
  }

  String _paymentMethod(Map<String, dynamic> m) {
    final explicit = m['payout_method'] ?? m['payment_method'] ?? m['method'] ?? m['channel'];
    if (explicit != null) {
      final t = explicit.toString().toLowerCase();
      if (t.contains('upi')) return 'UPI';
      if (t.contains('bank')) return 'Bank';
      if (t.contains('wallet')) return 'Wallet';
      return explicit.toString();
    }
    final upi = m['upi_id']?.toString().trim() ?? '';
    if (upi.isNotEmpty && upi != 'null') return 'UPI';
    for (final k in ['bank_account_number', 'account_number', 'ifsc']) {
      final v = m[k]?.toString().trim() ?? '';
      if (v.isNotEmpty && v != 'null') return 'Bank';
    }
    return '—';
  }

  int? _nestedDriverId(Map<String, dynamic> m) {
    final drv = m['driver'];
    if (drv is Map) return castToType<int>(drv['id']) ?? int.tryParse(drv['id']?.toString() ?? '');
    return null;
  }

  int? _driverId(Map<String, dynamic> m) => castToType<int>(m['driver_id']) ?? _nestedDriverId(m) ?? int.tryParse(m['driver_id']?.toString() ?? '');

  Future<void> _exportSummary(List<Map<String, dynamic>> payouts) async {
    if (payouts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nothing to export')));
      return;
    }
    final buf = StringBuffer();
    buf.writeln('Driver payouts (${payouts.length} rows)');
    for (var i = 0; i < payouts.length; i++) {
      final m = payouts[i];
      buf.writeln('${i + 1}. ${_payoutTitle(m)} | ${_fmtMoney(_payoutAmount(m))} | ${_statusKey(m)} | id:${m['id']}');
    }
    await Clipboard.setData(ClipboardData(text: buf.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Summary copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final payoutsAsync = ref.watch(payoutsProvider);

    return AdminScaffold(
      title: 'Driver payouts',
      actions: [
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () => ref.read(payoutsProvider.notifier).refresh(),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          payoutsAsync.when(
            data: (state) {
              final payouts = state.payouts;
              final totalListed = payouts.fold(0.0, (sum, m) => sum + (_payoutAmount(m) ?? 0));

              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [theme.primary.withValues(alpha: 0.12), theme.primary.withValues(alpha: 0.04)]),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.primary.withValues(alpha: 0.28)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Listed total (${payouts.length} rows)',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: theme.secondaryText),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _fmtMoney(totalListed),
                              style: GoogleFonts.interTight(fontWeight: FontWeight.w800, fontSize: 22, color: theme.primary),
                            ),
                          ],
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () => _exportSummary(payouts),
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: const Text('Copy list'),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, stack) => const SizedBox(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip(theme, 'Pending transfer', PayoutFilter.pendingManual),
                  _filterChip(theme, 'All (no filter)', PayoutFilter.all),
                  _filterChip(theme, 'Pending', PayoutFilter.pending),
                  _filterChip(theme, 'Completed', PayoutFilter.completed),
                  _filterChip(theme, 'Failed', PayoutFilter.failed),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: payoutsAsync.when(
              loading: () => Center(child: CircularProgressIndicator(color: theme.primary)),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payments_outlined, size: 48, color: theme.error),
                      const SizedBox(height: 12),
                      Text(err.toString(), textAlign: TextAlign.center, style: theme.bodyLarge),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => ref.read(payoutsProvider.notifier).refresh(),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (state) {
                final payouts = state.payouts;
                return RefreshIndicator(
                  color: theme.primary,
                  onRefresh: () => ref.read(payoutsProvider.notifier).refresh(),
                  child: payouts.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.sizeOf(context).height * 0.35,
                              child: Center(
                                child: Text(
                                  'No payouts for this filter.',
                                  style: theme.bodyLarge.override(color: theme.secondaryText),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          itemCount: 1,
                          itemBuilder: (context, i) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: theme.alternate),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  width: 940,
                                  child: Column(
                                    children: [
                                      _tableHeader(theme),
                                      for (final m in payouts) _tableRow(theme, m),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(FlutterFlowTheme theme, String label, PayoutFilter value) {
    final currentFilter = ref.watch(payoutsProvider).valueOrNull?.filter ?? PayoutFilter.pendingManual;
    final active = currentFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: active ? FontWeight.w600 : FontWeight.w500)),
        selected: active,
        onSelected: (b) {
          if (b) ref.read(payoutsProvider.notifier).setFilter(value);
        },
        selectedColor: theme.primary.withValues(alpha: 0.15),
        backgroundColor: theme.secondaryBackground,
      ),
    );
  }

  Widget _tableHeader(FlutterFlowTheme theme) {
    TextStyle hStyle() => GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: theme.secondaryText, letterSpacing: 0.2);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: theme.alternate.withValues(alpha: 0.6)))),
      child: Row(
        children: [
          Expanded(flex: 7, child: Text('Driver', style: hStyle())),
          SizedBox(width: 96, child: Text('Amount', textAlign: TextAlign.center, style: hStyle())),
          SizedBox(width: 72, child: Text('Method', textAlign: TextAlign.center, style: hStyle())),
          SizedBox(width: 102, child: Text('Status', textAlign: TextAlign.center, style: hStyle())),
          SizedBox(width: 204, child: Text('Actions', textAlign: TextAlign.center, style: hStyle())),
        ],
      ),
    );
  }

  Widget _tableRow(FlutterFlowTheme theme, Map<String, dynamic> m) {
    final title = _payoutTitle(m);
    final amt = _payoutAmount(m);
    final method = _paymentMethod(m);
    final st = _statusKey(m);
    final label = _statusLabel(st);
    final colors = _statusColors(st);
    final did = _driverId(m);

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              flex: 7,
              child: InkWell(
                onTap: did == null
                    ? null
                    : () => context.pushNamedAuth(DriverDetailsWidget.routeName, context.mounted, queryParameters: {'driverId': did.toString()}),
                child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: theme.primaryText)),
              ),
            ),
            SizedBox(
              width: 96,
              child: Center(child: Text(_fmtMoney(amt), textAlign: TextAlign.center, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12, color: theme.primaryText))),
            ),
            SizedBox(
              width: 72,
              child: Center(child: Text(method, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280)))),
            ),
            SizedBox(
              width: 102,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: colors.$2, borderRadius: BorderRadius.circular(6)),
                  child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: colors.$1)),
                ),
              ),
            ),
            SizedBox(
              width: 204,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_canAdminAct(m)) ...[
                    TextButton(onPressed: () => _markPaidRow(m), child: const Text('Pay', style: TextStyle(fontSize: 11))),
                    TextButton(onPressed: () => _rejectRow(m), child: Text('Reject', style: TextStyle(fontSize: 11, color: theme.error))),
                  ],
                  PopupMenuButton<String>(
                    tooltip: 'Finance ops',
                    icon: const Icon(Icons.more_vert_rounded, size: 20),
                    onSelected: (v) => _financeOpsMenuAction(context, v, m),
                    itemBuilder: (ctx) => [
                      if (did != null) const PopupMenuItem(value: 'timeline', child: Text('Audit timeline')),
                      if (did != null) const PopupMenuItem(value: 'hub', child: Text('Finance hub (driver)')),
                      if (_canAdminAct(m) && _payoutId(m) != null) const PopupMenuItem(value: 'hold', child: Text('Hold payout')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _financeOpsMenuAction(BuildContext context, String value, Map<String, dynamic> m) async {
    final did = _driverId(m);
    final pid = _payoutId(m);
    if (!context.mounted) return;

    if (value == 'timeline' && did != null) {
      context.pushNamedAuth(FinanceAuditTimelineWidget.routeName, context.mounted, queryParameters: {'driverId': did.toString()});
    } else if (value == 'hub' && did != null) {
      context.pushNamedAuth(FinanceControlHubScreen.routeName, context.mounted, queryParameters: {'tab': '1', 'driverId': did.toString()});
    } else if (value == 'hold' && pid != null) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Hold payout #$pid?'),
          content: const Text('Sets status to ON_HOLD (workflow).'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hold')),
          ],
        ),
      );
      if (ok != true || !context.mounted) return;
      try {
        await ref.read(payoutsProvider.notifier).hold(pid, 'driver_payouts_ui');
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payout on hold')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}
