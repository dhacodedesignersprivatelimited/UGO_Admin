import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/admin_pop_scope.dart';
import '/components/admin_scaffold.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// GET `/api/admins/finance/audit-timeline` — merged ledger, payouts, wallet tx, referrals.
class FinanceAuditTimelineWidget extends StatefulWidget {
  const FinanceAuditTimelineWidget({
    super.key,
    this.userId,
    this.driverId,
  });

  final int? userId;
  final int? driverId;

  static String routeName = 'FinanceAuditTimeline';
  static String routePath = '/finance-audit-timeline';

  @override
  State<FinanceAuditTimelineWidget> createState() => _FinanceAuditTimelineWidgetState();
}

class _FinanceAuditTimelineWidgetState extends State<FinanceAuditTimelineWidget> {
  bool _loading = true;
  String? _error;
  List<dynamic> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = currentAuthenticationToken;
    if (token == null || token.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Not signed in';
      });
      return;
    }
    final uid = widget.userId;
    final did = widget.driverId;
    if ((uid == null || uid < 1) && (did == null || did < 1)) {
      setState(() {
        _loading = false;
        _error = 'Provide userId or driverId (query).';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await GetAdminFinanceAuditTimelineCall.call(
        token: token,
        userId: uid,
        driverId: did,
        limit: 120,
      );
      if (!r.succeeded) {
        setState(() {
          _loading = false;
          _error = getJsonField(r.jsonBody, r'''$.message''')?.toString() ?? 'Failed';
        });
        return;
      }
      setState(() {
        _loading = false;
        _items = GetAdminFinanceAuditTimelineCall.itemsList(r.jsonBody);
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final subtitle = widget.userId != null
        ? 'user_id=${widget.userId}'
        : 'driver_id=${widget.driverId}';
    return AdminPopScope(
      child: AdminScaffold(
        title: 'Finance audit timeline',
        actions: [
          IconButton(onPressed: _loading ? null : _load, icon: const Icon(Icons.refresh_rounded)),
        ],
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          FilledButton(onPressed: _load, child: const Text('Retry')),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Text(subtitle, style: theme.bodySmall),
                        const SizedBox(height: 8),
                        Text(
                          'GET /api/admins/finance/audit-timeline',
                          style: GoogleFonts.jetBrainsMono(fontSize: 11, color: theme.secondaryText),
                        ),
                        const SizedBox(height: 16),
                        if (_items.isEmpty)
                          Text('No events.', style: theme.bodySmall)
                        else
                          ..._items.map((e) {
                            final m = e as Map<String, dynamic>;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(
                                  '${m['category']} · ${m['title']}',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                subtitle: Text(
                                  '${m['at']}\nref ${m['reference_type']}:${m['reference_id']} · ₹${m['amount_inr'] ?? '—'}\n${m['detail'] ?? ''}',
                                  style: theme.bodySmall,
                                ),
                                isThreeLine: true,
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
      ),
    );
  }
}
