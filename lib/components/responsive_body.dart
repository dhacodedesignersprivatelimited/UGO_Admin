import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Wraps page body content for responsive layout.
/// - Constrains max width on desktop/tablet (1200px)
/// - Centers content on wide screens
/// - Scales padding: 16 (mobile), 24 (tablet), 32 (desktop)
/// - Use with [child] as your main scrollable content
class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({
    super.key,
    required this.child,
    this.maxWidth = 1200.0,
    this.padding,
    this.scrollable = true,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets? padding;
  final bool scrollable;

  static EdgeInsets responsivePadding(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < kBreakpointSmall) return const EdgeInsets.all(16);
    if (w < kBreakpointMedium) return const EdgeInsets.all(20);
    if (w < kBreakpointLarge) return const EdgeInsets.all(24);
    return const EdgeInsets.all(32);
  }

  static double responsiveHorizontalPadding(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < kBreakpointSmall) return 16;
    if (w < kBreakpointMedium) return 20;
    if (w < kBreakpointLarge) return 24;
    return 32;
  }

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? responsivePadding(context);

    Widget content = Padding(
      padding: effectivePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );

    if (scrollable) {
      content = SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: content,
      );
    }

    return content;
  }
}

/// Wraps content with responsive padding and max width only (no scroll).
/// Use when parent provides RefreshIndicator or custom scroll.
class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 1200.0,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? ResponsiveBody.responsivePadding(context);
    return Padding(
      padding: effectivePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
