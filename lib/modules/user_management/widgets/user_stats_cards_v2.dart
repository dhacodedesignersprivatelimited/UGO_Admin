import 'package:flutter/material.dart';

import '/config/theme/flutter_flow_util.dart';
import '/modules/dashboard/view/dashboard_tokens.dart';
import '/modules/dashboard/widgets/metric_card.dart';

class UserStatsCardsV2 extends StatelessWidget {
  const UserStatsCardsV2({
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

    // Use a plain Row instead of DashboardMetricGrid (GridView inside LayoutBuilder)
    // to avoid reentrant layout errors when nested inside ListView > Column.
    return SizedBox(
      height: 110,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: DashboardMetricCard(
              title: 'Total Users',
              value: fmt(total),
              backgroundColor: const Color(0xFFF8EAD8),
              accentColor: DashboardTokens.metricUsersAccent,
              icon: Icons.groups_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DashboardMetricCard(
              title: 'Active Users',
              value: fmt(active),
              backgroundColor: const Color(0xFFD6F0D2),
              accentColor: const Color(0xFF2E7D32),
              icon: Icons.check_circle_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DashboardMetricCard(
              title: 'Blocked Users',
              value: fmt(blocked),
              backgroundColor: const Color(0xFFF4D0D0),
              accentColor: const Color(0xFFC62828),
              icon: Icons.block_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
