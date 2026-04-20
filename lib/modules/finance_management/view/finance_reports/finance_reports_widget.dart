import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';
import '/shared/widgets/admin_pop_scope.dart';
import '/shared/widgets/admin_scaffold.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';

/// Finance reports: `/api/admins/finance/reports/:kind` with optional date range,
/// revenue grouping (daily / weekly / monthly), JSON view, and CSV export.
class FinanceReportsWidget extends StatefulWidget {
  const FinanceReportsWidget({super.key});

  static String routeName = 'FinanceReports';
  static String routePath = '/finance-reports';

  @override
  State<FinanceReportsWidget> createState() => _FinanceReportsWidgetState();
}

class _FinanceReportsWidgetState extends State<FinanceReportsWidget> {
  String? _busy;
  String? _result;
  dynamic _lastRoot;

  DateTime? _from;
  DateTime? _to;
  String _group = 'none';

  Future<void> _pickFrom() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _from ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _from = d);
  }

  Future<void> _pickTo() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _to ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _to = d);
  }

  String? _isoDate(DateTime? d) => d?.toIso8601String().substring(0, 10);

  Future<void> _run(String kind) async {
    final token = currentAuthenticationToken;
    if (token == null || token.isEmpty) {
      setState(() => _result = 'Not signed in');
      return;
    }
    setState(() {
      _busy = kind;
      _result = null;
      _lastRoot = null;
    });
    try {
      final fromS = _isoDate(_from);
      final toS = _isoDate(_to);
      final groupParam = (kind == 'revenue' && _group != 'none') ? _group : null;
      final r = await GetAdminFinanceReportCall.call(
        token: token,
        kind: kind,
        from: fromS,
        to: toS,
        group: groupParam,
      );
      if (!r.succeeded) {
        setState(() {
          _busy = null;
          _result =
              getJsonField(r.jsonBody, r'''$.message''')?.toString() ?? 'Request failed';
        });
        return;
      }
      const encoder = JsonEncoder.withIndent('  ');
      final pretty = encoder.convert(r.jsonBody);
      setState(() {
        _busy = null;
        _result = pretty;
        _lastRoot = r.jsonBody;
      });
    } catch (e) {
      setState(() {
        _busy = null;
        _result = e.toString();
      });
    }
  }

  String? _buildCsv() {
    final root = _lastRoot;
    if (root is! Map) return null;
    final data = root['data'];
    if (data is! Map) return null;
    final kind = data['kind']?.toString();

    if (kind == 'revenue') {
      final ts = data['revenue_time_series'];
      if (ts is Map && ts['series'] is List) {
        final series = ts['series'] as List;
        if (series.isNotEmpty) {
          final b = StringBuffer('period_key,net_platform_movement_inr\n');
          for (final row in series) {
            if (row is Map) {
              b.writeln('${row['period_key']},${row['net_platform_movement_inr']}');
            }
          }
          return b.toString();
        }
      }
      final ledger = data['ledger'];
      if (ledger is Map && ledger['by_type'] is Map) {
        final by = ledger['by_type'] as Map;
        final buf = StringBuffer('entry_type,total_inr\n');
        by.forEach((k, v) => buf.writeln('$k,$v'));
        return buf.toString();
      }
    }

    if (kind == 'payouts' && data['by_status'] is List) {
      final rows = data['by_status'] as List;
      final buf = StringBuffer('status,count,amount_inr\n');
      for (final row in rows) {
        if (row is Map) {
          buf.writeln(
            '${row['status']},${row['cnt'] ?? row['COUNT'] ?? ''},${row['amt'] ?? row['SUM(amount)'] ?? ''}',
          );
        }
      }
      return buf.toString();
    }

    if (kind == 'referrals' && data['rows'] is List) {
      final rows = data['rows'] as List;
      if (rows.isEmpty) return 'driver_referral_id,period_key,matched_pro_rides,theoretical_max_payout_inr\n';
      final buf = StringBuffer(
        'driver_referral_id,period_key,matched_pro_rides,theoretical_max_payout_inr,accrued_referrer_payout_inr\n',
      );
      for (final row in rows) {
        if (row is Map) {
          buf.writeln(
            '${row['driver_referral_id']},${row['period_key']},${row['matched_pro_rides']},${row['theoretical_max_payout_inr']},${row['accrued_referrer_payout_inr']}',
          );
        }
      }
      return buf.toString();
    }

    return null;
  }

  Future<void> _exportCsv(BuildContext context) async {
    final csv = _buildCsv();
    if (csv == null || csv.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No tabular data to export — run a report first or use JSON copy.')),
        );
      }
      return;
    }
    await Clipboard.setData(ClipboardData(text: csv));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return AdminPopScope(
      child: AdminScaffold(
        title: 'Finance reports',
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Date filters apply to revenue and payout reports. Revenue grouping adds time buckets (ledger, platform account).',
              style: theme.bodySmall.override(
                font: GoogleFonts.inter(),
                color: theme.secondaryText,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: _pickFrom,
                  child: Text(_from == null ? 'From' : _isoDate(_from)!),
                ),
                OutlinedButton(
                  onPressed: _pickTo,
                  child: Text(_to == null ? 'To' : _isoDate(_to)!),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _from = null;
                    _to = null;
                  }),
                  child: const Text('Clear dates'),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _group,
                  items: const [
                    DropdownMenuItem(value: 'none', child: Text('Revenue group: none')),
                    DropdownMenuItem(value: 'daily', child: Text('Revenue group: daily')),
                    DropdownMenuItem(value: 'weekly', child: Text('Revenue group: weekly')),
                    DropdownMenuItem(value: 'monthly', child: Text('Revenue group: monthly')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _group = v);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _tile(theme, 'Revenue (ledger)', 'finance/reports/revenue', () => _run('revenue')),
            _tile(theme, 'Payouts by status', 'finance/reports/payouts', () => _run('payouts')),
            _tile(theme, 'Referral pairs (min A,B × rate)', 'finance/reports/referrals', () => _run('referrals')),
            if (_busy != null) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(minHeight: 2),
              const SizedBox(height: 8),
              Text('Loading $_busy…', style: theme.bodySmall),
            ],
            if (_result != null) ...[
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: _result!));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copied to clipboard')),
                        );
                      }
                    },
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('Copy JSON'),
                  ),
                  TextButton.icon(
                    onPressed: () => _exportCsv(context),
                    icon: const Icon(Icons.table_rows_rounded, size: 18),
                    label: const Text('Export CSV'),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.alternate),
                ),
                child: SelectableText(
                  _result!,
                  style: GoogleFonts.jetBrainsMono(fontSize: 11),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tile(FlutterFlowTheme theme, String title, String path, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        subtitle: Text('/api/admins/$path', style: theme.bodySmall),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: _busy != null ? null : onTap,
      ),
    );
  }
}
