import 'package:flutter/material.dart';

/// Design tokens for the admin dashboard (Figma-aligned).
abstract final class DashboardTokens {
  static const Color primaryOrange = Color(0xFFFF7A00);
  static const Color pageBackground = Color(0xFFF5F6FA);

  static const double cardRadius = 14;
  static const double metricRadius = 14;

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // Metric pastel fills
  static const Color metricRidesBg = Color(0xFFEFE6DC);
  static const Color metricUsersBg = Color(0xFFE3F2FD);
  static const Color metricDriversBg = Color(0xFFFFF8E1);
  static const Color metricEarningsBg = Color(0xFFFFEBEE);
  static const Color metricWalletBg = Color(0xFFF3E5F5);
  static const Color metricOnlineBg = Color(0xFFE0F7F4);

  static const Color metricRidesAccent = Color(0xFF8D6E63);
  static const Color metricUsersAccent = Color(0xFF1976D2);
  static const Color metricDriversAccent = Color(0xFFF9A825);
  static const Color metricEarningsAccent = Color(0xFFE53935);
  static const Color metricWalletAccent = Color(0xFF7B1FA2);
  static const Color metricOnlineAccent = Color(0xFF00897B);
}
