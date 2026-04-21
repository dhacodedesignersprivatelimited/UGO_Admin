class FinanceTransaction {
  final String id;
  final String driverName;
  final String driverAvatar;
  final double amount;
  final String status;
  final DateTime date;

  FinanceTransaction({
    required this.id,
    required this.driverName,
    required this.driverAvatar,
    required this.amount,
    required this.status,
    required this.date,
  });
}

class FinanceSummary {
  final double totalEarnings;
  final double pendingPayouts;
  final double completedPayouts;
  final double platformCommission;

  FinanceSummary({
    required this.totalEarnings,
    required this.pendingPayouts,
    required this.completedPayouts,
    required this.platformCommission,
  });
}
