import '/flutter_flow/flutter_flow_util.dart';
import '/pages/dashboard_page/dashboard_page_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChartTabs extends StatefulWidget {
  const ChartTabs({
    super.key,
    required this.model,
  });

  final DashboardPageModel model;

  @override
  State<ChartTabs> createState() => _ChartTabsState();
}

class _ChartTabsState extends State<ChartTabs> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animController;
  late Animation<double> _anim;

  int? _touchedPieIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _anim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _touchedPieIndex = null;
    });
    _animController
      ..reset()
      ..forward();
  }

  @override
  void didUpdateWidget(covariant ChartTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    final prev = oldWidget.model.chartRevision;
    final next = widget.model.chartRevision;
    // Skip 0→1 so we don't replay after the initial dashboard load (initState already ran).
    if (prev != next && prev > 0) {
      _animController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _animController.dispose();
    super.dispose();
  }

  String _fmtMoney(double v) {
    return formatNumber(
      v,
      formatType: FormatType.compact,
      decimalType: DecimalType.periodDecimal,
      currency: '₹',
    );
  }

  String _periodLabel(String raw) {
    if (raw.isEmpty) return raw;
    return raw[0].toUpperCase() + raw.substring(1);
  }

  Widget _filterBar() {
    final i = _tabController.index;
    final m = widget.model;

    if (i == 0) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Period',
              style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[600]),
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: DashboardPageModel.earningsPeriodOptions.map((p) {
                  final selected = m.chartEarningsPeriod == p;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_periodLabel(p)),
                      selected: selected,
                      onSelected: (_) => m.setChartEarningsPeriod(p),
                      selectedColor: Colors.orange.shade200,
                      checkmarkColor: Colors.deepOrange,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vehicles',
              style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[600]),
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('All vehicles'),
                      selected: m.chartVehicleId == null,
                      onSelected: (_) => m.setChartVehicleFilter(null),
                      selectedColor: Colors.orange.shade200,
                      checkmarkColor: Colors.deepOrange,
                    ),
                  ),
                  ...m.chartAdminVehicles.map((v) {
                    final id = int.tryParse(v['id']?.toString() ?? '');
                    if (id == null) return const SizedBox.shrink();
                    final name =
                        v['vehicle_name']?.toString() ?? 'Vehicle $id';
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(name),
                        selected: m.chartVehicleId == id,
                        onSelected: (_) => m.setChartVehicleFilter(id),
                        selectedColor: Colors.orange.shade200,
                        checkmarkColor: Colors.deepOrange,
                      ),
                    );
                  }),
                ],
              ),
            ),
            if (m.chartAdminVehicles.isEmpty &&
                !m.isLoading &&
                !m.chartRefreshing)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'No admin vehicles in response — check GET /admins/.../vehicles',
                  style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[500]),
                ),
              ),
          ],
        ),
      );
    }

    if (i == 1) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Window',
              style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[600]),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('7 days'),
                  selected: m.chartRideBarDays == 7,
                  onSelected: (_) => m.setChartRideBarDays(7),
                  selectedColor: Colors.orange.shade200,
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('30 days'),
                  selected: m.chartRideBarDays == 30,
                  onSelected: (_) => m.setChartRideBarDays(30),
                  selectedColor: Colors.orange.shade200,
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scope',
            style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[600]),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              ChoiceChip(
                label: const Text('All time'),
                selected: m.chartStatusDays == 0,
                onSelected: (_) => m.setChartStatusWindow(0),
                selectedColor: Colors.orange.shade200,
              ),
              ChoiceChip(
                label: const Text('Last 7 days'),
                selected: m.chartStatusDays == 7,
                onSelected: (_) => m.setChartStatusWindow(7),
                selectedColor: Colors.orange.shade200,
              ),
              ChoiceChip(
                label: const Text('Last 30 days'),
                selected: m.chartStatusDays == 30,
                onSelected: (_) => m.setChartStatusWindow(30),
                selectedColor: Colors.orange.shade200,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.model,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Earnings'),
                  Tab(text: 'Ride overview'),
                  Tab(text: 'Status'),
                ],
              ),
              _filterBar(),
              if (widget.model.chartRefreshing)
                const LinearProgressIndicator(minHeight: 2),
              SizedBox(
                height: 240,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _animatedWrapper(_earningsChart()),
                    _animatedWrapper(_ridesBarChart()),
                    _animatedWrapper(_statusPie()),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _animatedWrapper(Widget child) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return Opacity(
          opacity: _anim.value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - _anim.value)),
            child: child,
          ),
        );
      },
    );
  }

  List<FlSpot> _spotsFromSeries(List<double> values) {
    if (values.isEmpty) {
      return [const FlSpot(0, 0), const FlSpot(1, 0)];
    }
    final v = values.length == 1 ? [values.first, values.first] : values;
    return List.generate(v.length, (i) => FlSpot(i.toDouble(), v[i]));
  }

  FlTitlesData _lineTitles(int n) {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 36,
          getTitlesWidget: (v, _) => Text(
            v >= 1000 ? '${(v / 1000).toStringAsFixed(0)}k' : v.toInt().toString(),
            style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (v, _) {
            final i = v.toInt();
            if (i < 0 || i >= n) return const SizedBox();
            return Text(
              '${i + 1}',
              style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
            );
          },
        ),
      ),
    );
  }

  FlTitlesData _barTitles(int n, {required bool isWeeklyBuckets}) {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          getTitlesWidget: (v, _) => Text(
            v.toInt().toString(),
            style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (v, _) {
            final i = v.toInt();
            if (i < 0 || i >= n) return const SizedBox();
            final label = isWeeklyBuckets
                ? 'D${i + 1}'
                : '${i * 3 + 1}–${(i + 1) * 3}d';
            return Text(
              label,
              style: GoogleFonts.inter(fontSize: 9, color: Colors.grey),
            );
          },
        ),
      ),
    );
  }

  Widget _earningsChart() {
    final vals = List<double>.from(widget.model.earningsWeekly);
    if (vals.isEmpty || vals.every((e) => e == 0)) {
      return _empty('No earnings data for this filter');
    }

    final spots = _spotsFromSeries(vals);
    final animatedSpots = spots
        .map((e) => FlSpot(e.x, e.y * _anim.value))
        .toList();

    final ys = vals.map((e) => e * _anim.value);
    final maxY = ys.reduce((a, b) => a > b ? a : b);
    final minY = ys.reduce((a, b) => a < b ? a : b);
    final pad = (maxY - minY).abs() < 1 ? 8.0 : (maxY - minY) * 0.12;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: LineChart(
        LineChartData(
          minY: (minY - pad).clamp(0, double.infinity),
          maxY: maxY + pad,
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: _lineTitles(vals.length),
          lineTouchData: LineTouchData(
            enabled: true,
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => Colors.grey.shade900,
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              tooltipRoundedRadius: 8,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((s) {
                  final idx = s.x.toInt().clamp(0, vals.length - 1);
                  final raw = vals[idx];
                  return LineTooltipItem(
                    '${widget.model.chartSelectedVehicleLabel}\n${_periodLabel(widget.model.chartEarningsPeriod)} · ${idx + 1}\n${_fmtMoney(raw)}',
                    GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: animatedSpots,
              isCurved: true,
              gradient: const LinearGradient(
                colors: [Colors.orange, Colors.deepOrange],
              ),
              barWidth: 3.5,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withValues(alpha: 0.28),
                    Colors.orange.withValues(alpha: 0.04),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ridesBarChart() {
    final vals = List<double>.from(widget.model.ridesWeekly);
    if (vals.isEmpty || vals.every((e) => e == 0)) {
      return _empty('No rides in this window');
    }

    final maxY = vals.reduce((a, b) => a > b ? a : b);
    final cap = maxY <= 0 ? 4.0 : maxY * 1.25;
    final isSeven = widget.model.chartRideBarDays <= 7;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: BarChart(
        BarChartData(
          maxY: cap,
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: _barTitles(vals.length, isWeeklyBuckets: isSeven),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Colors.grey.shade900,
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final i = group.x.toInt();
                if (i < 0 || i >= vals.length) return null;
                final count = vals[i];
                final label = isSeven
                    ? 'Day ${i + 1}'
                    : 'Bucket ${i + 1} (~3 days each)';
                return BarTooltipItem(
                  '$label\n${count.toStringAsFixed(0)} rides',
                  GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    height: 1.3,
                  ),
                );
              },
            ),
          ),
          barGroups: List.generate(
            vals.length,
            (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: vals[i] * _anim.value,
                  gradient: const LinearGradient(
                    colors: [Colors.deepOrange, Colors.orange],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: isSeven ? 16 : 14,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusPie() {
    final m = widget.model;
    final c = m.completedPct * _anim.value;
    final o = m.ongoingPct * _anim.value;
    final x = m.cancelledPct * _anim.value;
    final sum = c + o + x;

    if (sum < 0.0001) {
      return _empty('No rides for this scope');
    }

    final segments = <_PieSeg>[];
    if (c > 0.0001) {
      segments.add(_PieSeg(
        c,
        Colors.green,
        'Completed',
        m.statusCompletedCount,
        m.completedPct,
      ));
    }
    if (o > 0.0001) {
      segments.add(_PieSeg(
        o,
        Colors.blue,
        'Ongoing',
        m.statusOngoingCount,
        m.ongoingPct,
      ));
    }
    if (x > 0.0001) {
      segments.add(_PieSeg(
        x,
        Colors.redAccent,
        'Cancelled',
        m.statusCancelledCount,
        m.cancelledPct,
      ));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 42,
                      sectionsSpace: 2,
                      pieTouchData: PieTouchData(
                        enabled: true,
                        touchCallback: (event, response) {
                          if (!event.isInterestedForInteractions) {
                            setState(() => _touchedPieIndex = null);
                            return;
                          }
                          setState(() {
                            _touchedPieIndex =
                                response?.touchedSection?.touchedSectionIndex;
                          });
                        },
                      ),
                      sections: List.generate(
                        segments.length,
                        (i) => PieChartSectionData(
                          value: segments[i].value,
                          color: segments[i].color,
                          radius: _touchedPieIndex == i ? 58 : 50,
                          title: '${(segments[i].fraction * 100).toStringAsFixed(0)}%',
                          titleStyle: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: segments
                    .map((s) => _legend(s.color, s.label, s.count))
                    .toList(),
              ),
            ],
          ),
          if (_touchedPieIndex != null &&
              _touchedPieIndex! >= 0 &&
              _touchedPieIndex! < segments.length)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Material(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: Colors.grey[800]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          segments[_touchedPieIndex!].tooltipLine,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
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

  Widget _legend(Color color, String text, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$text ($count)',
            style: GoogleFonts.inter(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _empty(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13),
        ),
      ),
    );
  }
}

class _PieSeg {
  _PieSeg(this.value, this.color, this.label, this.count, this.fraction);

  final double value;
  final Color color;
  final String label;
  final int count;
  final double fraction;

  String get tooltipLine =>
      '$label: $count rides · ${(fraction * 100).toStringAsFixed(1)}% of filtered set';
}
