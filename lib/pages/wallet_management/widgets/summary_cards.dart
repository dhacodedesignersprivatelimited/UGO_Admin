import 'package:flutter/material.dart';

class WalletSummaryCards extends StatelessWidget {
  final String totalBalance;
  final String totalCredited;
  final String totalDebited;
  final String pendingWithdrawals;

  const WalletSummaryCards({
    super.key,
    required this.totalBalance,
    required this.totalCredited,
    required this.totalDebited,
    required this.pendingWithdrawals,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: "Total Balance",
                amount: totalBalance,
                icon: Icons.account_balance_wallet,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                title: "Credited",
                amount: totalCredited,
                icon: Icons.arrow_downward,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: "Debited",
                amount: totalDebited,
                icon: Icons.arrow_upward,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                title: "Pending",
                amount: pendingWithdrawals,
                icon: Icons.hourglass_bottom,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ICON
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),

          const SizedBox(height: 10),

          /// TITLE
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),

          const SizedBox(height: 4),

          /// AMOUNT
          Text(
            "₹$amount",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}