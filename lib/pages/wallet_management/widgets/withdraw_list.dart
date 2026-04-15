import 'package:flutter/material.dart';
import 'withdraw_item.dart';

class WithdrawRequestList extends StatelessWidget {
  final List<Map<String, dynamic>> withdraws;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final Function(Map<String, dynamic>)? onApprove;
  final Function(Map<String, dynamic>)? onReject;

  const WithdrawRequestList({
    super.key,
    required this.withdraws,
    this.isLoading = false,
    this.onRefresh,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    /// 🔄 LOADING STATE
    if (isLoading) {
      return const _LoadingWithdrawList();
    }

    /// ❌ EMPTY STATE
    if (withdraws.isEmpty) {
      return const _EmptyWithdrawState();
    }

    /// ✅ LIST
    return RefreshIndicator(
      onRefresh: () async {
        if (onRefresh != null) onRefresh!();
      },
      child: ListView.builder(
        itemCount: withdraws.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final w = withdraws[index];

          return WithdrawItem(
            driverName: w['driver_name'] ?? "Unknown",
            phone: w['phone'] ?? "",
            amount: w['amount']?.toString() ?? "0",
            status: w['status'] ?? "pending",
            date: w['date'] ?? "",
            onApprove: () {
              if (onApprove != null) onApprove!(w);
            },
            onReject: () {
              if (onReject != null) onReject!(w);
            },
          );
        },
      ),
    );
  }
}

/// 🔄 LOADING SKELETON
class _LoadingWithdrawList extends StatelessWidget {
  const _LoadingWithdrawList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        4,
            (index) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/// ❌ EMPTY STATE
class _EmptyWithdrawState extends StatelessWidget {
  const _EmptyWithdrawState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: const [
          Icon(Icons.account_balance_wallet_outlined,
              size: 50, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No Withdraw Requests",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}