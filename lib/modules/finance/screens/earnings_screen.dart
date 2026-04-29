import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

import '/config/theme/flutter_flow_theme.dart';
import '/shared/widgets/admin_drawer.dart';
import '/shared/widgets/admin_pop_scope.dart';
import '../viewmodels/earnings_viewmodel.dart';

class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  static String routeName = 'Earnings';
  static String routePath = '/earnings';

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> {
  static final _inr = NumberFormat('#,##0.00', 'en_IN');

  double _num(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  Widget _liveFinanceHeader(
      FlutterFlowTheme theme, AsyncValue<Map<String, dynamic>> earningsAsync) {
    return earningsAsync.when(
      loading: () => Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.alternate.withOpacity(0.65)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            LinearProgressIndicator(minHeight: 2),
            SizedBox(height: 12),
            SizedBox(width: 180, child: LinearProgressIndicator(minHeight: 6)),
          ],
        ),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.error.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.error.withOpacity(0.25)),
          ),
          child: Text(error.toString(), style: TextStyle(color: theme.error)),
        ),
      ),
      data: (m) {
        final totalEarnings = _num(m['total_earnings']);
        final adminBalance = _num(m['admin_wallet_balance']);
        final totalRides = _num(m['total_rides']);
        final userStats = m['user_statistics'] is Map
            ? m['user_statistics'] as Map
            : <String, dynamic>{};
        final driverStats = m['driver_statistics'] is Map
            ? m['driver_statistics'] as Map
            : <String, dynamic>{};
        final totalUsers = _num(userStats['total']);
        final totalDrivers = _num(driverStats['total']);
        final activeDrivers = _num(driverStats['active']);

        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF7A3D), Color(0xFFFF5A2A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF7A3D).withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Platform Earnings',
                          style: theme.titleMedium.override(
                            font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '₹${_inr.format(totalEarnings)}',
                      style: theme.displaySmall.override(
                        font: GoogleFonts.interTight(fontWeight: FontWeight.w800),
                        color: Colors.white,
                        fontSize: 34,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total earnings across all rides',
                      style: theme.bodyMedium.override(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _badge('${totalRides.toInt()} Rides', Icons.directions_car_rounded),
                        _badge('${totalUsers.toInt()} Users', Icons.people_rounded),
                        _badge('Live snapshot', Icons.bolt_rounded),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _miniMetricCard(
                      title: 'Admin Wallet',
                      value: '₹${_inr.format(adminBalance)}',
                      icon: Icons.account_balance_rounded,
                      color: const Color(0xFF0066CC),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _miniMetricCard(
                      title: 'Total Rides',
                      value: totalRides.toInt().toString(),
                      icon: Icons.local_taxi_rounded,
                      color: const Color(0xFF1E8E3E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _miniMetricCard(
                      title: 'Active Drivers',
                      value: activeDrivers.toInt().toString(),
                      icon: Icons.person_rounded,
                      color: const Color(0xFFE37400),
                      subtitle: '${totalDrivers.toInt()} total',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _miniMetricCard(
                      title: 'Total Users',
                      value: totalUsers.toInt().toString(),
                      icon: Icons.group_rounded,
                      color: const Color(0xFF7B1FA2),
                      subtitle: '${_num(userStats['active']).toInt()} active',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final earningsAsync = ref.watch(earningsProvider);

    return AdminPopScope(
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          drawer: buildAdminDrawer(context),
          appBar: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primary,
            automaticallyImplyLeading: true,
            title: Text(
              'Earnings',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    font: GoogleFonts.interTight(
                      fontWeight: FlutterFlowTheme.of(context)
                          .headlineMedium
                          .fontWeight,
                      color: Colors.white,
                      fontSize: 22.0,
                    ),
                  ),
            ),
            centerTitle: true,
            elevation: 2.0,
            actions: [
              IconButton(
                onPressed: () => ref.refresh(earningsProvider),
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh',
              ),
            ],
          ),
          body: SafeArea(
            top: true,
            child: RefreshIndicator(
              onRefresh: () async => ref.refresh(earningsProvider),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _liveFinanceHeader(
                      FlutterFlowTheme.of(context), earningsAsync),
                  _buildEarningsCharts(context, earningsAsync),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEarningsCharts(
      BuildContext context, AsyncValue<Map<String, dynamic>> earningsAsync) {
    final theme = FlutterFlowTheme.of(context);
    return earningsAsync.when(
      loading: () => _chartLoading(theme),
      error: (_, __) => _chartEmpty(theme, 'Unable to load graph data.'),
      data: (m) {
        final chart = _extractEarningsSeries(m);
        if (chart.values.isEmpty) {
          return _chartEmpty(theme, 'No earnings trend data available yet.');
        }

        final maxY = chart.values.reduce(math.max);
        final minY = chart.values.reduce(math.min);
        final pad = maxY <= 0 ? 1.0 : maxY * 0.2;
        final top = (maxY + pad).clamp(1.0, double.infinity);
        final bottom = (minY - pad).clamp(0.0, double.infinity);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Earnings by Period',
              style: theme.headlineSmall.override(
                font: GoogleFonts.interTight(
                  fontWeight: theme.headlineSmall.fontWeight,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.secondaryBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.alternate.withOpacity(0.7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      const _StaticChip(label: 'Live Trend', selected: true),
                      _StaticChip(label: '${chart.values.length} points'),
                      _StaticChip(label: chart.sourceLabel),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 240,
                    child: LineChart(
                      LineChartData(
                        minY: bottom,
                        maxY: top,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: Colors.grey.withOpacity(0.2),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 46,
                              interval: top / 4,
                              getTitlesWidget: (v, _) => Text(
                                _compactMoney(v),
                                style: GoogleFonts.inter(
                                    fontSize: 10, color: Colors.grey.shade600),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (v, _) {
                                final i = v.toInt();
                                if (i < 0 || i >= chart.labels.length)
                                  return const SizedBox.shrink();
                                final isDense = chart.labels.length > 8;
                                if (isDense && i.isOdd)
                                  return const SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    chart.labels[i],
                                    style: GoogleFonts.inter(
                                        fontSize: 10,
                                        color: Colors.grey.shade700),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (_) => Colors.grey.shade900,
                            getTooltipItems: (spots) {
                              return spots.map((s) {
                                final i = s.x
                                    .toInt()
                                    .clamp(0, chart.labels.length - 1);
                                return LineTooltipItem(
                                  '${chart.labels[i]}\n₹${_inr.format(s.y)}',
                                  GoogleFonts.inter(
                                      color: Colors.white, fontSize: 12),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              for (var i = 0; i < chart.values.length; i++)
                                FlSpot(i.toDouble(), chart.values[i]),
                            ],
                            isCurved: true,
                            barWidth: 3,
                            color: const Color(0xFFFF7A3D),
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFFF7A3D).withOpacity(0.25),
                                  const Color(0xFFFF7A3D).withOpacity(0.02),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6EA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFC990)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tips_and_updates_rounded,
                      color: Color(0xFFE37400)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tip: Pull down to refresh live balances and trend points.',
                      style: theme.bodySmall
                          .override(color: const Color(0xFF8A4B00)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _chartLoading(FlutterFlowTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Earnings by Period',
          style: theme.headlineSmall.override(
            font: GoogleFonts.interTight(
                fontWeight: theme.headlineSmall.fontWeight),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.alternate.withOpacity(0.7)),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }

  Widget _chartEmpty(FlutterFlowTheme theme, String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Earnings by Period',
          style: theme.headlineSmall.override(
            font: GoogleFonts.interTight(
                fontWeight: theme.headlineSmall.fontWeight),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.alternate.withOpacity(0.7)),
          ),
          child: Text(message, style: theme.bodyMedium),
        ),
      ],
    );
  }

  _EarningsChartData _extractEarningsSeries(Map<String, dynamic> m) {
    final fromRevenueTs = _seriesFromRevenueTimeSeries(m);
    if (fromRevenueTs.values.isNotEmpty) return fromRevenueTs;

    final fromGenericList = _seriesFromGenericList(m);
    if (fromGenericList.values.isNotEmpty) return fromGenericList;

    final fromRecentTx = _seriesFromRecentTransactions(m);
    if (fromRecentTx.values.isNotEmpty) return fromRecentTx;

    return const _EarningsChartData([], [], 'No source');
  }

  _EarningsChartData _seriesFromRevenueTimeSeries(Map<String, dynamic> m) {
    final ts = m['revenue_time_series'];
    if (ts is! Map) return const _EarningsChartData([], [], 'No source');
    final series = ts['series'];
    if (series is! List) return const _EarningsChartData([], [], 'No source');

    final labels = <String>[];
    final values = <double>[];
    for (final row in series.whereType<Map>()) {
      final label =
          (row['period_key'] ?? row['date'] ?? row['label'] ?? '').toString();
      final value = _firstNum(
        row,
        const [
          'net_platform_movement_inr',
          'earnings_inr',
          'amount_inr',
          'amount',
          'total_earnings',
          'value',
        ],
      );
      if (label.isEmpty || value == null) continue;
      labels.add(_compactDateLabel(label));
      values.add(value);
    }
    return _tailSeries(labels, values, 'Revenue series');
  }

  _EarningsChartData _seriesFromGenericList(Map<String, dynamic> m) {
    final candidates = [
      m['earnings_series'],
      m['earnings_by_period'],
      m['time_series'],
      m['series'],
    ];
    for (final c in candidates) {
      if (c is! List) continue;
      final labels = <String>[];
      final values = <double>[];
      for (final row in c.whereType<Map>()) {
        final label = (row['label'] ??
                row['period'] ??
                row['period_key'] ??
                row['date'] ??
                '')
            .toString();
        final value = _firstNum(
          row,
          const [
            'value',
            'amount',
            'earnings',
            'earnings_inr',
            'net_platform_movement_inr',
            'y'
          ],
        );
        if (label.isEmpty || value == null) continue;
        labels.add(_compactDateLabel(label));
        values.add(value);
      }
      if (values.isNotEmpty)
        return _tailSeries(labels, values, 'Summary series');
    }
    return const _EarningsChartData([], [], 'No source');
  }

  _EarningsChartData _seriesFromRecentTransactions(Map<String, dynamic> m) {
    final txs = m['recent_transactions'];
    if (txs is! List) return const _EarningsChartData([], [], 'No source');

    final byDay = <String, double>{};
    for (final row in txs.whereType<Map>()) {
      final rawDate = (row['date'] ?? row['created_at'] ?? '').toString();
      if (rawDate.isEmpty) continue;
      DateTime? dt = DateTime.tryParse(rawDate);
      if (dt == null && rawDate.contains(' ')) {
        dt = DateTime.tryParse(rawDate.replaceFirst(' ', 'T'));
      }
      if (dt == null) continue;

      final key = DateFormat('MMMd').format(dt);
      final amount = _firstNum(
            row,
            const [
              'amount_inr',
              'amount',
              'net_platform_movement_inr',
              'net_amount',
              'final_fare',
              'value',
            ],
          ) ??
          1.0;

      byDay[key] = (byDay[key] ?? 0) + amount.abs();
    }

    if (byDay.isEmpty) return const _EarningsChartData([], [], 'No source');
    final labels = byDay.keys.toList();
    final values = byDay.values.toList();
    return _tailSeries(labels, values, 'Recent transactions');
  }

  _EarningsChartData _tailSeries(
      List<String> labels, List<double> values, String source) {
    if (values.length <= 8) return _EarningsChartData(labels, values, source);
    final start = values.length - 8;
    return _EarningsChartData(
        labels.sublist(start), values.sublist(start), source);
  }

  double? _firstNum(Map row, List<String> keys) {
    for (final k in keys) {
      final v = row[k];
      final n = _num(v);
      if (v != null && n != 0) return n;
    }
    for (final k in keys) {
      if (row[k] != null) return _num(row[k]);
    }
    return null;
  }

  String _compactDateLabel(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt != null) return DateFormat('MMMd').format(dt);
    if (raw.length > 6) return raw.substring(0, 6);
    return raw;
  }

  String _compactMoney(double value) {
    if (value >= 10000000) return '₹${(value / 10000000).toStringAsFixed(1)}Cr';
    if (value >= 100000) return '₹${(value / 100000).toStringAsFixed(1)}L';
    if (value >= 1000) return '₹${(value / 1000).toStringAsFixed(0)}k';
    return '₹${value.toStringAsFixed(0)}';
  }

  Widget _badge(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E6E6)),
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
                  style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.interTight(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F1F1F),
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: GoogleFonts.inter(
                  fontSize: 11, color: const Color(0xFF757575)),
            ),
        ],
      ),
    );
  }
}

class _StaticChip extends StatelessWidget {
  const _StaticChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFFFE4CC) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? const Color(0xFFFFB067) : const Color(0xFFE0E0E0),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected ? const Color(0xFFE37400) : const Color(0xFF666666),
        ),
      ),
    );
  }
}

class _EarningsChartData {
  const _EarningsChartData(this.labels, this.values, this.sourceLabel);

  final List<String> labels;
  final List<double> values;
  final String sourceLabel;
}
