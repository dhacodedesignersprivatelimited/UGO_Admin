import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '/shared/widgets/admin_pop_scope.dart';
import '/shared/widgets/admin_scaffold.dart';
import '/config/theme/flutter_flow_theme.dart';
import '../viewmodels/reports_viewmodel.dart';

class FinanceReportsScreen extends ConsumerStatefulWidget {
  const FinanceReportsScreen({super.key});

  static String routeName = 'FinanceReports';
  static String routePath = '/finance-reports';

  @override
  ConsumerState<FinanceReportsScreen> createState() =>
      _FinanceReportsScreenState();
}

class _FinanceReportsScreenState extends ConsumerState<FinanceReportsScreen> {
  DateTime? _from;
  DateTime? _to;
  String _group = 'none';
  static final _inr = NumberFormat('#,##0.00', 'en_IN');

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
    final fromS = _isoDate(_from);
    final toS = _isoDate(_to);
    await ref.read(reportsProvider.notifier).runReport(
          kind: kind,
          from: fromS,
          to: toS,
          group: _group,
        );
  }

  String? _buildCsv(dynamic root) {
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
              b.writeln(
                  '${row['period_key']},${row['net_platform_movement_inr']}');
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
              '${row['status']},${row['cnt'] ?? row['COUNT'] ?? ''},${row['amt'] ?? row['SUM(amount)'] ?? ''}');
        }
      }
      return buf.toString();
    }

    if (kind == 'referrals' && data['rows'] is List) {
      final rows = data['rows'] as List;
      if (rows.isEmpty)
        return 'driver_referral_id,period_key,matched_pro_rides,theoretical_max_payout_inr\n';
      final buf = StringBuffer(
          'driver_referral_id,period_key,matched_pro_rides,theoretical_max_payout_inr,accrued_referrer_payout_inr\n');
      for (final row in rows) {
        if (row is Map) {
          buf.writeln(
              '${row['driver_referral_id']},${row['period_key']},${row['matched_pro_rides']},${row['theoretical_max_payout_inr']},${row['accrued_referrer_payout_inr']}');
        }
      }
      return buf.toString();
    }

    return null;
  }

  Future<void> _exportCsv(BuildContext context, dynamic root) async {
    final csv = _buildCsv(root);
    if (csv == null || csv.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'No tabular data to export — run a report first or use JSON copy.')));
      }
      return;
    }
    await Clipboard.setData(ClipboardData(text: csv));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CSV copied to clipboard')));
    }
  }

  String? _formatPrettyJson(dynamic data) {
    if (data == null) return null;
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }

  double _asDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  String _money(dynamic v) => '₹${_inr.format(_asDouble(v))}';

  Widget _metricCard(
    FlutterFlowTheme theme, {
    required String title,
    required String value,
    required IconData icon,
    Color color = const Color(0xFFFF6B35),
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.bodySmall.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.interTight(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F1F1F),
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: theme.bodySmall.override(color: theme.secondaryText),
            ),
        ],
      ),
    );
  }

  Widget _buildRevenueView(FlutterFlowTheme theme, Map<String, dynamic> data) {
    final ledger = data['ledger'] as Map?;
    if (ledger == null) {
      return _emptyReportCard(
          theme, 'No revenue data available for selected period.');
    }

    final byType = ledger['by_type'] as Map?;
    final entries = byType?.entries.toList() ?? const [];
    final maxVal = entries.isEmpty
        ? 1.0
        : entries
            .map((e) => _asDouble(e.value))
            .reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _metricCard(
                theme,
                title: 'Net Platform Movement',
                value: _money(ledger['net_platform_movement_inr']),
                icon: Icons.trending_up_rounded,
                color: const Color(0xFF1E8E3E),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metricCard(
                theme,
                title: 'Commission Ledger',
                value: _money(ledger['total_commission_ledger_inr']),
                icon: Icons.account_balance_wallet_rounded,
                color: const Color(0xFF1976D2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _metricCard(
                theme,
                title: 'Referral Pool In',
                value: _money(ledger['total_referral_pool_in_inr']),
                icon: Icons.groups_rounded,
                color: const Color(0xFF7B1FA2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metricCard(
                theme,
                title: 'Referral Match Payout',
                value: _money(ledger['total_referral_match_payout_inr']),
                icon: Icons.paid_rounded,
                color: const Color(0xFFE37400),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.alternate),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ledger by Type',
                style: theme.titleSmall.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 10),
              if (entries.isEmpty)
                Text('No breakdown available', style: theme.bodySmall)
              else
                ...entries.map((e) {
                  final amount = _asDouble(e.value);
                  final ratio =
                      maxVal <= 0 ? 0.0 : (amount / maxVal).clamp(0.0, 1.0);
                  final label = e.key.toString().replaceAll('_', ' ');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                label,
                                style: theme.bodySmall.override(
                                  font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            Text(_money(amount), style: theme.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade300,
                            valueColor:
                                const AlwaysStoppedAnimation(Color(0xFFFF7A3D)),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPayoutsView(FlutterFlowTheme theme, Map<String, dynamic> data) {
    final rows =
        (data['by_status'] as List?)?.whereType<Map>().toList() ?? const [];
    if (rows.isEmpty) {
      return _emptyReportCard(theme, 'No payouts in this period.');
    }

    final totalCount = rows.fold<int>(0, (sum, r) => sum + _asInt(r['cnt']));
    final totalAmt =
        rows.fold<double>(0, (sum, r) => sum + _asDouble(r['amt']));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _metricCard(
                theme,
                title: 'Total Payout Requests',
                value: '$totalCount',
                icon: Icons.receipt_long_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metricCard(
                theme,
                title: 'Total Amount',
                value: _money(totalAmt),
                icon: Icons.currency_rupee_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.alternate),
          ),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text('Status', style: theme.labelMedium)),
                    SizedBox(
                        width: 70,
                        child: Text('Count',
                            style: theme.labelMedium,
                            textAlign: TextAlign.right)),
                    const SizedBox(width: 10),
                    SizedBox(
                        width: 120,
                        child: Text('Amount',
                            style: theme.labelMedium,
                            textAlign: TextAlign.right)),
                  ],
                ),
              ),
              ...rows.map((r) {
                final status =
                    (r['status'] ?? '-').toString().replaceAll('_', ' ');
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFFE6E6E6))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          status,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        width: 70,
                        child: Text('${_asInt(r['cnt'])}',
                            textAlign: TextAlign.right),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 120,
                        child:
                            Text(_money(r['amt']), textAlign: TextAlign.right),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReferralsView(
      FlutterFlowTheme theme, Map<String, dynamic> data) {
    final rows = (data['rows'] as List?)?.whereType<Map>().toList() ?? const [];
    final rate = data['rate_inr_per_match'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _metricCard(
          theme,
          title: 'Referral Rate per Match',
          value: _money(rate),
          icon: Icons.hub_rounded,
          color: const Color(0xFF7B1FA2),
        ),
        const SizedBox(height: 12),
        if (rows.isEmpty)
          _emptyReportCard(
              theme, 'No referral payout rows found for selected period.')
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.alternate),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Referral Rows', style: theme.titleSmall),
                const SizedBox(height: 8),
                ...rows.take(20).map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '#${r['driver_referral_id']}  ·  ${r['period_key']}  ·  rides ${r['matched_pro_rides']}  ·  payout ${_money(r['accrued_referrer_payout_inr'])}',
                          style: GoogleFonts.inter(fontSize: 12),
                        ),
                      ),
                    ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _emptyReportCard(FlutterFlowTheme theme, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate),
      ),
      child: Text(message, style: theme.bodyMedium),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final reportAsync = ref.watch(reportsProvider);

    return AdminPopScope(
      child: AdminScaffold(
        title: 'Finance reports',
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton(
                    onPressed: _pickFrom,
                    child: Text(_from == null ? 'From' : _isoDate(_from)!)),
                OutlinedButton(
                    onPressed: _pickTo,
                    child: Text(_to == null ? 'To' : _isoDate(_to)!)),
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
                    DropdownMenuItem(
                        value: 'none', child: Text('Revenue group: none')),
                    DropdownMenuItem(
                        value: 'daily', child: Text('Revenue group: daily')),
                    DropdownMenuItem(
                        value: 'weekly', child: Text('Revenue group: weekly')),
                    DropdownMenuItem(
                        value: 'monthly',
                        child: Text('Revenue group: monthly')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _group = v);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _tile(
                theme, 'Revenue', () => _run('revenue'), reportAsync.isLoading),
            _tile(theme, 'Payouts by status', () => _run('payouts'),
                reportAsync.isLoading),
            _tile(theme, 'Referral pairs', () => _run('referrals'),
                reportAsync.isLoading),
            reportAsync.when(
              loading: () => Column(
                children: [
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(minHeight: 2),
                  const SizedBox(height: 8),
                  Text('Loading...', style: theme.bodySmall),
                ],
              ),
              error: (err, stack) => Padding(
                padding: const EdgeInsets.only(top: 16),
                child:
                    Text('Error: $err', style: TextStyle(color: theme.error)),
              ),
              data: (state) {
                final prettyJson = _formatPrettyJson(state.data);
                if (prettyJson == null) return const SizedBox.shrink();

                final root = state.data;
                final data = (root is Map && root['data'] is Map)
                    ? Map<String, dynamic>.from(root['data'] as Map)
                    : <String, dynamic>{};
                final kind =
                    (data['kind'] ?? state.reportKind ?? '').toString();

                return Column(
                  children: [
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1E6),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Report: ${kind.isEmpty ? 'unknown' : kind}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFFE37400),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (kind == 'revenue') _buildRevenueView(theme, data),
                    if (kind == 'payouts') _buildPayoutsView(theme, data),
                    if (kind == 'referrals') _buildReferralsView(theme, data),
                    if (kind != 'revenue' &&
                        kind != 'payouts' &&
                        kind != 'referrals')
                      _emptyReportCard(
                          theme, 'Unsupported report response format.'),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8,
                      children: [
                        TextButton.icon(
                          onPressed: () => _exportCsv(context, state.data),
                          icon: const Icon(Icons.table_rows_rounded, size: 18),
                          label: const Text('Export CSV'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(FlutterFlowTheme theme, String title, VoidCallback onTap,
      bool isLoading) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title:
            Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: isLoading ? null : onTap,
      ),
    );
  }
}
