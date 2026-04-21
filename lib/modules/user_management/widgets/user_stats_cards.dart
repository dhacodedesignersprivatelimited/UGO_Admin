import 'package:flutter/material.dart';
import '/config/theme/flutter_flow_util.dart';

import '/modules/dashboard/view/dashboard_tokens.dart';
import '/modules/dashboard/widgets/metric_card.dart';

class UserStatsCards extends StatelessWidget {
  const UserStatsCards({
    super.key,
    required this.total,
    required this.active,
    required this.blocked,
  });

  final int total;
  final int active;
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
          title: 'Total Users',
          value: fmt(total),
          backgroundColor: const Color(0xFFF8EAD8),
          accentColor: DashboardTokens.metricUsersAccent,
          icon: Icons.groups_rounded,
        ),
        DashboardMetricCard(
          title: 'Active Users',
          value: fmt(active),
          backgroundColor: const Color(0xFFD6F0D2),
          accentColor: const Color(0xFF2E7D32),
          icon: Icons.check_circle_rounded,
        ),
        DashboardMetricCard(
          title: 'Blocked Users',
          value: fmt(blocked),
          backgroundColor: const Color(0xFFF4D0D0),
          accentColor: const Color(0xFFC62828),
          icon: Icons.block_rounded,
        ),
      ],
    );
  }
}