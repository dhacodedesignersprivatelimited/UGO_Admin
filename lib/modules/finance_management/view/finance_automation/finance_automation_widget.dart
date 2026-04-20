import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';
import '/core/network/finance_sse_client.dart';
import '/shared/widgets/admin_pop_scope.dart';
import '/shared/widgets/admin_scaffold.dart';
import '/config/theme/flutter_flow_theme.dart';

Color _casePriorityColor(String p) {
  switch (p.toLowerCase()) {
    case 'critical':
      return const Color(0xFFB71C1C);
    case 'high':
      return const Color(0xFFE65100);
    case 'medium':
      return const Color(0xFFF9A825);
    case 'low':
    default:
      return const Color(0xFF546E7A);
  }
}

bool _jsonBool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = '$v'.toLowerCase();
  return s == 'true' || s == '1';
}

String _caseSlaSubtitle(Map<String, dynamic> m) {
  final effRaw = m['sla_effective_due_at'];
  final dueRaw = (effRaw != null && '$effRaw'.trim().isNotEmpty) ? effRaw : m['sla_due_at'];
  final dueStr = dueRaw == null ? '' : '$dueRaw';
  if (dueStr.isEmpty) return 'SLA: not set · priority: ${m['priority'] ?? 'medium'}';
  final due = DateTime.tryParse(dueStr);
  if (due == null) return 'SLA: $dueStr · priority: ${m['priority'] ?? 'medium'}';
  final st = '${m['status']}'.toLowerCase();
  if (st == 'resolved' || st == 'closed') {
    return 'SLA: $dueStr (closed) · priority: ${m['priority'] ?? 'medium'}';
  }
  final paused = _jsonBool(m['sla_paused']) || st == 'waiting_on_user' || st == 'waiting_on_driver';
  if (paused) {
    final remMs = m['sla_remaining_ms'];
    if (remMs is num) {
      final rem = Duration(milliseconds: remMs.round());
      final overdue = _jsonBool(m['is_overdue']);
      if (overdue || rem.isNegative) {
        final late = rem.isNegative ? rem.abs() : const Duration();
        return 'SLA PAUSED · overdue by ${_formatDurationShort(late)} (effective) · ${m['priority'] ?? 'medium'}';
      }
      return 'SLA PAUSED · ${_formatDurationShort(rem)} left (effective) · ${m['priority'] ?? 'medium'}';
    }
    return 'SLA PAUSED · effective due $dueStr · priority: ${m['priority'] ?? 'medium'}';
  }
  final overdue = _jsonBool(m['is_overdue']);
  final rem = due.difference(DateTime.now());
  if (overdue || rem.isNegative) {
    final late = rem.isNegative ? rem.abs() : const Duration();
    return 'SLA OVERDUE by ${_formatDurationShort(late)} · due $dueStr · ${m['priority'] ?? 'medium'}';
  }
  return 'SLA ${_formatDurationShort(rem)} left · due $dueStr · ${m['priority'] ?? 'medium'}';
}

String _formatDurationShort(Duration d) {
  if (d.inDays >= 1) return '${d.inDays}d ${d.inHours.remainder(24)}h';
  if (d.inHours >= 1) return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
  return '${d.inMinutes}m';
}

String? _waitingMsLabel(Map<String, dynamic> m) {
  final v = m['time_spent_waiting_wall_ms'];
  if (v is! num) return null;
  final ms = v.round();
  if (ms <= 0) return null;
  return 'Time spent waiting (wall): ${_formatDurationShort(Duration(milliseconds: ms))}';
}

/// Policies, cases, live event bus (polling), and financial audit viewer.
class FinanceAutomationWidget extends StatefulWidget {
  const FinanceAutomationWidget({super.key});

  static String routeName = 'FinanceAutomation';
  static String routePath = '/finance-automation';

  @override
  State<FinanceAutomationWidget> createState() => _FinanceAutomationWidgetState();
}

