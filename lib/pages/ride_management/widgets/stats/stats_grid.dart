import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../dashboard_page/dashboard/dashboard_tokens.dart';
import '../../../dashboard_page/dashboard/widgets/metric_card.dart';

/// Ride KPIs using the same **DashboardMetricCard** / grid language as the home dashboard.
class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key, required this.stats});

  final Map<String, String> stats;

  String _s(String key, [String fallback = '—']) => stats[key] ?? fallback;

  static const Color _completedBg = Color(0xFFE8F5E9);
  static const Color _completedAccent = Color(0xFF2E7D32);

  List<Widget> _tiles() {
    return [
      DashboardMetricCard(
        title: 'Total Rides',
        value: _s('total_value'),
        subtitle: _s('total_footer_left', 'Today'),
        backgroundColor: DashboardTokens.metricRidesBg,
        accentColor: DashboardTokens.metricRidesAccent,
        icon: Icons.directions_car_rounded,
      ),
      DashboardMetricCard(
        title: 'Completed',
        value: _s('completed_value'),
        subtitle: _s('completed_footer_left'),
        backgroundColor: _completedBg,
        accentColor: _completedAccent,
        icon: Icons.check_circle_outline_rounded,
      ),
      DashboardMetricCard(
        title: 'Ongoing',
        value: _s('ongoing_value'),
        subtitle: _s('ongoing_footer_left'),
        backgroundColor: DashboardTokens.metricDriversBg,
        accentColor: DashboardTokens.metricDriversAccent,
        icon: Icons.schedule_rounded,
      ),
      DashboardMetricCard(
        title: 'Cancelled',
        value: _s('cancelled_value'),
        subtitle: _s('cancelled_footer_left'),
        backgroundColor: DashboardTokens.metricWalletBg,
        accentColor: DashboardTokens.metricWalletAccent,
        icon: Icons.cancel_outlined,
      ),
      DashboardMetricCard(
        title: 'Total Earnings',
        value: _s('earnings_value'),
        subtitle: _s('earnings_footer_left', 'Today'),
        backgroundColor: DashboardTokens.metricEarningsBg,
        accentColor: DashboardTokens.metricEarningsAccent,
        icon: Icons.currency_rupee_rounded,
      ),
    ];
  }

  static double _effectiveWidth(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final layoutW = constraints.maxWidth;
    final screenW = MediaQuery.sizeOf(context).width;
    return math.min(layoutW, screenW);
  }

  /// Only use a 5-across strip when each tile can stay wide enough (avoid ~80dp cells).
  static bool _useStrip(double w, double shortestSide) {
    const minTile = 112.0;
    const gaps = 4 * 12.0;
    final need = 5 * minTile + gaps;
    if (w >= need) return true;
    if (w >= 1180) return true;
    if (w >= 1040 && shortestSide >= 600) return true;
    return false;
  }

  static double _gridGap(double w) => w < 380 ? 10.0 : 16.0;

  /// Three columns only when each cell can stay ~≥118dp wide (icon + 2-line title + value).
  static double _minWidthForThreeCols(double gap) {
    const minCellW = 118.0;
    return 3 * minCellW + 2 * gap;
  }

  @override
  Widget build(BuildContext context) {
    final shortest = MediaQuery.sizeOf(context).shortestSide;

    return LayoutBuilder(
      builder: (context, c) {
        final tiles = _tiles();
        final w = _effectiveWidth(context, c);
        final strip = _useStrip(w, shortest);

        if (strip) {
          final g = w >= 1200 ? 12.0 : (w < 900 ? 10.0 : 12.0);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                if (i > 0) SizedBox(width: g),
                Expanded(child: tiles[i]),
              ],
            ],
          );
        }

        final gap = _gridGap(w);
        final min3 = _minWidthForThreeCols(gap);
        final tight = w < 380;

        // Lower width/height ratio => taller cells (more room for icon + subtitle).
        return DashboardMetricGrid(
          maxWidthForThreeCols: min3,
          crossAxisSpacing: gap,
          mainAxisSpacing: gap,
          childAspectRatioThreeCols: tight ? 0.82 : 0.92,
          childAspectRatioTwoCols: tight ? 0.95 : 1.02,
          children: tiles,
        );
      },
    );
  }
}
