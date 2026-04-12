import '/flutter_flow/flutter_flow_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Circular avatar that loads over the network without surfacing [NetworkImage] decode failures.
///
/// Missing files (404), timeouts, and bad URLs show a placeholder instead of throwing.
class SafeNetworkAvatar extends StatelessWidget {
  const SafeNetworkAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 20,
    this.placeholderIcon = Icons.person_rounded,
  });

  /// Full URL (including scheme). Empty → placeholder only.
  final String imageUrl;
  final double radius;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final trimmed = imageUrl.trim();
    final size = radius * 2;
    final iconSize = radius * 0.92;

    if (trimmed.isEmpty || trimmed == 'null') {
      return CircleAvatar(
        radius: radius,
        backgroundColor: theme.primary.withValues(alpha: 0.1),
        child: Icon(placeholderIcon, size: iconSize, color: theme.primary),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.alternate.withValues(alpha: 0.35),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: trimmed,
          width: size,
          height: size,
          fit: BoxFit.cover,
          fadeInDuration: const Duration(milliseconds: 120),
          placeholder: (_, __) => Container(
            width: size,
            height: size,
            color: theme.alternate.withValues(alpha: 0.25),
            alignment: Alignment.center,
            child: SizedBox(
              width: radius * 0.65,
              height: radius * 0.65,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.primary,
              ),
            ),
          ),
          errorWidget: (_, __, ___) => Container(
            width: size,
            height: size,
            color: theme.primary.withValues(alpha: 0.08),
            alignment: Alignment.center,
            child: Icon(placeholderIcon, size: iconSize, color: theme.primary),
          ),
        ),
      ),
    );
  }
}
