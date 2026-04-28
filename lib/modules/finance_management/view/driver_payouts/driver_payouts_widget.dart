import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';
import '/shared/widgets/admin_scaffold.dart';
import '/shared/widgets/responsive_body.dart';
import '/modules/driver_management/view/driver_details/driver_details_widget.dart';
import '/modules/finance_management/view/finance_audit/finance_audit_timeline_widget.dart';
import '/modules/finance_management/view/finance_control/finance_control_hub_widget.dart';
import 'driver_payouts_model.dart';
export 'driver_payouts_model.dart';

enum _PayoutFilter {
  pendingManual,
  all,
  pending,
  completed,
  failed,
}

class DriverPayoutsWidget extends StatefulWidget {
  const DriverPayoutsWidget({super.key});

  static String routeName = 'DriverPayouts';
  static String routePath = '/driver-payouts';

  @override
  State<DriverPayoutsWidget> createState() => _DriverPayoutsWidgetState();
}

class _DriverPayoutsWidgetState extends State<DriverPayoutsWidget> {
  late DriverPayoutsModel _model;

  List<Map<String, dynamic>> _payouts = [];
  bool _loading = true;
  bool _ok = false;
  String? _error;
  _PayoutFilter _filter = _PayoutFilter.pendingManual;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DriverPayoutsModel());
    _load();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  int? _payoutId(Map<String, dynamic> m) =>
      castToType<int>(m['id']) ?? castToType<int>(m['payout_id']);

  bool _canAdminAct(Map<String, dynamic> m) {
    final s = _statusKey(m);
    return s.contains('pending') || s.contains('manual') || s.contains('approved');
  }

  // --- API LOGIC (UNTOUCHED) ---

  Future<void> _markPaidRow(Map<String, dynamic> m) async {
    final id = _payoutId(m);
    if (id == null) return;
    final token = currentAuthenticationToken;
    if (token == null || token.isEmpty) return;
    final refCtrl = TextEditingController();
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Mark Payout #$id as Paid', style: GoogleFonts.interTight(fontWeight: FontWeight.w600)),
          content: TextField(
            controller: refCtrl,
            decoration: InputDecoration(
              labelText: 'Payment Reference (Optional)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: FlutterFlowTheme.of(context).secondaryBackground,
            ),
          ),
          actionsPadding: const EdgeInsets.all(16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: TextStyle(color: FlutterFlowTheme.of(context).secondaryText)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Confirm Payment'),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;

      final resp = await MarkPayoutPaidCall.call(
        token: token,
        payoutId: id,
        paymentReference: refCtrl.text.trim().isEmpty ? null : refCtrl.text.trim(),
      );

      if (!mounted) return;
      if (!resp.succeeded) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(getJsonField(resp.jsonBody, r'''$.message''')?.toString() ?? 'Failed to mark as paid'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ));
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payout marked as paid successfully'), backgroundColor: Color(0xFF2E7D32)),
      );
      await _load();
    } finally {
      refCtrl.dispose();
    }
  }

  Future<void> _rejectRow(Map<String, dynamic> m) async {
    final id = _payoutId(m);
    if (id == null) return;
    final token = currentAuthenticationToken;
    if (token == null || token.isEmpty) return;
    final reasonCtrl = TextEditingController();
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Reject Payout #$id', style: GoogleFonts.interTight(fontWeight: FontWeight.w600)),
          content: TextField(
            controller: reasonCtrl,
            decoration: InputDecoration(
              labelText: 'Reason for rejection (min 3 chars)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: FlutterFlowTheme.of(context).secondaryBackground,
            ),
            maxLines: 3,
          ),
          actionsPadding: const EdgeInsets.all(16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: TextStyle(color: FlutterFlowTheme.of(context).secondaryText)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Reject Payout'),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;

      final reason = reasonCtrl.text.trim();
      if (reason.length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Reason must be at least 3 characters long'), backgroundColor: FlutterFlowTheme.of(context).error),
        );
        return;
      }

      final resp = await PostAdminPayoutRejectCall.call(
        token: token,
        payoutId: id,
        reason: reason,
      );

      if (!mounted) return;
      if (!resp.succeeded) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(getJsonField(resp.jsonBody, r'''$.message''')?.toString() ?? 'Failed to reject payout'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ));
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Payout rejected successfully'), backgroundColor: FlutterFlowTheme.of(context).error),
      );
      await _load();
    } finally {
      reasonCtrl.dispose();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final includeStatus = _filter != _PayoutFilter.all;
      final status = switch (_filter) {
        _PayoutFilter.pendingManual => 'pending_manual_transfer',
        _PayoutFilter.pending => 'pending',
        _PayoutFilter.completed => 'completed',
        _PayoutFilter.failed => 'failed',
        _PayoutFilter.all => null,
      };
      final response = await GetAdminPendingPayoutsCall.call(
        token: currentAuthenticationToken,
        page: 1,
        limit: 50,
        status: status,
        includeStatusParam: includeStatus,
      );
      if (!mounted) return;
      if (!response.succeeded) {
        setState(() {
          _ok = false;
          _payouts = [];
          _error = getJsonField(response.jsonBody, r'''$.message''')?.toString() ?? 'Request failed';
          _loading = false;
        });
        return;
      }
      final raw = GetAdminPendingPayoutsCall.payoutsList(response.jsonBody);
      setState(() {
        _ok = true;
        _payouts = raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _ok = false;
          _loading = false;
        });
      }
    }
  }

  // --- DATA PARSING & FORMATTING (UNTOUCHED LOGIC) ---

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
    for (final k in [
      'amount_raw',
      'amount',
      'requested_amount',
      'withdraw_amount',
      'net_amount',
      'payout_amount',
      'total_amount',
      'gross_amount',
    ]) {
      final d = _parseDouble(m[k]);
      if (d != null) return d;
    }
    return null;
  }

  double _sumAmounts() {
    var s = 0.0;
    for (final m in _payouts) {
      s += _payoutAmount(m) ?? 0;
    }
    return s;
  }

  String _payoutTitle(Map<String, dynamic> m) {
    final drv = m['driver'];
    if (drv is Map) {
      final dm = Map<String, dynamic>.from(drv);
      final dn = dm['name']?.toString().trim();
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

  String _payoutSubtitle(Map<String, dynamic> m) {
    final bits = <String>[];
    final id = m['id'] ?? m['payout_id'];
    if (id != null) bits.add('ID: $id');
    for (final k in ['created_at', 'updated_at', 'requested_at']) {
      final v = m[k]?.toString();
      if (v != null && v.isNotEmpty && v != 'null') {
        final dateStr = v.length > 10 ? v.substring(0, 10) : v;
        bits.add(dateStr);
        break;
      }
    }
    return bits.join(' · ');
  }

  String _statusKey(Map<String, dynamic> m) => (m['status']?.toString() ?? '').toLowerCase();

  String _statusLabel(String s) {
    if (s.contains('complete') || s.contains('paid') || s.contains('success')) {
      return 'Completed';
    }
    if (s.contains('fail') || s.contains('reject') || s.contains('error')) {
      return 'Failed';
    }
    if (s.contains('manual')) {
      return 'Action Required';
    }
    return 'Processing';
  }

  (Color fg, Color bg) _statusColors(String s) {
    final label = _statusLabel(s);
    if (label == 'Completed') {
      return (const Color(0xFF2E7D32), const Color(0xFFE8F5E9));
    }
    if (label == 'Failed') {
      return (const Color(0xFFC62828), const Color(0xFFFFEBEE));
    }
    if (label == 'Action Required') {
      return (const Color(0xFFE65100), const Color(0xFFFFF3E0));
    }
    return (const Color(0xFF1565C0), const Color(0xFFE3F2FD));
  }

  String _paymentMethod(Map<String, dynamic> m) {
    final upiOrBank = m['upi_or_bank']?.toString().trim();
    if (upiOrBank != null && upiOrBank.isNotEmpty && upiOrBank != 'null') {
      final t = upiOrBank.toLowerCase();
      if (t.startsWith('upi:')) return 'UPI';
      if (t.startsWith('bank:')) return 'Bank';
    }
    final explicit = m['payout_method'] ?? m['payment_method'] ?? m['method'] ?? m['transfer_type'] ?? m['payout_channel'] ?? m['channel'];
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
    return 'Unknown';
  }

  int? _nestedDriverId(Map<String, dynamic> m) {
    final drv = m['driver'];
    if (drv is Map) {
      final dm = Map<String, dynamic>.from(drv);
      return castToType<int>(dm['id']) ?? int.tryParse(dm['id']?.toString() ?? '');
    }
    return null;
  }

  int? _driverId(Map<String, dynamic> m) =>
      castToType<int>(m['driver_id']) ?? _nestedDriverId(m) ?? int.tryParse(m['driver_id']?.toString() ?? '');

  Future<void> _exportSummary() async {
    if (_payouts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nothing to export')),
      );
      return;
    }
    final buf = StringBuffer();
    buf.writeln('Driver payouts (${_payouts.length} rows)');
    for (var i = 0; i < _payouts.length; i++) {
      final m = _payouts[i];
      buf.writeln(
        '${i + 1}. ${_payoutTitle(m)} | ${_fmtMoney(_payoutAmount(m))} | ${_statusKey(m)} | id:${m['id']}',
      );
    }
    await Clipboard.setData(ClipboardData(text: buf.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Summary copied to clipboard'),
        backgroundColor: FlutterFlowTheme.of(context).primary,
      ),
    );
  }

  // --- PREMIUM UI BUILDER ---

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final totalListed = _sumAmounts();

    return AdminScaffold(
      title: 'Driver Payouts',
      actions: [
        IconButton(
          tooltip: 'Refresh Queue',
          icon: const Icon(Icons.refresh_rounded),
          onPressed: _loading ? null : _load,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // SUMMARY CARD
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.primary,
                        theme.primary.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Value Listed',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _ok ? _fmtMoney(totalListed) : '—',
                              style: GoogleFonts.interTight(
                                fontWeight: FontWeight.w800,
                                fontSize: 28,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${_payouts.length} Transactions',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: theme.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            ),
                            onPressed: _ok && _payouts.isNotEmpty ? _exportSummary : null,
                            icon: const Icon(Icons.copy_rounded, size: 16),
                            label: Text('Copy List', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // FILTER CHIPS
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip(theme, 'Action Required', _PayoutFilter.pendingManual),
                      const SizedBox(width: 8),
                      _filterChip(theme, 'All Payouts', _PayoutFilter.all),
                      const SizedBox(width: 8),
                      _filterChip(theme, 'Processing', _PayoutFilter.pending),
                      const SizedBox(width: 8),
                      _filterChip(theme, 'Completed', _PayoutFilter.completed),
                      const SizedBox(width: 8),
                      _filterChip(theme, 'Failed', _PayoutFilter.failed),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // PAYOUT LIST
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator(color: theme.primary))
                : !_ok
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.error.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.error_outline_rounded, size: 48, color: theme.error),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error ?? 'Could not load payouts',
                      textAlign: TextAlign.center,
                      style: theme.titleMedium.override(font: GoogleFonts.interTight(fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _load,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            )
                : RefreshIndicator(
              color: theme.primary,
              onRefresh: _load,
              child: _payouts.isEmpty
                  ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.4,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.payments_rounded,
                            size: 64,
                            color: theme.secondaryText.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No payouts found',
                            style: theme.titleLarge.override(
                              font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'There are no transactions matching this filter.',
                            style: theme.bodyMedium.override(color: theme.secondaryText),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
                  : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: _payouts.length,
                    itemBuilder: (context, i) {
                      return _buildPayoutCard(theme, _payouts[i]);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutCard(FlutterFlowTheme theme, Map<String, dynamic> m) {
    final title = _payoutTitle(m);
    final subtitle = _payoutSubtitle(m);
    final amt = _payoutAmount(m);
    final method = _paymentMethod(m);
    final st = _statusKey(m);
    final label = _statusLabel(st);
    final colors = _statusColors(st);
    final did = _driverId(m);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.alternate, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar/Icon
            InkWell(
              onTap: did == null
                  ? null
                  : () => context.pushNamedAuth(
                DriverDetailsWidget.routeName,
                context.mounted,
                queryParameters: {'driverId': did.toString()},
              ),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.alternate),
                ),
                child: Icon(Icons.person_rounded, color: theme.secondaryText, size: 24),
              ),
            ),
            const SizedBox(width: 16),

            // Core Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: did == null
                        ? null
                        : () => context.pushNamedAuth(
                      DriverDetailsWidget.routeName,
                      context.mounted,
                      queryParameters: {'driverId': did.toString()},
                    ),
                    child: Text(
                      title,
                      style: GoogleFonts.interTight(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: theme.primaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.$2,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          label.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: colors.$1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: theme.secondaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Amount & Actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _fmtMoney(amt),
                  style: GoogleFonts.interTight(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  method.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.secondaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_canAdminAct(m)) ...[
                      FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                          foregroundColor: const Color(0xFF2E7D32),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          minimumSize: const Size(0, 32),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => unawaited(_markPaidRow(m)),
                        child: Text('Pay', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                      const SizedBox(width: 6),
                      FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.error.withValues(alpha: 0.15),
                          foregroundColor: theme.error,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          minimumSize: const Size(0, 32),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => unawaited(_rejectRow(m)),
                        child: Text('Reject', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                    ],
                    const SizedBox(width: 4),
                    PopupMenuButton<String>(
                      tooltip: 'Options',
                      icon: Icon(Icons.more_vert_rounded, size: 20, color: theme.secondaryText),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: theme.secondaryBackground,
                      onSelected: (v) => unawaited(_financeOpsMenuAction(context, v, m)),
                      itemBuilder: (ctx) => [
                        if (did != null)
                          PopupMenuItem(
                            value: 'timeline',
                            child: Row(
                              children: [
                                Icon(Icons.history_rounded, size: 18, color: theme.secondaryText),
                                const SizedBox(width: 8),
                                Text('Audit Timeline', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        if (did != null)
                          PopupMenuItem(
                            value: 'hub',
                            child: Row(
                              children: [
                                Icon(Icons.account_balance_wallet_rounded, size: 18, color: theme.secondaryText),
                                const SizedBox(width: 8),
                                Text('Driver Finance Hub', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        if (_canAdminAct(m) && _payoutId(m) != null)
                          PopupMenuItem(
                            value: 'hold',
                            child: Row(
                              children: [
                                const Icon(Icons.pause_circle_filled_rounded, size: 18, color: Color(0xFFEF6C00)),
                                const SizedBox(width: 8),
                                Text('Hold Payout', style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: const Color(0xFFEF6C00))),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _financeOpsMenuAction(
      BuildContext context,
      String value,
      Map<String, dynamic> m,
      ) async {
    final did = _driverId(m);
    final pid = _payoutId(m);
    if (!context.mounted) return;
    if (value == 'timeline' && did != null) {
      context.pushNamedAuth(
        FinanceAuditTimelineWidget.routeName,
        context.mounted,
        queryParameters: {'driverId': did.toString()},
      );
    } else if (value == 'hub' && did != null) {
      context.pushNamedAuth(
        FinanceControlHubWidget.routeName,
        context.mounted,
        queryParameters: {
          'tab': '1',
          'driverId': did.toString(),
        },
      );
    } else if (value == 'hold' && pid != null) {
      final token = currentAuthenticationToken;
      if (token == null || token.isEmpty) return;
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Hold Payout #$pid?', style: GoogleFonts.interTight(fontWeight: FontWeight.w600)),
          content: const Text('This will set the status to ON_HOLD and pause the workflow.'),
          actionsPadding: const EdgeInsets.all(16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: TextStyle(color: FlutterFlowTheme.of(context).secondaryText)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF6C00),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hold Payout'),
            ),
          ],
        ),
      );
      if (ok != true || !context.mounted) return;

      final r = await PostAdminFinanceWorkflowPayoutHoldCall.call(
        token: token,
        payoutId: pid,
        reason: 'admin_dashboard_hold',
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            r.succeeded ? 'Payout successfully placed on hold' : (getJsonField(r.jsonBody, r'''$.message''')?.toString() ?? 'Failed to hold payout'),
          ),
          backgroundColor: r.succeeded ? const Color(0xFFEF6C00) : FlutterFlowTheme.of(context).error,
        ),
      );
      if (r.succeeded) await _load();
    }
  }

  Widget _filterChip(FlutterFlowTheme theme, String label, _PayoutFilter value) {
    final sel = _filter == value;
    return FilterChip(
      label: Text(label),
      selected: sel,
      showCheckmark: false,
      backgroundColor: theme.primaryBackground,
      selectedColor: theme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: sel ? theme.primary : theme.alternate,
        ),
      ),
      labelStyle: theme.bodyMedium.override(
        font: GoogleFonts.inter(
          fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
        ),
        color: sel ? Colors.white : theme.primaryText,
      ),
      onSelected: (_) {
        if (_filter == value) return;
        setState(() => _filter = value);
        _load();
      },
    );
  }
}