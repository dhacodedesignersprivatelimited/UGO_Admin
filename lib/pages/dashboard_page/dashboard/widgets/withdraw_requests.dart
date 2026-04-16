import 'dart:math' as math;

import '/components/safe_network_avatar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../dashboard_tokens.dart';

/// Recent withdrawal / payout rows.
class WithdrawRequests extends StatelessWidget {
  const WithdrawRequests({
    super.key,
    required this.payouts,
    this.isLoading = false,
    this.maxRows = 4,
    this.onViewAll,
  });

  final List<dynamic> payouts;
  final bool isLoading;
  final int maxRows;
  final VoidCallback? onViewAll;

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString().trim());
  }

  static double? _payoutAmount(Map<String, dynamic> m) {
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

  static String _payoutTitle(Map<String, dynamic> m) {
    final drv = m['driver'];
    if (drv is Map) {
      final dm = Map<String, dynamic>.from(drv);
      final dn = dm['name']?.toString().trim();
      if (dn != null && dn.isNotEmpty && dn != 'null') {
        final wr = m['wr_id']?.toString().trim();
        if (wr != null && wr.isNotEmpty && wr != 'null') {
          return '$wr · $dn';
        }
        return dn;
      }
    }
    final fn = m['driver_first_name']?.toString().trim() ?? '';
    final ln = m['driver_last_name']?.toString().trim() ?? '';
    final n = '$fn $ln'.trim();
    if (n.isNotEmpty) return n;
    final name = m['driver_name']?.toString().trim() ??
        m['name']?.toString().trim();
    if (name != null && name.isNotEmpty && name != 'null') {
      final wr = m['wr_id']?.toString().trim();
      if (wr != null && wr.isNotEmpty && wr != 'null') {
        return '$wr · $name';
      }
      return name;
    }
    final id = m['driver_id'] ?? m['user_id'];
    return id != null ? 'Driver #$id' : 'Driver';
  }

  static String? _profileUrl(Map<String, dynamic> m) {
    for (final k in [
      'driver_profile_image',
      'profile_image',
      'driver_image',
      'avatar',
      'photo',
    ]) {
      final v = m[k]?.toString().trim();
      if (v != null && v.isNotEmpty && v != 'null') return v;
    }
    final drv = m['driver'];
    if (drv is Map) {
      final dm = Map<String, dynamic>.from(drv);
      for (final k in ['profile_image', 'profileImage', 'image']) {
        final v = dm[k]?.toString().trim();
        if (v != null && v.isNotEmpty && v != 'null') return v;
      }
    }
    return null;
  }

  static String _paymentMethod(Map<String, dynamic> m) {
    final upiOrBank = m['upi_or_bank']?.toString().trim();
    if (upiOrBank != null && upiOrBank.isNotEmpty && upiOrBank != 'null') {
      final t = upiOrBank.toLowerCase();
      if (t.startsWith('upi:')) return 'UPI';
      if (t.startsWith('bank:')) return 'Bank';
    }
    final explicit = m['payout_method'] ??
        m['payment_method'] ??
        m['method'] ??
        m['transfer_type'] ??
        m['payout_channel'] ??
        m['channel'];
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
    final s = (m['status']?.toString() ?? '').toLowerCase();
    if (s.contains('pending_manual_transfer')) return 'Manual';
    return '—';
  }

  static String _statusRaw(Map<String, dynamic> m) =>
      (m['status']?.toString() ?? '').toLowerCase();

  static String _statusLabel(String s) {
    if (s.contains('complete') || s.contains('paid') || s.contains('success')) {
      return 'Approved';
    }
    if (s.contains('fail') || s.contains('reject') || s.contains('error')) {
      return 'Failed';
    }
    return 'Pending';
  }

  static (Color fg, Color bg) _statusColors(String raw) {
    final label = _statusLabel(raw);
    if (label == 'Approved') {
      return (const Color(0xFF2E7D32), const Color(0xFFE8F5E9));
    }
    if (label == 'Failed') {
      return (const Color(0xFFC62828), const Color(0xFFFFEBEE));
    }
    return (const Color(0xFFEF6C00), const Color(0xFFFFF3E0));
  }

  static String _fmtMoney(double? n) {
    if (n == null) return '—';
    return '₹${NumberFormat('#,##0.00', 'en_IN').format(n)}';
  }

  static int? _driverId(Map<String, dynamic> m) =>
      castToType<int>(m['driver_id']) ??
      castToType<int>(getJsonField(m, r'''$.driver.id''')) ??
      int.tryParse(m['driver_id']?.toString() ?? '');

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final screenW = MediaQuery.sizeOf(context).width;
    const horizontalPad = 32.0;
    final viewport = math.max(screenW - horizontalPad, 280.0);
    const tableMinW = 620.0;
    final contentW = viewport < tableMinW ? tableMinW : viewport;
    final totalCount = payouts.whereType<Map>().length;
    final rows = payouts
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .take(maxRows)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DashboardTokens.cardRadius),
        boxShadow: DashboardTokens.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Recent Withdraw Requests',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryText,
                    ),
                  ),
                ),
                Text(
                  'Total: $totalCount',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (rows.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Showing ${rows.length} of $totalCount',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: theme.secondaryText,
                  ),
                ),
              ),
            ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: DashboardTokens.primaryOrange,
                ),
              ),
            )
          else if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              child: Text(
                'No withdrawal requests to show.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: theme.secondaryText,
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: contentW,
                child: Column(
                  children: [
                    _tableHeader(theme: theme),
                    for (var i = 0; i < rows.length; i++) ...[
                      _WithdrawRow(
                        map: rows[i],
                        theme: theme,
                      ).animate().fadeIn(duration: 300.ms, delay: (50 * i).ms),
                    ],
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  foregroundColor: DashboardTokens.primaryOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All Requests',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: DashboardTokens.primaryOrange,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader({required FlutterFlowTheme theme}) {
    TextStyle hStyle() => GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: theme.secondaryText,
          letterSpacing: 0.2,
        );

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.alternate.withValues(alpha: 0.6)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(flex: 7, child: Text('Driver', style: hStyle())),
          SizedBox(
            width: 96,
            child: Text('Amount', textAlign: TextAlign.center, style: hStyle()),
          ),
          SizedBox(
            width: 72,
            child: Text('Method', textAlign: TextAlign.center, style: hStyle()),
          ),
          SizedBox(
            width: 102,
            child: Text('Status', textAlign: TextAlign.center, style: hStyle()),
          ),
        ],
      ),
    );
  }
}

