import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/admin_scaffold.dart';
import '/pages/driver_details/driver_details_widget.dart';
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
          _error = getJsonField(response.jsonBody, r'''$.message''')
                  ?.toString() ??
              'Request failed';
          _loading = false;
        });
        return;
      }
      final raw = GetAdminPendingPayoutsCall.payoutsList(response.jsonBody);
      setState(() {
        _ok = true;
        _payouts = raw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
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
      'amount',
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
    final fn = m['driver_first_name']?.toString().trim() ?? '';
    final ln = m['driver_last_name']?.toString().trim() ?? '';
    final n = '$fn $ln'.trim();
    if (n.isNotEmpty) return n;
    final name = m['driver_name']?.toString().trim() ??
        m['name']?.toString().trim();
    if (name != null && name.isNotEmpty && name != 'null') return name;
    final id = m['driver_id'] ?? m['user_id'];
    return id != null ? 'Payout #$id' : 'Payout';
  }

  String _payoutSubtitle(Map<String, dynamic> m) {
    final bits = <String>[];
    final id = m['id'] ?? m['payout_id'];
    if (id != null) bits.add('Ref $id');
    final st = m['status']?.toString();
    if (st != null && st.isNotEmpty && st != 'null') bits.add(st);
    for (final k in ['created_at', 'updated_at', 'requested_at']) {
      final v = m[k]?.toString();
      if (v != null && v.isNotEmpty && v != 'null') {
        bits.add(v.length > 16 ? '${v.substring(0, 16)}…' : v);
        break;
      }
    }
    return bits.join(' · ');
  }

  String _statusKey(Map<String, dynamic> m) =>
      (m['status']?.toString() ?? '').toLowerCase();

  Color _statusColor(String s) {
    if (s.contains('complete') || s.contains('paid') || s.contains('success')) {
      return const Color(0xFF2E7D32);
    }
    if (s.contains('fail') || s.contains('reject') || s.contains('error')) {
      return const Color(0xFFC62828);
    }
    return const Color(0xFFEF6C00);
  }

  int? _driverId(Map<String, dynamic> m) =>
      castToType<int>(m['driver_id']) ??
      int.tryParse(m['driver_id']?.toString() ?? '');

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
      const SnackBar(content: Text('Summary copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final totalListed = _sumAmounts();

    return AdminScaffold(
      title: 'Driver payouts',
      actions: [
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh_rounded),
          onPressed: _loading ? null : _load,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primary.withValues(alpha: 0.12),
                    theme.primary.withValues(alpha: 0.04),
                  ],
                ),
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
                          'Listed total (${_payouts.length} rows)',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _ok ? _fmtMoney(totalListed) : '—',
                          style: GoogleFonts.interTight(
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                            color: theme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _ok ? _exportSummary : null,
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('Copy list'),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip(theme, 'Pending transfer', _PayoutFilter.pendingManual),
                  _filterChip(theme, 'All (no filter)', _PayoutFilter.all),
                  _filterChip(theme, 'Pending', _PayoutFilter.pending),
                  _filterChip(theme, 'Completed', _PayoutFilter.completed),
                  _filterChip(theme, 'Failed', _PayoutFilter.failed),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
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
                              Icon(Icons.payments_outlined,
                                  size: 48, color: theme.error),
                              const SizedBox(height: 12),
                              Text(
                                _error ?? 'Could not load payouts',
                                textAlign: TextAlign.center,
                                style: theme.bodyLarge,
                              ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: _load,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Retry'),
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
                                    height:
                                        MediaQuery.sizeOf(context).height * 0.35,
                                    child: Center(
                                      child: Text(
                                        'No payouts for this filter.',
                                        style: theme.bodyLarge.override(
                                          color: theme.secondaryText,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 0, 16, 100),
                                itemCount: _payouts.length,
                                itemBuilder: (context, i) {
                                  final m = _payouts[i];
                                  final amt = _payoutAmount(m);
                                  final st = _statusKey(m);
                                  final stColor = _statusColor(st);
                                  final did = _driverId(m);

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(14),
                                        onTap: did == null
                                            ? null
                                            : () => context.pushNamedAuth(
                                                  DriverDetailsWidget.routeName,
                                                  context.mounted,
                                                  queryParameters: {
                                                    'driverId': did.toString(),
                                                  },
                                                ),
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: theme.secondaryBackground,
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            border: Border.all(
                                                color: theme.alternate),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: stColor.withValues(
                                                      alpha: 0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Icon(
                                                  Icons.account_balance_wallet,
                                                  color: stColor,
                                                  size: 22,
                                                ),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      _payoutTitle(m),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: GoogleFonts
                                                          .interTight(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      _payoutSubtitle(m),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 11,
                                                        color: theme
                                                            .secondaryText,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    _fmtMoney(amt),
                                                    style: GoogleFonts.interTight(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 15,
                                                      color: const Color(
                                                          0xFF1565C0),
                                                    ),
                                                  ),
                                                  if (st.isNotEmpty)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 6),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: stColor
                                                              .withValues(
                                                                  alpha: 0.12),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20),
                                                        ),
                                                        child: Text(
                                                          st.toUpperCase(),
                                                          style: GoogleFonts
                                                              .inter(
                                                            fontSize: 9,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700,
                                                            color: stColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
    FlutterFlowTheme theme,
    String label,
    _PayoutFilter value,
  ) {
    final sel = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 4),
      child: FilterChip(
        label: Text(label),
        selected: sel,
        onSelected: (_) {
          if (_filter == value) return;
          setState(() => _filter = value);
          _load();
        },
      ),
    );
  }
}
