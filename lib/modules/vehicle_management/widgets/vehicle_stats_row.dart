import 'package:flutter/material.dart';

import '/modules/dashboard/view/dashboard_tokens.dart';
import '/modules/dashboard/widgets/metric_card.dart';

/// Stats row for vehicle management — uses plain Row (not GridView) to avoid
/// reentrant layout errors when nested inside ListView > Column.
class VehicleStatsRow extends StatelessWidget {
  const VehicleStatsRow({
    super.key,
    required this.totalTypes,
    required this.totalSubVehicles,
  });

  final int totalTypes;
  final int totalSubVehicles;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: DashboardMetricCard(
              title: 'Vehicle Types',
              value: totalTypes.toString(),
              backgroundColor: const Color(0xFFF8EAD8),
              accentColor: DashboardTokens.primaryOrange,
              icon: Icons.category_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DashboardMetricCard(
              title: 'Sub-Vehicles',
              value: totalSubVehicles.toString(),
              backgroundColor: const Color(0xFFE3F2FD),
              accentColor: DashboardTokens.metricUsersAccent,
              icon: Icons.directions_car_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DashboardMetricCard(
              title: 'Fleet Size',
              value: totalSubVehicles.toString(),
              backgroundColor: const Color(0xFFE0F7F4),
              accentColor: DashboardTokens.metricOnlineAccent,
              icon: Icons.local_taxi_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
