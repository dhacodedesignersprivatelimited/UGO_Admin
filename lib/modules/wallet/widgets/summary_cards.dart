import 'package:flutter/material.dart';
import '/modules/dashboard/widgets/metric_card.dart';

class WalletSummaryCards extends StatelessWidget {
  final String totalBalance;
  final String totalCredited;
  final String totalDebited;
  final String pendingWithdrawals;
  final int pendingWithdrawalsCount;

  const WalletSummaryCards({
    super.key,
    required this.totalBalance,
    required this.totalCredited,
    required this.totalDebited,
    required this.pendingWithdrawals,
    this.pendingWithdrawalsCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardMetricGrid(
      maxWidthForThreeCols: 860,
      childAspectRatioThreeCols: 1.85,
      childAspectRatioTwoCols: 1.65,
      children: [
        DashboardMetricCard(
          title: 'Total Wallet',
          value: '₹$totalBalance',
          backgroundColor: const Color(0xFFD6F0D2),
          accentColor: const Color(0xFF2E7D32),
          icon: Icons.account_balance_wallet_rounded,
        ),
        DashboardMetricCard(
          title: 'Total Credited',
          value: '₹$totalCredited',
          backgroundColor: const Color(0xFFD0E8FF),
          accentColor: const Color(0xFF1565C0),
          icon: Icons.arrow_circle_down_rounded,
        ),
        DashboardMetricCard(
          title: 'Total Debited',
          value: '₹$totalDebited',
          backgroundColor: const Color(0xFFF4D0D0),
          accentColor: const Color(0xFFC62828),
          icon: Icons.arrow_circle_up_rounded,
        ),
        DashboardMetricCard(
          title: 'Pending (WD)',
          value: '₹$pendingWithdrawals',
          backgroundColor: const Color(0xFFE3DDF7),
          accentColor: const Color(0xFF5E35B1),
          icon: Icons.pending_actions_rounded,
          subtitle: pendingWithdrawalsCount > 0 ? '$pendingWithdrawalsCount pending' : null,
        ),
      ],
    );
  }
}
