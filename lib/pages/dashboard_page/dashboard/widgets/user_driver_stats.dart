import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ================= MODEL =================

class GaugeSegment {
  const GaugeSegment({
    required this.label,
    required this.count,
    required this.arcColor,
    required this.legendColor,
  });

  final String label;
  final int count;
  final Color arcColor;
  final Color legendColor;
}

class DashboardGaugeBreakdown {
  const DashboardGaugeBreakdown({
    required this.displayTotal,
    required this.denom,
    required this.segments,
  });

  final int displayTotal;
  final int denom;
  final List<GaugeSegment> segments;
}

/// ================= MAIN CARD =================

class StatisticsGaugeCard extends StatelessWidget {
  const StatisticsGaugeCard({
    super.key,
    required this.title,
    required this.centerSubtitle,
    required this.breakdown,
    this.padding = const EdgeInsets.fromLTRB(14, 11, 14, 10),
    this.elevated = true,
    this.onCardTap,
  });

  final String title;
  final String centerSubtitle;
  final DashboardGaugeBreakdown breakdown;
  final EdgeInsets padding;
  final bool elevated;
  final VoidCallback? onCardTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCardTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: elevated
              ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ]
              : null,
        ),
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 4,
                    child: _SemiGaugeChart(
                      breakdown: breakdown,
                      subtitle: centerSubtitle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 7,
                    child: _Legend(
                      segments: breakdown.segments,
                      denom: breakdown.denom,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ================= GAUGE =================

class _SemiGaugeChart extends StatelessWidget {
  const _SemiGaugeChart({
    required this.breakdown,
    required this.subtitle,
  });

  final DashboardGaugeBreakdown breakdown;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 156,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(142, 142),
            painter: _GaugePainter(
              segments: breakdown.segments,
              total: breakdown.denom,
              strokeWidth: 10,
            ),
          ),

          /// CENTER TEXT
          Positioned(
            bottom: 28,
            child: Column(
              children: [
                Text(
                  breakdown.displayTotal.toString(),
                  style: GoogleFonts.inter(
                    fontSize: 33,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= CUSTOM PAINTER =================

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.segments,
    required this.total,
    required this.strokeWidth,
  });

  final List<GaugeSegment> segments;
  final int total;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final basePaint = Paint()
      ..color = const Color(0xFFDDE2E8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, math.pi, math.pi, false, basePaint);

    final visibleSegments = segments.where((s) => s.count > 0).toList();
    if (visibleSegments.isEmpty || total <= 0) return;

    // Keep tiny fixed gaps between segments to avoid rounded cap overlap
    // that distorts percentages visually.
    final gap = visibleSegments.length > 1 ? 0.03 : 0.0;
    final totalGapSweep = gap * (visibleSegments.length - 1);
    final availableSweep = (math.pi - totalGapSweep).clamp(0.0, math.pi);

    double startAngle = math.pi;
    for (var i = 0; i < visibleSegments.length; i++) {
      final s = visibleSegments[i];
      final fraction = s.count / total;
      final sweep = availableSweep * fraction;
      if (sweep <= 0) continue;

      final paint = Paint()
        ..color = s.arcColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap =
            visibleSegments.length == 1 ? StrokeCap.round : StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
      if (i < visibleSegments.length - 1) {
        startAngle += gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// ================= LEGEND =================

class _Legend extends StatelessWidget {
  const _Legend({
    required this.segments,
    required this.denom,
  });

  final List<GaugeSegment> segments;
  final int denom;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: segments.map((s) {
        final pct = denom == 0 ? 0 : (s.count / denom) * 100;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: s.legendColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  s.label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF374151),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "${s.count} (${pct.toStringAsFixed(1)}%)",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4B5563),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}