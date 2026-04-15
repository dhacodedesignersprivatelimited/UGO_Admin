import 'package:flutter/material.dart';
import '../models/dashboard_model.dart';
import 'user_driver_stats.dart';

class DashboardCarousel2 extends StatefulWidget {
  const DashboardCarousel2({
    super.key,
    required this.model,
    this.onUserTap,
    this.onDriverTap,
  });

  final DashboardPageModel model;
  final VoidCallback? onUserTap;
  final VoidCallback? onDriverTap;

  @override
  State<DashboardCarousel2> createState() =>
      _DashboardCarousel2State();
}

class _DashboardCarousel2State
    extends State<DashboardCarousel2> {
  final PageController _controller = PageController();
  int index = 0;

  DashboardGaugeBreakdown breakdownUserStats(DashboardPageModel m) {
    final total =
        (m.usersActive + m.usersInactive + m.usersBlocked) > 0
            ? (m.usersActive + m.usersInactive + m.usersBlocked)
            : m.totalUsers;
    return DashboardGaugeBreakdown(
      displayTotal: total > 0 ? total : m.totalUsers,
      denom: total > 0 ? total : 1,
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

  DashboardGaugeBreakdown breakdownDriverStats(DashboardPageModel m) {
    final total =
        (m.driversActiveAccounts +
                    m.driversPendingKyc +
                    m.driversBlockedAccounts) >
                0
            ? (m.driversActiveAccounts +
                m.driversPendingKyc +
                m.driversBlockedAccounts)
            : m.totalDrivers;
    return DashboardGaugeBreakdown(
      displayTotal: total > 0 ? total : m.totalDrivers,
      denom: total > 0 ? total : 1,
      segments: [
        GaugeSegment(
          label: 'Active Drivers',
          count: m.driversActiveAccounts,
          arcColor: const Color(0xFF16A34A),
          legendColor: const Color(0xFF16A34A),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.model;

    return Column(
      children: [
        SizedBox(
          height: 246,
          child: PageView(
            controller: _controller,
            onPageChanged: (i) => setState(() => index = i),
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
        Row(
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
        )
      ],
    );
  }
}