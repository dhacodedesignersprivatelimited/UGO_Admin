class TransactionModel {
  final String name;
  final String phone;
  final String type;
  final double amount;
  final double balance;
  final String description;
  final String date;
  final String? avatar;

  TransactionModel({
    required this.name,
    required this.phone,
    required this.type,
    required this.amount,
    required this.balance,
    required this.description,
    required this.date,
    this.avatar,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      name: json['name'] ?? "Unknown",
      phone: json['phone'] ?? "",
      type: json['type'] ?? "credit",
      amount: double.tryParse(json['amount'].toString()) ?? 0,
      balance: double.tryParse(json['balance'].toString()) ?? 0,
      description: json['description'] ?? "",
      date: json['date'] ?? "",
      avatar: json['avatar'],
    );
  }
}