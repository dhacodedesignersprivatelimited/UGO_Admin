import 'package:equatable/equatable.dart';

class MetricTile extends Equatable {
  const MetricTile({
    required this.id,
    required this.title,
    required this.value,
    required this.deltaPercent,
    required this.trendUp,
  });

  final String id;
  final String title;
  final String value;
  final double deltaPercent;
  final bool trendUp;

  @override
  List<Object?> get props => [id, title, value, deltaPercent, trendUp];
}

class DashboardAnalytics extends Equatable {
  const DashboardAnalytics({
    required this.generatedAt,
    required this.metrics,
    required this.activeDrivers,
    required this.liveRides,
    required this.completedRides24h,
  });

  final DateTime generatedAt;
  final List<MetricTile> metrics;
  final int activeDrivers;
  final int liveRides;
  final int completedRides24h;

  @override
  List<Object?> get props =>
      [generatedAt, metrics, activeDrivers, liveRides, completedRides24h];
}
