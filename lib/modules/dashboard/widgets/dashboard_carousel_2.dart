import 'package:flutter/material.dart';
import '../view_model/dashboard_cubit.dart';
import 'user_driver_stats.dart';

class DashboardCarousel2 extends StatefulWidget {
  const DashboardCarousel2({
    super.key,
    required this.state,
    this.onUserTap,
    this.onDriverTap,
  });

  final DashboardState state;
  final VoidCallback? onUserTap;
  final VoidCallback? onDriverTap;

  @override
  State<DashboardCarousel2> createState() =>
      _DashboardCarousel2State();
}

class _DashboardCarousel2State
    extends State<DashboardCarousel2> {
  final PageController _controller = PageController();
  final ValueNotifier<int> _index = ValueNotifier(0);

  DashboardGaugeBreakdown breakdownUserStats(DashboardState m) {
    final total = m.totalUsers > 0 ? m.totalUsers : 1;
    return DashboardGaugeBreakdown(
      displayTotal: m.totalUsers,
      denom: total,
      segments: [
        GaugeSegment(
          label: 'Active Users',
          count: m.usersActive,
          arcColor: const Color(0xFF1976D2),
          legendColor: const Color(0xFF1976D2),
        ),
        GaugeSegment(
          label: 'Inactive Users',
          count: m.usersInactive,
          arcColor: const Color(0xFFD1D5DB),
          legendColor: const Color(0xFFD1D5DB),
        ),
        GaugeSegment(
          label: 'Blocked Users',
          count: m.usersBlocked,
          arcColor: const Color(0xFFE53935),
          legendColor: const Color(0xFFE53935),
        ),
      ],
    );
  }

  DashboardGaugeBreakdown breakdownDriverStats(DashboardState m) {
    final total = m.totalDrivers > 0 ? m.totalDrivers : 1;
    return DashboardGaugeBreakdown(
      displayTotal: m.totalDrivers,
      denom: total,
      segments: [
        GaugeSegment(
          label: 'Active Drivers',
          count: m.driversActiveAccounts,
          arcColor: const Color(0xFF16A34A),
          legendColor: const Color(0xFF16A34A),
        ),
        GaugeSegment(
          label: 'Inactive Drivers',
          count: m.driversInactiveAccounts,
          arcColor: const Color(0xFFD1D5DB),
          legendColor: const Color(0xFFD1D5DB),
        ),
        GaugeSegment(
          label: 'Pending',
          count: m.driversPendingKyc,
          arcColor: const Color(0xFFF4B400),
          legendColor: const Color(0xFFF4B400),
        ),
        GaugeSegment(
          label: 'Blocked Drivers',
          count: m.driversBlockedAccounts,
          arcColor: const Color(0xFFE53935),
          legendColor: const Color(0xFFE53935),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _index.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.state;

    return Column(
      children: [
        SizedBox(
          height: 246,
          child: PageView(
            controller: _controller,
            onPageChanged: (i) => _index.value = i,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: StatisticsGaugeCard(
                  title: 'User Statistics',
                  centerSubtitle: 'Total Users',
                  breakdown: breakdownUserStats(m),
                  onCardTap: widget.onUserTap,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: StatisticsGaugeCard(
                  title: 'Driver Statistics',
                  centerSubtitle: 'Total Drivers',
                  breakdown: breakdownDriverStats(m),
                  onCardTap: widget.onDriverTap,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        ValueListenableBuilder<int>(
          valueListenable: _index,
          builder: (_, index, __) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(2, (i) {
              final isActive = i == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 6,
                width: isActive ? 20 : 6,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFFF6B00)
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
