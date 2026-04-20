import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';
import '/shared/widgets/admin_pop_scope.dart';
import '/shared/widgets/admin_scaffold.dart';
import '/config/theme/flutter_flow_theme.dart';

/// SLA calendar config, team compliance, and per-admin case metrics.
class FinanceSlaDashboardWidget extends StatefulWidget {
  const FinanceSlaDashboardWidget({super.key});

  static String routeName = 'FinanceSlaDashboard';
  static String routePath = '/finance-sla-dashboard';

  @override
  State<FinanceSlaDashboardWidget> createState() => _FinanceSlaDashboardWidgetState();
}

class _FinanceSlaDashboardWidgetState extends State<FinanceSlaDashboardWidget> {
  bool _loading = true;
  Map<String, dynamic>? _metrics;
  final _tzCtl = TextEditingController();
  final _startCtl = TextEditingController();
  final _endCtl = TextEditingController();
  final _holidaysCtl = TextEditingController();
  bool _calEnabled = false;
  bool _deferEscalation = false;
  bool _savingCal = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _tzCtl.dispose();
    _startCtl.dispose();
    _endCtl.dispose();
    _holidaysCtl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final token = currentAuthenticationToken;
    if (token == null) return;
    setState(() => _loading = true);
    final from = DateTime.now().subtract(const Duration(days: 30)).toUtc().toIso8601String();
    final to = DateTime.now().toUtc().toIso8601String();
    final m = await GetAdminFinanceCaseMetricsCall.call(token: token, fromIso: from, toIso: to);
    final c = await GetAdminFinanceSlaCalendarCall.call(token: token);
    if (!mounted) return;
    final cal = GetAdminFinanceSlaCalendarCall.calendarMap(c.jsonBody);
    setState(() {
      _loading = false;
      _metrics = m.succeeded ? GetAdminFinanceCaseMetricsCall.dataMap(m.jsonBody) : null;
      if (cal != null) {
        _tzCtl.text = '${cal['timezone'] ?? 'UTC'}';
        _startCtl.text = '${cal['business_start'] ?? '09:00:00'}'.split('.').first;
        _endCtl.text = '${cal['business_end'] ?? '18:00:00'}'.split('.').first;
        final hol = cal['holidays'];
        if (hol is List) {
          _holidaysCtl.text = hol.map((e) => '$e').join(', ');
        }
        _calEnabled = cal['enabled'] == true || cal['enabled'] == 1;
        _deferEscalation = cal['defer_escalation_outside_bh'] == true || cal['defer_escalation_outside_bh'] == 1;
      }
    });
  }

  Future<void> _saveCalendar() async {
    final token = currentAuthenticationToken;
    if (token == null) return;
    final holParts = _holidaysCtl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    setState(() => _savingCal = true);
    final r = await PatchAdminFinanceSlaCalendarCall.call(
      token: token,
      timezone: _tzCtl.text.trim(),
      businessStart: _startCtl.text.trim(),
      businessEnd: _endCtl.text.trim(),
      holidays: holParts,
      enabled: _calEnabled,
      deferEscalationOutsideBh: _deferEscalation,
    );
    if (!mounted) return;
    setState(() => _savingCal = false);
    if (r.succeeded) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return AdminPopScope(
      child: AdminScaffold(
        title: 'SLA & team performance',
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('Selected window', style: theme.labelMedium),
                    Text(
                      '${_metrics?['range']?['from'] ?? '—'} → ${_metrics?['range']?['to'] ?? '—'}',
                      style: GoogleFonts.jetBrainsMono(fontSize: 11),
                    ),
                    const SizedBox(height: 16),
                    _summaryRow(theme),
                    const SizedBox(height: 12),
                    _pauseObservabilitySection(theme),
                    const SizedBox(height: 12),
                    _slaInsightsSection(theme),
                    const SizedBox(height: 12),
                    _timeLossAnalysisSection(theme),
                    const SizedBox(height: 12),
                    _forecastSummaryRow(theme),
                    const SizedBox(height: 8),
                    SizedBox(height: 140, child: _forecastBreachBar()),
                    const SizedBox(height: 8),
                    _atRiskSection(theme),
                    const SizedBox(height: 24),
                    Text('Daily SLA compliance (resolved)', style: theme.titleMedium),
                    const SizedBox(height: 8),
                    SizedBox(height: 220, child: _dailyChart()),
                    const SizedBox(height: 24),
                    Text('Cases per admin', style: theme.titleMedium),
                    const SizedBox(height: 8),
                    SizedBox(height: 200, child: _adminChart()),
                    const SizedBox(height: 24),
                    Text('Priority mix (created in window)', style: theme.titleMedium),
                    const SizedBox(height: 8),
                    SizedBox(height: 200, child: _priorityPie()),
                    const SizedBox(height: 24),
                    Text('Business calendar', style: theme.titleMedium),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('Enable business-hour SLA'),
                      subtitle: const Text('When on, new case deadlines count only business minutes.'),
                      value: _calEnabled,
                      onChanged: (v) => setState(() => _calEnabled = v),
                    ),
                    SwitchListTile(
                      title: const Text('Defer escalation outside business hours'),
                      subtitle: const Text('When on, SLA breach actions run only during configured hours.'),
                      value: _deferEscalation,
                      onChanged: (v) => setState(() => _deferEscalation = v),
                    ),
                    TextField(
                      controller: _tzCtl,
                      decoration: const InputDecoration(labelText: 'IANA timezone (e.g. Asia/Kolkata)'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _startCtl,
                            decoration: const InputDecoration(labelText: 'Business start (HH:MM:SS)'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _endCtl,
                            decoration: const InputDecoration(labelText: 'Business end (HH:MM:SS)'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _holidaysCtl,
                      decoration: const InputDecoration(
                        labelText: 'Holidays (YYYY-MM-DD, comma-separated)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _savingCal ? null : _saveCalendar,
                      child: Text(_savingCal ? 'Saving…' : 'Save calendar'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  double _hoursFromMs(dynamic v) {
    if (v is! num) return 0;
    return v / 3600000.0;
  }

  String _trendArrowUi(dynamic arrow) {
    final a = '$arrow';
    if (a == 'up') return '\u2191';
    if (a == 'down') return '\u2193';
    return '\u2192';
  }

  Widget _slaInsightsSection(FlutterFlowTheme theme) {
    final ins = _metrics?['sla_insights'] as Map<String, dynamic>?;
    if (ins == null) return const SizedBox.shrink();
    final trend = ins['trend_vs_previous_period'] as Map<String, dynamic>?;
    final pct = ins['paused_pct_by_reason'] as Map<String, dynamic>?;
    final causes = (ins['top_delay_causes'] as List?) ?? const [];
    final admins = (ins['top_admins_by_pause_ms'] as List?) ?? const [];
    final top = ins['top_reason_by_delay'] as Map<String, dynamic>?;

    String pctStr(dynamic v) {
      if (v == null) return '—';
      final n = v is num ? v.toDouble() : double.tryParse('$v');
      if (n == null) return '—';
      return '${n.toStringAsFixed(1)}%';
    }

    String deltaStr(dynamic v) {
      if (v == null) return '—';
      final n = v is num ? v.toDouble() : double.tryParse('$v');
      if (n == null) return '—';
      final s = n > 0 ? '+' : '';
      return '$s${n.toStringAsFixed(1)}%';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Auto insights & owner attribution', style: theme.titleMedium),
        const SizedBox(height: 6),
        if (pct != null)
          Text(
            '% of paused wall · user ${pctStr(pct['user'])} · driver ${pctStr(pct['driver'])} · system ${pctStr(pct['system'])}',
            style: GoogleFonts.jetBrainsMono(fontSize: 11),
          ),
        if (top != null && (top['ms'] is num ? (top['ms'] as num) > 0 : false)) ...[
          const SizedBox(height: 4),
          Text(
            'Top delay: ${top['label'] ?? top['reason']} (${_hoursFromMs(top['ms']).toStringAsFixed(2)}h paused wall)',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
        if (trend != null) ...[
          const SizedBox(height: 8),
          Text('vs previous period (same length)', style: theme.labelMedium),
          const SizedBox(height: 4),
          Text(
            'Paused wall ${_trendArrowUi(trend['paused_time_trend_arrow'])} ${deltaStr(trend['paused_time_ms_delta_pct'])} · '
            'Active ${_trendArrowUi(trend['active_time_trend_arrow'])} ${deltaStr(trend['active_time_ms_delta_pct'])} · '
            'Leading reason wall ${_trendArrowUi(trend['leading_delay_reason_trend_arrow'])} ${deltaStr(trend['leading_delay_reason_ms_delta_pct'])}',
            style: GoogleFonts.jetBrainsMono(fontSize: 10),
          ),
          Text(
            'Prev window: ${trend['previous_range']?['from'] ?? ''} \u2192 ${trend['previous_range']?['to'] ?? ''}',
            style: GoogleFonts.jetBrainsMono(fontSize: 9, color: Colors.black54),
          ),
        ],
        const SizedBox(height: 12),
        Text('Top delay causes', style: theme.labelMedium),
        const SizedBox(height: 6),
        if (causes.isEmpty)
          Text('No pause wall in cohort', style: theme.bodySmall)
        else
          ...causes.map((raw) {
            if (raw is! Map) return const SizedBox.shrink();
            final m = Map<String, dynamic>.from(raw);
            return Card(
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                dense: true,
                title: Text('${m['label'] ?? m['reason']}', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                subtitle: Text(
                  '${pctStr(m['pct_of_paused_wall'])} of paused · ${_hoursFromMs(m['ms']).toStringAsFixed(2)}h',
                  style: GoogleFonts.jetBrainsMono(fontSize: 11),
                ),
              ),
            );
          }),
        const SizedBox(height: 8),
        Text('Top admins by pause wall (segment owner at pause start)', style: theme.labelMedium),
        const SizedBox(height: 6),
        if (admins.isEmpty)
          Text('No attributed pauses (assign segments after migration)', style: theme.bodySmall)
        else
          ...admins.take(10).map((raw) {
            if (raw is! Map) return const SizedBox.shrink();
            final m = Map<String, dynamic>.from(raw);
            final aid = m['admin_id'];
            final ms = m['pause_ms'];
            final label = aid == null || aid == 0 ? 'Unassigned' : 'Admin $aid';
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '$label · ${_hoursFromMs(ms is num ? ms : 0).toStringAsFixed(2)}h',
                style: GoogleFonts.jetBrainsMono(fontSize: 11),
              ),
            );
          }),
      ],
    );
  }

  Widget _timeLossActivePausedBar() {
    final tl = _metrics?['time_loss_analysis'] as Map<String, dynamic>?;
    if (tl == null) return const SizedBox.shrink();
    final activeH = _hoursFromMs(tl['active_time_ms']);
    final pausedH = _hoursFromMs(tl['paused_time_ms']);
    final sum = activeH + pausedH;
    if (sum < 1e-9) {
      return const Center(child: Text('No cohort wall-time in window', style: TextStyle(fontSize: 12)));
    }
    final maxY = sum < 0.05 ? 1.0 : sum * 1.08;
    return BarChart(
      BarChartData(
        maxY: maxY,
        alignment: BarChartAlignment.center,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i == 0) return const Padding(padding: EdgeInsets.only(top: 8), child: Text('Cohort'));
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: sum,
                width: 40,
                borderRadius: BorderRadius.zero,
                rodStackItems: [
                  BarChartRodStackItem(0, activeH, Colors.teal.shade600),
                  BarChartRodStackItem(activeH, sum, Colors.deepOrange.shade400),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeLossReasonStackBar() {
    final tl = _metrics?['time_loss_analysis'] as Map<String, dynamic>?;
    if (tl == null) return const SizedBox.shrink();
    final pr = tl['paused_by_reason'] as Map<String, dynamic>?;
    if (pr == null) return const SizedBox.shrink();
    final u = _hoursFromMs(pr['user_delay_ms']);
    final d = _hoursFromMs(pr['driver_delay_ms']);
    final sy = _hoursFromMs(pr['system_delay_ms']);
    final sum = u + d + sy;
    if (sum < 1e-9) {
      return const Center(child: Text('No paused wall-time', style: TextStyle(fontSize: 12)));
    }
    final maxY = sum < 0.05 ? 1.0 : sum * 1.08;
    return BarChart(
      BarChartData(
        maxY: maxY,
        alignment: BarChartAlignment.center,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                if (v.toInt() == 0) {
                  return const Padding(padding: EdgeInsets.only(top: 8), child: Text('Paused wall'));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: sum,
                width: 40,
                borderRadius: BorderRadius.zero,
                rodStackItems: [
                  BarChartRodStackItem(0, u, Colors.indigo.shade500),
                  BarChartRodStackItem(u, u + d, Colors.orange.shade600),
                  BarChartRodStackItem(u + d, sum, Colors.blueGrey.shade400),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeLossDailyPausedByReason(FlutterFlowTheme theme) {
    final raw = (_metrics?['time_loss_daily'] as List?) ?? const [];
    if (raw.isEmpty) {
      return Text('No pause segments closed in this window (by end date)', style: theme.bodySmall);
    }
    final rows = raw.length > 36 ? raw.sublist(raw.length - 36) : List<dynamic>.from(raw);
    double h(dynamic m, String k) {
      if (m is! Map) return 0;
      final v = m[k];
      return v is num ? v / 3600000.0 : 0;
    }

    double maxY = 0.01;
    final groups = <BarChartGroupData>[];
    for (var i = 0; i < rows.length; i++) {
      final m = rows[i];
      final uh = h(m, 'paused_user_ms');
      final dh = h(m, 'paused_driver_ms');
      final sh = h(m, 'paused_system_ms');
      final sum = uh + dh + sh;
      if (sum > maxY) maxY = sum;
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: sum,
              width: 5,
              borderRadius: BorderRadius.zero,
              rodStackItems: [
                BarChartRodStackItem(0, uh, Colors.indigo.shade400),
                BarChartRodStackItem(uh, uh + dh, Colors.orange.shade500),
                BarChartRodStackItem(uh + dh, sum, Colors.blueGrey.shade300),
              ],
            ),
          ],
        ),
      );
    }
    maxY *= 1.15;
    return BarChart(
      BarChartData(
        maxY: maxY,
        alignment: BarChartAlignment.spaceBetween,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= rows.length) return const SizedBox.shrink();
                final m = rows[i];
                if (m is! Map) return const SizedBox.shrink();
                final ds = '${m['date'] ?? ''}';
                final short = ds.length >= 10 ? ds.substring(5, 10) : ds;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(short, style: GoogleFonts.jetBrainsMono(fontSize: 8)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        barGroups: groups,
      ),
    );
  }

  Widget _timeLossAnalysisSection(FlutterFlowTheme theme) {
    final tl = _metrics?['time_loss_analysis'] as Map<String, dynamic>?;
    if (tl == null) return const SizedBox.shrink();
    final pr = tl['paused_by_reason'] as Map<String, dynamic>?;
    String fmtH(dynamic ms) {
      final h = _hoursFromMs(ms);
      if (h < 0.01) return '${(h * 60).toStringAsFixed(0)}m';
      return '${h.toStringAsFixed(2)}h';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Time loss (cohort wall clock)', style: theme.titleMedium),
        const SizedBox(height: 6),
        Text(
          'Active ${fmtH(tl['active_time_ms'])} · Paused ${fmtH(tl['paused_time_ms'])} · Open pause (ongoing) ${fmtH(tl['open_pause_wall_ms'])}',
          style: GoogleFonts.jetBrainsMono(fontSize: 11),
        ),
        if (pr != null) ...[
          const SizedBox(height: 4),
          Text(
            'User delay ${fmtH(pr['user_delay_ms'])} · Driver ${fmtH(pr['driver_delay_ms'])} · System ${fmtH(pr['system_delay_ms'])}',
            style: GoogleFonts.jetBrainsMono(fontSize: 11),
          ),
        ],
        const SizedBox(height: 8),
        Text('Active vs paused (hours)', style: theme.labelMedium),
        SizedBox(height: 160, child: _timeLossActivePausedBar()),
        const SizedBox(height: 4),
        Row(
          children: [
            _legendDot(Colors.teal.shade600, 'Active'),
            const SizedBox(width: 12),
            _legendDot(Colors.deepOrange.shade400, 'Paused'),
          ],
        ),
        const SizedBox(height: 16),
        Text('Paused wall by reason (hours)', style: theme.labelMedium),
        SizedBox(height: 160, child: _timeLossReasonStackBar()),
        const SizedBox(height: 4),
        Row(
          children: [
            _legendDot(Colors.indigo.shade500, 'User'),
            const SizedBox(width: 10),
            _legendDot(Colors.orange.shade600, 'Driver'),
            const SizedBox(width: 10),
            _legendDot(Colors.blueGrey.shade400, 'System'),
          ],
        ),
        const SizedBox(height: 16),
        Text('Daily paused wall by reason (segment end date)', style: theme.labelMedium),
        SizedBox(height: 200, child: _timeLossDailyPausedByReason(theme)),
      ],
    );
  }

  Widget _legendDot(Color c, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, color: c),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 11)),
      ],
    );
  }

  Widget _pauseObservabilitySection(FlutterFlowTheme theme) {
    final po = _metrics?['pause_observability'] as Map<String, dynamic>?;
    if (po == null) return const SizedBox.shrink();
    final seg = po['closed_pause_segments'];
    final casesP = po['cases_with_closed_pauses'];
    final avgSeg = po['avg_pause_segment_ms'];
    final avgCase = po['avg_total_pause_ms_per_case'];
    final freq = po['pause_frequency_segments_per_case'];
    final pct = po['pct_time_paused_vs_active_wall'];
    String fmtMs(dynamic v) {
      if (v == null) return '—';
      final n = v is num ? v.toInt() : int.tryParse('$v');
      if (n == null) return '—';
      if (n < 1000) return '${n}ms';
      if (n < 60000) return '${(n / 1000).toStringAsFixed(1)}s';
      return '${(n / 60000).toStringAsFixed(1)}m';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pause observability (cohort)', style: theme.titleMedium),
        const SizedBox(height: 6),
        Text(
          'Closed segments: $seg · Cases with pauses: $casesP · Avg segment: ${fmtMs(avgSeg)} · Avg total / paused case: ${fmtMs(avgCase)}',
          style: GoogleFonts.jetBrainsMono(fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          'Pause frequency (segments / case): ${freq ?? '—'} · % wall time paused vs active: ${pct != null ? '$pct%' : '—'}',
          style: GoogleFonts.jetBrainsMono(fontSize: 11),
        ),
      ],
    );
  }

  Widget _summaryRow(FlutterFlowTheme theme) {
    final s = _metrics?['summary'] as Map<String, dynamic>?;
    if (s == null) {
      return Text('No metrics data', style: theme.bodyMedium);
    }
    final rate = s['sla_compliance_rate'];
    final avg = s['avg_resolution_sec'];
    final od = s['overdue_open_pct_current'];
    Widget card(String t, String v) => Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t, style: theme.labelSmall),
                  Text(v, style: theme.titleMedium),
                ],
              ),
            ),
          ),
        );
    return Row(
      children: [
        card('SLA compliance', rate == null ? '—' : '${(100 * (rate is num ? rate.toDouble() : double.tryParse('$rate') ?? 0)).toStringAsFixed(1)}%'),
        card('Avg resolve', avg == null ? '—' : '${(avg is num ? avg.toInt() : int.tryParse('$avg') ?? 0)} s'),
        card('Overdue (active)', od == null ? '—' : '${od is num ? od.toStringAsFixed(1) : od}%'),
        card('Resolved', '${s['resolved_in_range'] ?? 0}'),
      ],
    );
  }

  Widget _forecastSummaryRow(FlutterFlowTheme theme) {
    final fc = _metrics?['forecast'] as Map<String, dynamic>?;
    final s = _metrics?['summary'] as Map<String, dynamic>?;
    if (fc == null) return const SizedBox.shrink();
    final p2 = fc['predicted_breaches_next_2h'];
    final p4 = fc['predicted_breaches_next_4h'];
    final lp = fc['load_pressure'];
    final pauseMs = s?['total_pause_ms_cohort'];
    Widget card(String t, String v) => Expanded(
          child: Card(
            color: Colors.deepPurple.shade50,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t, style: theme.labelSmall),
                  Text(v, style: theme.titleSmall),
                ],
              ),
            ),
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Breach forecast (non-paused, SLA running)', style: theme.titleMedium),
        const SizedBox(height: 6),
        Row(
          children: [
            card('Due ≤2h', '${p2 ?? 0}'),
            card('Due ≤4h', '${p4 ?? 0}'),
            card('Load idx', lp == null ? '—' : '$lp'),
            card('Pause ms (cohort)', pauseMs == null ? '—' : '${pauseMs is num ? pauseMs.toInt() : int.tryParse('$pauseMs') ?? 0}'),
          ],
        ),
      ],
    );
  }

  Widget _forecastBreachBar() {
    final fc = _metrics?['forecast'] as Map<String, dynamic>?;
    if (fc == null) return const SizedBox.shrink();
    final p2 = (fc['predicted_breaches_next_2h'] is num) ? (fc['predicted_breaches_next_2h'] as num).toDouble() : 0.0;
    final p4 = (fc['predicted_breaches_next_4h'] is num) ? (fc['predicted_breaches_next_4h'] as num).toDouble() : 0.0;
    final maxY = (p2 > p4 ? p2 : p4) < 1 ? 4.0 : (p2 > p4 ? p2 : p4) * 1.15;
    return BarChart(
      BarChartData(
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i == 0) return const Padding(padding: EdgeInsets.only(top: 6), child: Text('≤2h'));
                if (i == 1) return const Padding(padding: EdgeInsets.only(top: 6), child: Text('≤4h'));
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [BarChartRodData(toY: p2, width: 28, color: Colors.deepPurple, borderRadius: BorderRadius.zero)],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [BarChartRodData(toY: p4, width: 28, color: Colors.deepPurple.shade300, borderRadius: BorderRadius.zero)],
          ),
        ],
      ),
    );
  }

  Widget _atRiskSection(FlutterFlowTheme theme) {
    final fc = _metrics?['forecast'] as Map<String, dynamic>?;
    final list = (fc?['at_risk_cases'] as List?) ?? const [];
    if (list.isEmpty) {
      return Text('No at-risk cases in next 8h', style: theme.bodySmall);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('At risk (due within 8h)', style: theme.titleMedium),
        const SizedBox(height: 6),
        ...list.take(12).map((raw) {
          if (raw is! Map) return const SizedBox.shrink();
          final m = Map<String, dynamic>.from(raw);
          final id = m['id'];
          final due = '${m['sla_due_at'] ?? ''}';
          final pr = '${m['priority'] ?? ''}';
          final et = '${m['entity_type']} #${m['entity_id']}';
          final dt = DateTime.tryParse(due);
          String sub = due;
          if (dt != null) {
            final left = dt.difference(DateTime.now());
            sub = '${left.inHours}h ${left.inMinutes.remainder(60)}m · $due';
          }
          return Card(
            color: Colors.orange.shade50,
            child: ListTile(
              dense: true,
              title: Text('Case $id · $et', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
              subtitle: Text('$pr · $sub', style: GoogleFonts.jetBrainsMono(fontSize: 11)),
            ),
          );
        }),
      ],
    );
  }

  Widget _dailyChart() {
    final list = (_metrics?['daily_compliance'] as List?) ?? const [];
    if (list.isEmpty) {
      return const Center(child: Text('No resolved cases in this window'));
    }
    final maxY = list.fold<double>(4.0, (m, e) {
      if (e is! Map) return m;
      final t = (e['total_resolved'] is num) ? (e['total_resolved'] as num).toDouble() : 0.0;
      return t > m ? t : m;
    });
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= list.length) return const SizedBox.shrink();
                final d = list[i] is Map ? '${(list[i] as Map)['date']}' : '';
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(d.length > 10 ? d.substring(5) : d, style: const TextStyle(fontSize: 9)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(list.length, (i) {
          final e = list[i] is Map ? list[i] as Map<String, dynamic> : <String, dynamic>{};
          final met = (e['met'] is num) ? (e['met'] as num).toDouble() : 0.0;
          final tot = (e['total_resolved'] is num) ? (e['total_resolved'] as num).toDouble() : 0.0;
          final miss = (tot - met).clamp(0.0, tot).toDouble();
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(toY: met, width: 14, color: Colors.teal, borderRadius: BorderRadius.zero),
              BarChartRodData(fromY: met, toY: met + miss, width: 14, color: Colors.orange.shade300, borderRadius: BorderRadius.zero),
            ],
          );
        }),
      ),
    );
  }

  Widget _adminChart() {
    final list = (_metrics?['cases_per_admin'] as List?) ?? const [];
    if (list.isEmpty) return const Center(child: Text('No admin assignments'));
    final top = list.take(12).toList();
    final maxY = top.fold<double>(1.0, (m, e) {
      if (e is! Map) return m;
      final c = (e['case_count'] is num) ? (e['case_count'] as num).toDouble() : 0.0;
      return c > m ? c : m;
    });
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= top.length) return const SizedBox.shrink();
                final id = top[i] is Map ? (top[i] as Map)['admin_id'] : 0;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('a$id', style: const TextStyle(fontSize: 9)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(top.length, (i) {
          final e = top[i] is Map ? top[i] as Map<String, dynamic> : <String, dynamic>{};
          final c = (e['case_count'] is num) ? (e['case_count'] as num).toDouble() : 0.0;
          return BarChartGroupData(
            x: i,
            barRods: [BarChartRodData(toY: c, width: 14, color: Colors.indigo, borderRadius: BorderRadius.zero)],
          );
        }),
      ),
    );
  }

  Widget _priorityPie() {
    final list = (_metrics?['priority_distribution'] as List?) ?? const [];
    if (list.isEmpty) return const Center(child: Text('No cases'));
    final colors = [Colors.blueGrey, Colors.amber, Colors.deepOrange, Colors.red.shade800];
    var total = 0.0;
    for (final e in list) {
      if (e is Map && e['count'] is num) total += (e['count'] as num).toDouble();
    }
    if (total <= 0) return const Center(child: Text('No cases'));
    int ci = 0;
    final sections = <PieChartSectionData>[];
    for (final e in list) {
      if (e is! Map) continue;
      final c = (e['count'] is num) ? (e['count'] as num).toDouble() : 0.0;
      if (c <= 0) continue;
      final p = '${e['priority'] ?? ''}';
      final color = colors[ci % colors.length];
      ci++;
      sections.add(
        PieChartSectionData(
          color: color,
          value: c,
          title: '$p\n${(100 * c / total).toStringAsFixed(0)}%',
          radius: 52,
          titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
        ),
      );
    }
    if (sections.isEmpty) return const Center(child: Text('No cases'));
    return PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 40, sections: sections));
  }
}