class _WithdrawRow extends StatelessWidget {
  const _WithdrawRow({
    required this.map,
    required this.theme,
  });

  final Map<String, dynamic> map;
  final FlutterFlowTheme theme;

  @override
  Widget build(BuildContext context) {
    final title = WithdrawRequests._payoutTitle(map);
    final url = WithdrawRequests._profileUrl(map) ?? '';
    final amt = WithdrawRequests._payoutAmount(map);
    final method = WithdrawRequests._paymentMethod(map);
    final rawSt = WithdrawRequests._statusRaw(map);
    final stLabel = WithdrawRequests._statusLabel(rawSt);
    final stColors = WithdrawRequests._statusColors(rawSt);
    final did = WithdrawRequests._driverId(map);
    final money = WithdrawRequests._fmtMoney(amt);

    final methodText = Text(
      method,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF6B7280),
      ),
    );
    final statusChip = _statusChip(stLabel, stColors.$1, stColors.$2);

    void onTap() {
      if (did == null) return;
      context.pushNamedAuth(
        DriverDetailsWidget.routeName,
        context.mounted,
        queryParameters: {'driverId': did.toString()},
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: did != null ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 7,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SafeNetworkAvatar(imageUrl: url, radius: 13),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: theme.primaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 96,
                  child: Center(
                      child: Text(
                    money,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: theme.primaryText,
                    ),
                  )),
                ),
                SizedBox(
                  width: 72,
                  child: Center(child: methodText),
                ),
                SizedBox(
                  width: 102,
                  child: Center(child: statusChip),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String label, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
