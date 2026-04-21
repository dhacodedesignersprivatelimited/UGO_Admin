import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/finance_repository.dart';

class FinanceDashboardState {
  final double totalEarnings;
  final double pendingPayoutsAmount;
  final int pendingPayoutsCount;
  final List<Map<String, dynamic>> recentTransactions;

  FinanceDashboardState({
    required this.totalEarnings,
    required this.pendingPayoutsAmount,
    required this.pendingPayoutsCount,
    required this.recentTransactions,
  });
}

final financeDashboardProvider = FutureProvider.autoDispose<FinanceDashboardState>((ref) async {
  final repository = ref.watch(financeRepositoryProvider);
  
  // Concurrently fetch primary sources
  final results = await Future.wait([
    repository.getDashboardStats(),
    repository.getPayments(),
  ]);

  final summary = results[0] as Map<String, dynamic>;
  final payments = results[1] as List<Map<String, dynamic>>;

  // Aggregate computed earnings from completed trips
  // If summary doesn't have a direct 'total_earnings', we might fallback to rides,
  // but let's try to find common aggregation fields first.
  double totalEarnings = 0;
  final ledger = summary['platform_ledger_breakdown'];
  if (ledger is Map) {
    totalEarnings = double.tryParse(ledger['total_commission_ledger_inr']?.toString() ?? '0') ?? 0;
  } else {
    // Fallback or secondary source
    totalEarnings = double.tryParse(summary['company_ledger_balance_inr']?.toString() ?? '0') ?? 0;
  }

  // Pending Payouts from Summary (Directly from backend aggregation)
  final pending = summary['pending_payouts'] as Map?;
  double pendingAmount = double.tryParse(pending?['amount_inr']?.toString() ?? '0') ?? 0;
  int pendingCount = int.tryParse(pending?['count']?.toString() ?? '0') ?? 0;

  // Slice recent transactions
  final recentTx = payments.take(10).toList();

  return FinanceDashboardState(
    totalEarnings: totalEarnings,
    pendingPayoutsAmount: pendingAmount,
    pendingPayoutsCount: pendingCount,
    recentTransactions: recentTx,
  );
});
