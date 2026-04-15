import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dashboard_tokens.dart';

/// KPI tile: pastel surface, optional icon, tap ripple.
class DashboardMetricCard extends StatelessWidget {
  const DashboardMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.backgroundColor,
    required this.accentColor,
    this.icon,
    this.onTap,
  });

  final String title;
  final String value;
  final Color backgroundColor;
  final Color accentColor;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(DashboardTokens.metricRadius);
    final child = Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: radius,
        border: Border.all(
          color: accentColor.withValues(alpha: 0.28),
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              height: 1.1,
              color: const Color(0xFF111111),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return child;

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        splashColor: accentColor.withValues(alpha: 0.12),
        highlightColor: accentColor.withValues(alpha: 0.06),
        child: child,
      ),
    );
  }
}

/// Responsive metric grid: 3 columns on wide layouts, 2 on phones.
class DashboardMetricGrid extends StatelessWidget {
  const DashboardMetricGrid({
    super.key,
    required this.children,
    this.maxWidthForThreeCols = 720,
  });

  final List<Widget> children;
  final double maxWidthForThreeCols;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth >= maxWidthForThreeCols ? 3 : 2;
        return GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: cols == 3 ? 1.6 : 1.45,
          children: children,
        );
      },
    );
  }
}
