class WithdrawModel {
  final int id;
  final String driverName;
  final String phone;
  final double amount;
  final String status;
  final String date;

  WithdrawModel({
    required this.id,
    required this.driverName,
    required this.phone,
    required this.amount,
    required this.status,
    required this.date,
  });

  factory WithdrawModel.fromJson(Map<String, dynamic> json) {
    return WithdrawModel(
      id: int.parse(json['id'].toString()),
      driverName: json['driver_name'] ?? "Unknown",
      phone: json['phone'] ?? "",
      amount: double.tryParse(json['amount'].toString()) ?? 0,
      status: json['status'] ?? "pending",
      date: json['date'] ?? "",
    );
  }
}