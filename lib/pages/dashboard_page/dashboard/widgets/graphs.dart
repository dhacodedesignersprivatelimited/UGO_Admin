import 'dart:math' as math;

import '/flutter_flow/flutter_flow_util.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../dashboard_tokens.dart';
import '../models/dashboard_model.dart';

/// Charts carousel: earnings line, weekly rides bar, ride status pie.
class DashboardCarousel1 extends StatefulWidget {
  const DashboardCarousel1({super.key, required this.model});

  final DashboardPageModel model;

  @override
  State<DashboardCarousel1> createState() => _DashboardCarousel1State();
}

class _DashboardCarousel1State extends State<DashboardCarousel1>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  int _page = 0;
  late AnimationController _animController;
  late Animation<double> _anim;
  int? _touchedPieIndex;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant DashboardCarousel1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    final prev = oldWidget.model.chartRevision;
    final next = widget.model.chartRevision;
    if (prev != next && prev > 0) {
      _animController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _replayAnim() {
    _animController
      ..reset()
      ..forward();
  }

  String _fmtMoney(double v) {
    return formatNumber(
      v,
      formatType: FormatType.compact,
      decimalType: DecimalType.periodDecimal,
      currency: '₹',
    );
  }

  List<String> _dayLabels(int n) {
    if (n == 7) {
      return const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    }
    return List.generate(n, (i) => '${i + 1}');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.model,
      builder: (context, _) {
        final m = widget.model;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(DashboardTokens.cardRadius),
                boxShadow: DashboardTokens.cardShadow,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  if (m.chartRefreshing)
                    const LinearProgressIndicator(
                      minHeight: 2,
                      color: DashboardTokens.primaryOrange,
                    ),
                  SizedBox(
                    height: 280,
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (i) {
                        setState(() {
                          _page = i;
                          _touchedPieIndex = null;
                        });
                        _replayAnim();
                      },
                      children: [
                        _animated(_earningsPage(m)),
                        _animated(_ridesBarPage(m)),
                        _animated(_piePage(m)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DotsIndicator(
                    count: 3,
                    index: _page,
                    activeColor: DashboardTokens.primaryOrange,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _animated(Widget child) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return Opacity(
          opacity: _anim.value,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - _anim.value)),
            child: child,
          ),
        );
      },
    );
  }

  Widget _earningsPage(DashboardPageModel m) {
    final thisWeek = List<double>.from(m.earningsWeekly);
    final labels = _dayLabels(thisWeek.length);

    if (thisWeek.isEmpty || thisWeek.every((e) => e == 0)) {
      return _chartShell(
        title: 'Earnings Overview',
        trailing: const SizedBox.shrink(),
        child: _emptyChart('No earnings data'),
      );
    }

    final n = thisWeek.length;
    final spotsThis = List.generate(
      n,
      (i) => FlSpot(i.toDouble(), thisWeek[i] * _anim.value),
    );
    final allY = [...spotsThis.map((e) => e.y)];
    final maxY = allY.reduce(math.max);
    final minY = allY.reduce(math.min);
    final pad = (maxY - minY).abs() < 1 ? 8.0 : (maxY - minY) * 0.15;

    return _chartShell(
      title: 'Earnings Overview',
      trailing: const SizedBox.shrink(),
      legend: _legendDot(DashboardTokens.primaryOrange, 'Earnings'),
      child: Padding(
        padding: const EdgeInsets.only(right: 8, left: 4, top: 4),
        child: LineChart(
          LineChartData(
            minY: (minY - pad).clamp(0, double.infinity),
            maxY: maxY + pad,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (v) => FlLine(
                color: Colors.grey.withValues(alpha: 0.2),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (v, _) => Text(
                    v >= 100000
                        ? '₹${(v / 100000).toStringAsFixed(1)}L'
                        : (v >= 1000 ? '₹${(v / 1000).toStringAsFixed(0)}k' : '₹${v.toInt()}'),
                    style: GoogleFonts.inter(fontSize: 9, color: Colors.grey),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i < 0 || i >= n) return const SizedBox();
                    final lab = i < labels.length ? labels[i] : '${i + 1}';
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        lab,
                        style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ),
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => Colors.grey.shade900,
                tooltipRoundedRadius: 8,
                getTooltipItems: (spots) {
                  return spots.map((s) {
                    final idx = s.x.toInt().clamp(0, n - 1);
                    final val = thisWeek[idx];
                    return LineTooltipItem(
                      _fmtMoney(val),
                      GoogleFonts.inter(color: Colors.white, fontSize: 12),
                    );
                  }).toList();
                },
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spotsThis,
                isCurved: true,
                color: DashboardTokens.primaryOrange,
                barWidth: 3,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      DashboardTokens.primaryOrange.withValues(alpha: 0.22),
                      DashboardTokens.primaryOrange.withValues(alpha: 0.02),
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
    );
  }

  Widget _ridesBarPage(DashboardPageModel m) {
    final vals = List<double>.from(m.ridesWeekly);
    final isSeven = m.chartRideBarDays <= 7;
    final labels = isSeven ? _dayLabels(vals.length) : List.generate(vals.length, (i) => '${i + 1}');

    if (vals.isEmpty || vals.every((e) => e == 0)) {
      return _chartShell(
        title: 'Weekly Rides',
        trailing: const SizedBox(),
        child: _emptyChart('No rides in this window'),
      );
    }

    final maxY = vals.reduce(math.max);
    final cap = maxY <= 0 ? 4.0 : maxY * 1.25;

    return _chartShell(
      title: 'Weekly Rides',
      trailing: const SizedBox.shrink(),
      legend: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _legendDot(DashboardTokens.primaryOrange, 'Ride count'),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 8, 8),
        child: BarChart(
          BarChartData(
            maxY: cap,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (v) => FlLine(
                color: Colors.grey.withValues(alpha: 0.2),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
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
                    if (i < 0 || i >= vals.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        labels[i],
                        style: GoogleFonts.inter(fontSize: 9, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => Colors.grey.shade900,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final i = group.x.toInt();
                  if (i < 0 || i >= vals.length) return null;
                  return BarTooltipItem(
                    '${labels[i]}\n${vals[i].toStringAsFixed(0)} rides',
                    GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
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
                    gradient: LinearGradient(
                      colors: [
                        DashboardTokens.primaryOrange,
                        DashboardTokens.primaryOrange.withValues(alpha: 0.65),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    width: isSeven ? 14 : 12,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _piePage(DashboardPageModel m) {
    final c = m.completedPct * _anim.value;
    final o = m.ongoingPct * _anim.value;
    final x = m.cancelledPct * _anim.value;
    final sum = c + o + x;

    if (sum < 0.0001) {
      return _chartShell(
        title: 'Ride Status',
        trailing: const SizedBox(),
        child: _emptyChart('No rides for this scope'),
      );
    }

    final segments = <_PieSeg>[];
    if (c > 0.0001) {
      segments.add(_PieSeg(
        c,
        const Color(0xFF43A047),
        'Completed',
        m.statusCompletedCount,
        m.completedPct,
      ));
    }
    if (o > 0.0001) {
      segments.add(_PieSeg(
        o,
        DashboardTokens.primaryOrange,
        'Ongoing',
        m.statusOngoingCount,
        m.ongoingPct,
      ));
    }
    if (x > 0.0001) {
      segments.add(_PieSeg(
        x,
        const Color(0xFFE53935),
        'Cancelled',
        m.statusCancelledCount,
        m.cancelledPct,
      ));
    }

    return _chartShell(
      title: 'Ride Status',
      trailing: const SizedBox(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    centerSpaceRadius: 44,
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
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: segments
                  .map((s) => _pieLegendRow(s.color, s.label, s.count))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pieLegendRow(Color color, String label, int count) {
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
            '$label ($count)',
            style: GoogleFonts.inter(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color c, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[700])),
      ],
    );
  }

  Widget _chartShell({
    required String title,
    required Widget trailing,
    Widget? legend,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              trailing,
            ],
          ),
          if (legend != null) ...[
            const SizedBox(height: 8),
            legend,
          ],
          const SizedBox(height: 6),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _emptyChart(String text) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13),
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
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({
    required this.count,
    required this.index,
    required this.activeColor,
  });

  final int count;
  final int index;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 6,
          width: active ? 22 : 6,
          decoration: BoxDecoration(
            color: active ? activeColor : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }
}
