import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_util.dart';

import '../../dashboard_page/dashboard/dashboard_tokens.dart';
import '../../dashboard_page/dashboard/widgets/metric_card.dart';

class DriverStatsCards extends StatelessWidget {
  const DriverStatsCards({
    super.key,
    required this.total,
    required this.active,
    required this.online,
    required this.pending,
    required this.blocked,
  });

  final int total;
  final int active;
  final int online;
  final int pending;
  final int blocked;

  @override
  Widget build(BuildContext context) {
    String fmt(int n) => formatNumber(
          n,
          formatType: FormatType.decimal,
          decimalType: DecimalType.automatic,
        );

    return DashboardMetricGrid(
      maxWidthForThreeCols: 860,
      childAspectRatioThreeCols: 1.85,
      childAspectRatioTwoCols: 1.65,
      children: [
        DashboardMetricCard(
          title: 'Total Drivers',
          value: fmt(total),
          backgroundColor: const Color(0xFFF8EAD8),
          accentColor: DashboardTokens.metricRidesAccent,
          icon: Icons.groups_rounded,
        ),
        DashboardMetricCard(
          title: 'Active Drivers',
          value: fmt(active),
          backgroundColor: const Color(0xFFD6F0D2),
          accentColor: const Color(0xFF2E7D32),
          icon: Icons.check_circle_rounded,
        ),
        DashboardMetricCard(
          title: 'Online Drivers',
          value: fmt(online),
          backgroundColor: const Color(0xFFF5EFBE),
          accentColor: const Color(0xFF00897B),
          icon: Icons.wifi_tethering_rounded,
        ),
        DashboardMetricCard(
          title: 'Pending Approvals',
          value: fmt(pending),
          backgroundColor: const Color(0xFFE3DDF7),
          accentColor: const Color(0xFF5E35B1),
          icon: Icons.pending_actions_rounded,
        ),
        DashboardMetricCard(
          title: 'Blocked Drivers',
          value: fmt(blocked),
          backgroundColor: const Color(0xFFF4D0D0),
          accentColor: const Color(0xFFC62828),
          icon: Icons.block_rounded,
        ),
      ],
    );
  }
}
