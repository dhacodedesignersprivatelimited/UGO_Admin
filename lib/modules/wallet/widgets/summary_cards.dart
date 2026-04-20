import 'package:flutter/material.dart';

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
    final items = [
      _SummaryData(
        title: 'Total Wallet',
        amount: totalBalance,
        background: const Color(0xFFEAF7EE),
        border: const Color(0xFFB9DFC4),
        amountColor: const Color(0xFF2E7D32),
      ),
      _SummaryData(
        title: 'Total Credited',
        amount: totalCredited,
        background: const Color(0xFFE9F0FD),
        border: const Color(0xFFBED0F5),
        amountColor: const Color(0xFF1565C0),
      ),
      _SummaryData(
        title: 'Total Debited',
        amount: totalDebited,
        background: const Color(0xFFFDECEC),
        border: const Color(0xFFF5C2C2),
        amountColor: const Color(0xFFC62828),
      ),
      _SummaryData(
        title: 'Pending (WD)',
        amount: pendingWithdrawals,
        background: const Color(0xFFEDEAFE),
        border: const Color(0xFFCFC5F5),
        amountColor: const Color(0xFF5E35B1),
        badgeText: pendingWithdrawalsCount > 0 ? '$pendingWithdrawalsCount' : null,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 620
                ? 3
                : 2;
        return GridView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.05,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return _SummaryCard(
              title: item.title,
              amount: item.amount,
              background: item.background,
              border: item.border,
              amountColor: item.amountColor,
              badgeText: item.badgeText,
            );
          },
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color background;
  final Color border;
  final Color amountColor;
  final String? badgeText;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.background,
    required this.border,
    required this.amountColor,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: background,
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (badgeText != null)
                Positioned(
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: amountColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badgeText!,
                      style: TextStyle(
                        color: amountColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "₹$amount",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryData {
  const _SummaryData({
    required this.title,
    required this.amount,
    required this.background,
    required this.border,
    required this.amountColor,
    this.badgeText,
  });

  final String title;
  final String amount;
  final Color background;
  final Color border;
  final Color amountColor;
  final String? badgeText;
}