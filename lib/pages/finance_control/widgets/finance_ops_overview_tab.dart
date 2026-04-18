import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';

/// Live ops: metrics, **alerts**, **insights**, auto-refresh, recent payouts & ledger samples.
class FinanceOpsOverviewTab extends StatefulWidget {
  const FinanceOpsOverviewTab({super.key});

  @override
  State<FinanceOpsOverviewTab> createState() => _FinanceOpsOverviewTabState();
}

class _FinanceOpsOverviewTabState extends State<FinanceOpsOverviewTab> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _summary;
  Map<String, dynamic>? _metrics;
  List<dynamic> _outbox = const [];
  List<dynamic> _pendingPayouts = const [];
  List<dynamic> _alerts = const [];
  Map<String, dynamic>? _insights;
  List<dynamic> _liveLedger = const [];
  List<dynamic> _liveWalletTx = const [];

  bool _liveRefresh = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _setLive(bool v) {
    setState(() => _liveRefresh = v);
    _timer?.cancel();
    if (v) {
      _timer = Timer.periodic(const Duration(seconds: 25), (_) => _loadLiveSlice());
    }
  }

  Future<void> _loadLiveSlice() async {
    final token = currentAuthenticationToken;
    if (token == null || token.isEmpty) return;
    try {
      final results = await Future.wait([
        GetAdminUnifiedPayoutsCall.call(token: token, page: 1, limit: 10, status: 'pending'),
        GetAdminLedgerCall.call(token: token, page: 1, limit: 12),
        GetAdminFinanceAlertsCall.call(token: token),
        GetAdminWalletTransactionsCall.call(token: token, page: 1, limit: 8),
      ]);
      if (!mounted) return;
      setState(() {
        _pendingPayouts = GetAdminUnifiedPayoutsCall.payoutsList(results[0].jsonBody);
        _liveLedger = GetAdminLedgerCall.entriesList(results[1].jsonBody);
        _alerts = results[2].succeeded ? GetAdminFinanceAlertsCall.alertsList(results[2].jsonBody) : _alerts;
        _liveWalletTx = results[3].succeeded
            ? GetAdminWalletTransactionsCall.transactionsList(results[3].jsonBody)
            : _liveWalletTx;
      });
    } catch (_) {}
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
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        GetAdminFinanceSummaryCall.call(token: token),
        GetAdminFinanceMetricsCall.call(token: token),
        GetAdminFinanceOutboxCall.call(token: token, limit: 25),
        GetAdminUnifiedPayoutsCall.call(token: token, page: 1, limit: 8, status: 'pending'),
        GetAdminFinanceAlertsCall.call(token: token),
        GetAdminFinanceInsightsCall.call(token: token),
        GetAdminLedgerCall.call(token: token, page: 1, limit: 10),
        GetAdminWalletTransactionsCall.call(token: token, page: 1, limit: 6),
      ]);
      final sum = results[0];
      final met = results[1];
      final ob = results[2];
      final po = results[3];
      final al = results[4];
      final ins = results[5];
      final led = results[6];
      final wtx = results[7];
      if (!sum.succeeded) {
        setState(() {
          _loading = false;
          _error = getJsonField(sum.jsonBody, r'''$.message''')?.toString() ?? 'Summary failed';
        });
        return;
      }
      setState(() {
        _loading = false;
        _summary = GetAdminFinanceSummaryCall.data(sum.jsonBody);
        _metrics = met.succeeded ? getJsonField(met.jsonBody, r'''$.data''') as Map<String, dynamic>? : null;
        _outbox = GetAdminFinanceOutboxCall.itemsList(ob.jsonBody);
        _pendingPayouts = GetAdminUnifiedPayoutsCall.payoutsList(po.jsonBody);
        _alerts = al.succeeded ? GetAdminFinanceAlertsCall.alertsList(al.jsonBody) : const [];
        _insights = ins.succeeded ? getJsonField(ins.jsonBody, r'''$.data''') as Map<String, dynamic>? : null;
        _liveLedger = led.succeeded ? GetAdminLedgerCall.entriesList(led.jsonBody) : const [];
        _liveWalletTx = wtx.succeeded ? GetAdminWalletTransactionsCall.transactionsList(wtx.jsonBody) : const [];
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _showWorkflows() async {
    final token = currentAuthenticationToken;
    if (token == null || !mounted) return;
    final r = await GetAdminFinanceWorkflowsCall.call(token: token);
    if (!mounted) return;
    final data = r.succeeded ? getJsonField(r.jsonBody, r'''$.data''') : null;
    final list = (data is Map && data['workflows'] is List) ? data['workflows'] as List : const [];
    final buf = StringBuffer();
    for (final w in list) {
      if (w is Map) {
        buf.writeln('• ${w['id']}: ${w['title']}\n  ${w['description']}\n');
      }
    }
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Workflow catalog'),
        content: SingleChildScrollView(child: Text(buf.isEmpty ? 'No data' : buf.toString())),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final pending = _summary?['pending_payouts'] as Map<String, dynamic>?;
    final pendingCount = pending?['count'] ?? 0;
    final pendingAmt = pending?['amount_inr'] ?? 0;
    final outbox = _metrics?['outbox'] as Map<String, dynamic>?;
    final obPending = outbox?['pending'] ?? 0;
    final obFailed = outbox?['failed'] ?? 0;
    final obProc = outbox?['processing'] ?? 0;

    final narrative = (_insights?['narrative'] as List?)?.map((e) => e.toString()).toList() ?? const [];

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Financial operations',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Live refresh (25s)'),
            subtitle: const Text('Pending queue, ledger head, alerts, driver wallet tx'),
            value: _liveRefresh,
            onChanged: _setLive,
          ),
          TextButton(onPressed: _showWorkflows, child: const Text('View workflow catalog')),
          const SizedBox(height: 8),
          if (obFailed > 0)
            Card(
              color: theme.error.withValues(alpha: 0.12),
              child: ListTile(
                leading: Icon(Icons.warning_amber_rounded, color: theme.error),
                title: Text('Outbox failures: $obFailed', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                subtitle: const Text('System alert — review failed finance outbox events.'),
              ),
            ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _metricCard(theme, 'Pending payouts', '$pendingCount', '₹$pendingAmt'),
              _metricCard(theme, 'Outbox pending', '$obPending', 'queue depth'),
              _metricCard(theme, 'Outbox processing', '$obProc', 'in flight'),
              _metricCard(theme, 'Outbox failed', '$obFailed', 'needs attention'),
            ],
          ),
          const SizedBox(height: 20),
          Text('Alert rules (snapshot)', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          Text('GET /api/admins/finance/alerts', style: theme.bodySmall),
          const SizedBox(height: 8),
          if (_alerts.isEmpty)
            Text('No active rule hits.', style: theme.bodySmall)
          else
            ..._alerts.map((a) {
              final m = a as Map<String, dynamic>;
              final code = m['code']?.toString() ?? '';
              Map<String, dynamic>? det;
              final raw = m['detail'];
              if (raw is Map) det = Map<String, dynamic>.from(raw);
              final detStr = det != null ? det.entries.map((e) => '${e.key}:${e.value}').join(', ') : raw?.toString() ?? '';
              final driverId = det?['driver_id'] as int? ?? int.tryParse('${det?['driver_id'] ?? ''}');
              final payoutId = det?['payout_id'] as int? ?? int.tryParse('${det?['payout_id'] ?? ''}');
              final userId = det?['user_id'] as int? ?? int.tryParse('${det?['user_id'] ?? ''}');
              return Card(
                color: theme.warning.withValues(alpha: 0.08),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${m['severity']} · ${m['title']}',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('$code\n$detStr', maxLines: 6, overflow: TextOverflow.ellipsis, style: theme.bodySmall),
                      Wrap(
                        spacing: 8,
                        children: [
                          if (driverId != null && driverId > 0)
                            TextButton(
                              onPressed: () => context.pushNamed(
                                FinanceControlHubWidget.routeName,
                                queryParameters: {'tab': '1', 'driverId': '$driverId'},
                              ),
                              child: const Text('Ledger (driver)'),
                            ),
                          if (userId != null && userId > 0)
                            TextButton(
                              onPressed: () => context.pushNamed(
                                FinanceControlHubWidget.routeName,
                                queryParameters: {'tab': '1', 'userId': '$userId'},
                              ),
                              child: const Text('Ledger (user)'),
                            ),
                          if (driverId != null && driverId > 0)
                            TextButton(
                              onPressed: () => context.pushNamed(
                                FinanceAuditTimelineWidget.routeName,
                                queryParameters: {'driverId': '$driverId'},
                              ),
                              child: const Text('Timeline'),
                            ),
                          if (payoutId != null && payoutId > 0)
                            TextButton(
                              onPressed: () => _openCaseFromAlert(context, 'payout', payoutId, code),
                              child: const Text('Open case'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 20),
          Text('Smart insights', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          Text('GET /api/admins/finance/insights', style: theme.bodySmall),
          const SizedBox(height: 8),
          if (narrative.isEmpty)
            Text('No narrative.', style: theme.bodySmall)
          else ...[
            TextButton(
              onPressed: () => context.pushNamed(FinanceReportsWidget.routeName),
              child: const Text('View underlying reports'),
            ),
            ...narrative.map((n) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('· $n', style: theme.bodyMedium),
                )),
          ],
          const SizedBox(height: 20),
          Text('Live payout queue (sample)', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          if (_pendingPayouts.isEmpty)
            Text('No rows.', style: theme.bodySmall)
          else
            ..._pendingPayouts.map((p) {
              final m = p as Map<String, dynamic>;
              final pid = m['id'] ?? m['payout_id'];
              final did = m['driver_id'];
              return ListTile(
                dense: true,
                title: Text('#$pid · driver $did · ₹${m['amount']}'),
                subtitle: Text('${m['status']}'),
                trailing: pid != null && did != null
                    ? TextButton(
                        onPressed: () => context.pushNamed(
                          FinanceAuditTimelineWidget.routeName,
                          queryParameters: {'driverId': '$did'},
                        ),
                        child: const Text('Timeline'),
                      )
                    : null,
              );
            }),
          const SizedBox(height: 16),
          Text('Live ledger (latest)', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          if (_liveLedger.isEmpty)
            Text('No rows.', style: theme.bodySmall)
          else
            ..._liveLedger.take(6).map((e) {
              final m = e as Map<String, dynamic>;
              return ListTile(
                dense: true,
                title: Text('${m['entry_type']} · ₹${m['amount']}', style: GoogleFonts.jetBrainsMono(fontSize: 11)),
                subtitle: Text('${m['reference_type']}:${m['reference_id']}'),
              );
            }),
          const SizedBox(height: 16),
          Text('Live driver wallet transactions', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          Text('GET /api/admins/wallet/transactions', style: theme.bodySmall),
          if (_liveWalletTx.isEmpty)
            Text('No rows (or endpoint empty).', style: theme.bodySmall)
          else
            ..._liveWalletTx.map((t) {
              final m = t as Map<String, dynamic>;
              return ListTile(
                dense: true,
                title: Text(
                  '${m['transaction_type'] ?? m['type'] ?? 'tx'} · driver ${m['driver_id'] ?? '—'}',
                  style: GoogleFonts.jetBrainsMono(fontSize: 11),
                ),
                subtitle: Text('${m['date'] ?? m['created_at'] ?? ''} · ${m['description'] ?? ''}', maxLines: 2),
              );
            }),
          const SizedBox(height: 16),
          Text('Outbox queue (latest)', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          if (_outbox.isEmpty)
            Text('No outbox rows returned.', style: theme.bodySmall)
          else
            ..._outbox.map((e) {
              final m = e as Map<String, dynamic>;
              return ListTile(
                dense: true,
                title: Text('${m['event_type']} · ${m['status']}'),
                subtitle: Text(
                  'id ${m['id']} · attempts ${m['attempts']}/${m['max_attempts']}\n${m['last_error'] ?? ''}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          const SizedBox(height: 12),
          Text('Quick links', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ListTile(
            leading: const Icon(Icons.payments_rounded),
            title: const Text('Driver payouts queue'),
            onTap: () => context.pushNamed(DriverPayoutsWidget.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.table_chart_rounded),
            title: const Text('Finance reports & CSV'),
            onTap: () => context.pushNamed(FinanceReportsWidget.routeName),
          ),
        ],
      ),
    );
  }

  Future<void> _openCaseFromAlert(BuildContext context, String entityType, int entityId, String alertCode) async {
    final token = currentAuthenticationToken;
    if (token == null || !context.mounted) return;
    final notesCtrl = TextEditingController(text: 'Opened from alert: $alertCode');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create finance case'),
        content: TextField(controller: notesCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Notes')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Create')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final r = await PostAdminFinanceCaseCall.call(
      token: token,
      entityType: entityType,
      entityId: entityId,
      notes: notesCtrl.text.trim(),
      sourceAlertCode: alertCode,
    );
    notesCtrl.dispose();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          r.succeeded ? 'Case created' : (getJsonField(r.jsonBody, r'''$.message''')?.toString() ?? 'Failed'),
        ),
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
              Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
              Text(sub, style: theme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