class _FinanceAutomationWidgetState extends State<FinanceAutomationWidget> with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
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
        title: 'Finance automation',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              color: theme.secondaryBackground,
              child: TabBar(
                controller: _tabs,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Policies'),
                  Tab(text: 'Cases'),
                  Tab(text: 'Live events'),
                  Tab(text: 'Audit log'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: const [
                  _PoliciesTab(),
                  _CasesTab(),
                  _LiveEventsTab(),
                  _AuditViewTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PoliciesTab extends StatefulWidget {
  const _PoliciesTab();

  @override
  State<_PoliciesTab> createState() => _PoliciesTabState();
}

class _PoliciesTabState extends State<_PoliciesTab> {
  bool _loading = true;
  List<dynamic> _rows = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = currentAuthenticationToken;
    if (token == null) return;
    setState(() => _loading = true);
    final r = await GetAdminFinancePoliciesCall.call(token: token);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _rows = r.succeeded ? GetAdminFinancePoliciesCall.policiesList(r.jsonBody) : const [];
    });
  }

  Future<void> _toggle(int id, bool enabled) async {
    final token = currentAuthenticationToken;
    if (token == null) return;
    final r = await PatchAdminFinancePolicyCall.call(token: token, id: id, enabled: !enabled);
    if (!mounted) return;
    if (r.succeeded) await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _rows.length,
        itemBuilder: (context, i) {
          final m = _rows[i] as Map<String, dynamic>;
          final id = m['id'] as int? ?? int.tryParse('${m['id']}') ?? 0;
          final en = m['enabled'] == true || m['enabled'] == 1;
          return Card(
            child: ExpansionTile(
              title: Text(m['name']?.toString() ?? 'Policy $id'),
              subtitle: Text('priority ${m['priority']} · enabled $en'),
              trailing: Switch(
                value: en,
                onChanged: id > 0 ? (_) => _toggle(id, en) : null,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SelectableText(
                    'conditions: ${m['conditions']}\nactions: ${m['actions']}',
                    style: GoogleFonts.jetBrainsMono(fontSize: 11),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CasesTab extends StatefulWidget {
  const _CasesTab();

  @override
  State<_CasesTab> createState() => _CasesTabState();
}

class _CasesTabState extends State<_CasesTab> {
  bool _loading = true;
  List<dynamic> _rows = const [];
  Timer? _slaTicker;

  @override
  void initState() {
    super.initState();
    _load();
    _slaTicker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _slaTicker?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final token = currentAuthenticationToken;
    if (token == null) return;
    setState(() => _loading = true);
    final r = await GetAdminFinanceCasesCall.call(token: token);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _rows = r.succeeded ? GetAdminFinanceCasesCall.casesList(r.jsonBody) : const [];
    });
  }

  Future<void> _openWorkflow(int caseId) async {
    final token = currentAuthenticationToken;
    if (token == null) return;
    final r = await GetAdminFinanceCaseDetailCall.call(token: token, caseId: caseId);
    if (!mounted || !r.succeeded) return;
    final cMap = GetAdminFinanceCaseDetailCall.caseMap(r.jsonBody);
    final comments = GetAdminFinanceCaseDetailCall.commentsList(r.jsonBody);
    final pauseSegs = GetAdminFinanceCaseDetailCall.pauseSegmentsList(r.jsonBody);
    if (cMap == null) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => _CaseWorkflowDialog(
        caseId: caseId,
        caseMap: cMap,
        initialComments: comments,
        pauseSegments: pauseSegs,
        onSaved: _load,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _rows.length,
        itemBuilder: (context, i) {
          final m = _rows[i] as Map<String, dynamic>;
          final idVal = m['id'];
          final cid = idVal is int ? idVal : (idVal is num ? idVal.toInt() : int.tryParse('$idVal') ?? 0);
          final priority = '${m['priority'] ?? 'medium'}';
          final overdue = _jsonBool(m['is_overdue']);
          return Card(
            color: overdue ? Colors.red.shade50.withValues(alpha: 0.45) : null,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _casePriorityColor(priority).withValues(alpha: 0.2),
                child: Text(
                  priority.isNotEmpty ? priority[0].toUpperCase() : '?',
                  style: TextStyle(color: _casePriorityColor(priority), fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
              title: Text('${m['entity_type']} #${m['entity_id']} · ${m['status']}'),
              subtitle: Text(
                '${m['notes'] ?? ''}\nassignee: ${m['assigned_admin_id'] ?? '—'}\n${_caseSlaSubtitle(m)}\nalert: ${m['source_alert_code'] ?? '—'}',
                maxLines: 6,
              ),
              trailing: IconButton(
                tooltip: 'Workflow & timeline',
                icon: const Icon(Icons.timeline_rounded),
                onPressed: cid > 0 ? () => _openWorkflow(cid) : null,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CaseWorkflowDialog extends StatefulWidget {
  const _CaseWorkflowDialog({
    required this.caseId,
    required this.caseMap,
    required this.initialComments,
    required this.pauseSegments,
    required this.onSaved,
  });

  final int caseId;
  final Map<String, dynamic> caseMap;
  final List<dynamic> initialComments;
  final List<dynamic> pauseSegments;
  final Future<void> Function() onSaved;

  @override
  State<_CaseWorkflowDialog> createState() => _CaseWorkflowDialogState();
}

class _CaseWorkflowDialogState extends State<_CaseWorkflowDialog> {
  late String _status;
  late String _priority;
  final _assignCtl = TextEditingController();
  final _noteCtl = TextEditingController();
  final _commentCtl = TextEditingController();
  List<dynamic> _comments = const [];
  bool _busy = false;
  Timer? _slaTicker;

  @override
  void initState() {
    super.initState();
    _status = '${widget.caseMap['status'] ?? 'open'}';
    _priority = '${widget.caseMap['priority'] ?? 'medium'}';
    final aid = widget.caseMap['assigned_admin_id'];
    if (aid != null) _assignCtl.text = '$aid';
    _comments = List<dynamic>.from(widget.initialComments);
    _slaTicker = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _slaTicker?.cancel();
    _assignCtl.dispose();
    _noteCtl.dispose();
    _commentCtl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final token = currentAuthenticationToken;
    if (token == null) return;
    setState(() => _busy = true);
    final assignText = _assignCtl.text.trim();
    final aid = assignText.isEmpty ? null : int.tryParse(assignText);
    final r = await PatchAdminFinanceCaseCall.call(
      token: token,
      caseId: widget.caseId,
      status: _status,
      assignedAdminId: aid,
      notes: _noteCtl.text.trim().isEmpty ? null : _noteCtl.text.trim(),
      priority: _priority,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (r.succeeded) {
      await widget.onSaved();
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _addComment() async {
    final token = currentAuthenticationToken;
    if (token == null) return;
    final t = _commentCtl.text.trim();
    if (t.isEmpty) return;
    setState(() => _busy = true);
    final r = await PostAdminFinanceCaseCommentCall.call(token: token, caseId: widget.caseId, body: t);
    if (!mounted) return;
    setState(() => _busy = false);
    if (r.succeeded) {
      _commentCtl.clear();
      final list = GetAdminFinanceCaseDetailCall.commentsList(r.jsonBody);
      setState(() => _comments = list);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return AlertDialog(
      title: Text('Case #${widget.caseId}', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Status', style: theme.labelMedium),
              Builder(builder: (context) {
                const base = [
                  'open',
                  'investigating',
                  'escalated',
                  'waiting_on_user',
                  'waiting_on_driver',
                  'resolved',
                  'closed'
                ];
                final items = <DropdownMenuItem<String>>[
                  ...base.map((s) => DropdownMenuItem<String>(value: s, child: Text(s))),
                ];
                if (!base.contains(_status)) {
                  items.insert(0, DropdownMenuItem<String>(value: _status, child: Text(_status)));
                }
                return InputDecorator(
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _status,
                      items: items,
                      onChanged: _busy ? null : (v) => setState(() => _status = v ?? 'open'),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
              Text('Priority', style: theme.labelMedium),
              Builder(builder: (context) {
                const base = ['low', 'medium', 'high', 'critical'];
                final items = <DropdownMenuItem<String>>[
                  ...base.map((s) => DropdownMenuItem<String>(value: s, child: Text(s))),
                ];
                if (!base.contains(_priority)) {
                  items.insert(0, DropdownMenuItem<String>(value: _priority, child: Text(_priority)));
                }
                return InputDecorator(
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _priority,
                      items: items,
                      onChanged: _busy ? null : (v) => setState(() => _priority = v ?? 'medium'),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              Text(_caseSlaSubtitle(Map<String, dynamic>.from(widget.caseMap)), style: GoogleFonts.jetBrainsMono(fontSize: 11)),
              if (_waitingMsLabel(widget.caseMap) != null) ...[
                const SizedBox(height: 6),
                Text(_waitingMsLabel(widget.caseMap)!, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.blueGrey)),
              ],
              const SizedBox(height: 12),
              if (widget.pauseSegments.isNotEmpty) ...[
                Text('Pause history', style: theme.labelMedium),
                const SizedBox(height: 6),
                ...widget.pauseSegments.map((seg) {
                  if (seg is! Map) return const SizedBox.shrink();
                  final sm = Map<String, dynamic>.from(seg);
                  final start = '${sm['start_at'] ?? ''}';
                  final end = sm['end_at'] != null ? '${sm['end_at']}' : 'open';
                  final reason = '${sm['reason'] ?? 'system'}';
                  final aid = sm['assigned_admin_id'];
                  final tid = sm['team_id'];
                  final owner = aid != null ? 'admin:$aid' : 'unassigned';
                  final team = tid != null ? ' team:$tid' : '';
                  final dur = sm['duration_ms'];
                  final bm = sm['business_minutes_applied'];
                  final durStr = dur is num ? '${(dur / 1000).toStringAsFixed(1)}s wall' : '—';
                  final bmStr = bm != null ? ' · $bm biz min applied' : '';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('$start → $end · $reason · $owner$team · $durStr$bmStr', style: GoogleFonts.jetBrainsMono(fontSize: 10)),
                  );
                }),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: _assignCtl,
                decoration: const InputDecoration(labelText: 'Assigned admin id'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteCtl,
                decoration: const InputDecoration(labelText: 'Case notes (replaces notes)'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Text('Timeline', style: theme.labelMedium),
              ..._comments.map((c) {
                if (c is! Map) return const SizedBox.shrink();
                final m = Map<String, dynamic>.from(c);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${m['created_at']} · ${m['action'] ?? ''}\n${m['body']}',
                    style: GoogleFonts.jetBrainsMono(fontSize: 11),
                  ),
                );
              }),
              TextField(
                controller: _commentCtl,
                decoration: const InputDecoration(labelText: 'Add timeline comment'),
              ),
              TextButton(onPressed: _busy ? null : _addComment, child: const Text('Append comment')),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: const Text('Close')),
        FilledButton(onPressed: _busy ? null : _save, child: Text(_busy ? '…' : 'Save')),
      ],
    );
  }
}

class _LiveEventsTab extends StatefulWidget {
  const _LiveEventsTab();

  @override
  State<_LiveEventsTab> createState() => _LiveEventsTabState();
}

class _LiveEventsTabState extends State<_LiveEventsTab> {
  final _items = <Map<String, dynamic>>[];
  int _since = 0;
  bool _live = false;
  Timer? _timer;
  final AdminFinanceEventsSseClient _sse = AdminFinanceEventsSseClient();
  String? _sseStatus;

  @override
  void dispose() {
    _timer?.cancel();
    _sse.close();
    super.dispose();
  }

  void _ingestEvent(Map<String, dynamic> m) {
    final idVal = m['id'];
    final idInt = idVal is int
        ? idVal
        : (idVal is num ? idVal.toInt() : int.tryParse(idVal.toString()) ?? 0);
    if (idInt > _since) _since = idInt;
    _items.insert(0, m);
    if (_items.length > 200) _items.removeRange(200, _items.length);
  }

  Future<void> _setLive(bool v) async {
    setState(() {
      _live = v;
      if (!v) _sseStatus = null;
    });
    _timer?.cancel();
    _timer = null;
    await _sse.disconnect();
    if (v) {
      await _startSse();
    }
  }

  Future<void> _startSse() async {
    final token = currentAuthenticationToken;
    if (token == null || !mounted) return;
    setState(() => _sseStatus = 'Connecting…');
    final ok = await _sse.connect(
      token: token,
      sinceId: _since,
      onEvent: (m) {
        if (!mounted) return;
        setState(() {
          _sseStatus = 'Live (SSE)';
          _ingestEvent(m);
        });
      },
      onError: (e) {
        if (!mounted) return;
        setState(() => _sseStatus = 'SSE error — use REST refresh');
      },
    );
    if (!mounted) return;
    setState(() {
      if (ok && _live) {
        _sseStatus = 'Live (SSE)';
      } else if (_live) {
        _sseStatus = 'Could not open stream — check auth / network';
      }
    });
  }

  Future<void> _poll() async {
    final token = currentAuthenticationToken;
    if (token == null) return;
    final r = await GetAdminFinanceEventsRecentCall.call(token: token, sinceId: _since);
    if (!r.succeeded || !mounted) return;
    final list = GetAdminFinanceEventsRecentCall.eventsList(r.jsonBody);
    for (final e in list) {
      if (e is! Map) continue;
      final m = Map<String, dynamic>.from(e);
      _ingestEvent(m);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Live stream (SSE)'),
          subtitle: Text(
            _sseStatus ??
                'GET /api/admins/finance/events/stream · replay via since_id · optional Redis fan-out on server',
            style: theme.bodySmall,
          ),
          value: _live,
          onChanged: (v) {
            unawaited(_setLive(v));
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: _poll,
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Fetch recent (REST)'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _items.length,
            itemBuilder: (context, i) {
              final m = _items[i];
              return ListTile(
                dense: true,
                title: Text('${m['type']} #${m['id']}', style: GoogleFonts.jetBrainsMono(fontSize: 12)),
                subtitle: Text('${m['at']}\n${m['payload']}', maxLines: 4),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AuditViewTab extends StatefulWidget {
  const _AuditViewTab();

  @override
  State<_AuditViewTab> createState() => _AuditViewTabState();
}

class _AuditViewTabState extends State<_AuditViewTab> {
  bool _loading = true;
  List<dynamic> _rows = const [];
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = currentAuthenticationToken;
    if (token == null) return;
    setState(() => _loading = true);
    final r = await GetAdminFinanceAuditViewCall.call(token: token, page: _page, limit: 30);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _rows = r.succeeded ? GetAdminFinanceAuditViewCall.entriesList(r.jsonBody) : const [];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: _page > 1 ? () { _page--; _load(); } : null, child: const Text('Prev')),
            TextButton(onPressed: () { _page++; _load(); }, child: const Text('Next')),
          ],
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _rows.length,
            itemBuilder: (context, i) {
              final m = _rows[i] as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  dense: true,
                  title: Text('${m['action']} · ${m['action_type'] ?? ''}', style: GoogleFonts.jetBrainsMono(fontSize: 11)),
                  subtitle: Text(
                    'actor ${m['actor_type']} ${m['actor_id']}\n${m['created_at']}\nreason: ${m['reason'] ?? ''}\nmeta: ${m['metadata']}',
                    maxLines: 6,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
