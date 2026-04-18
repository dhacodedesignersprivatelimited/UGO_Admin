import 'dart:math' as math;

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
    this.subtitle,
    this.onTap,
  });

  final String title;
  final String value;
  final Color backgroundColor;
  final Color accentColor;
  final IconData? icon;
  /// Optional muted line under [value] (e.g. share %, “Today · n”).
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(DashboardTokens.metricRadius);
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;
    final iconGap = icon != null && hasSubtitle ? 6.0 : 8.0;
    final titleValueGap = hasSubtitle ? 8.0 : 10.0;
    final iconSize = (icon != null && hasSubtitle) ? 20.0 : 22.0;

    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: iconSize,
            color: accentColor,
          ),
          SizedBox(height: iconGap),
        ],
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
        SizedBox(height: titleValueGap),
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
        if (hasSubtitle) ...[
          const SizedBox(height: 5),
          Text(
            subtitle!.trim(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.2,
              color: const Color(0xFF111111).withValues(alpha: 0.55),
            ),
          ),
        ],
      ],
    );

    final child = Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: radius,
        border: Border.all(
          color: accentColor.withValues(alpha: 0.28),
          width: 1.2,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: hasSubtitle && icon != null ? 8 : 10,
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          // Never put maxHeight on the Column: it overflows before FittedBox can scale.
          // Constrain width for wrapping; FittedBox scales the whole stack to fit height.
          final inner = ConstrainedBox(
            constraints: BoxConstraints(maxWidth: math.max(0, c.maxWidth)),
            child: column,
          );
          if (!c.hasBoundedHeight || !c.maxHeight.isFinite) {
            return inner;
          }
          return FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: inner,
          );
        },
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
    this.childAspectRatioThreeCols,
    this.childAspectRatioTwoCols,
    this.crossAxisSpacing = 16,
    this.mainAxisSpacing = 16,
  });

  final List<Widget> children;
  final double maxWidthForThreeCols;
  final double? childAspectRatioThreeCols;
  final double? childAspectRatioTwoCols;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth >= maxWidthForThreeCols ? 3 : 2;
        final ar3 = childAspectRatioThreeCols ?? 1.6;
        final ar2 = childAspectRatioTwoCols ?? 1.45;
        return GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: cols == 3 ? ar3 : ar2,
          children: children,
        );
      },
    );
  }
}
