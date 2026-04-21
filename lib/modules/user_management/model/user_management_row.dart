class UserManagementRow {
  const UserManagementRow({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.walletBalance,
    required this.totalRides,
    required this.isBlocked,
    required this.avatarUrl,
    required this.status,
    required this.statusSubtitle,
  });

  final int id;
  final String name;
  final String phone;
  final String email;
  final String walletBalance;
  final int totalRides;
  final bool isBlocked;
  final String avatarUrl;
  final String status;
  final String statusSubtitle;
}