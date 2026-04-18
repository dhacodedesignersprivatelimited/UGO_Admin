class DriverManagementRow {
  const DriverManagementRow({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicle,
    required this.vehicleNumber,
    required this.avatarUrl,
    required this.status,
    required this.statusSubtitle,
    required this.walletBalance,
    required this.totalRides,
    required this.rating,
    required this.isOnline,
    required this.isPending,
    required this.isBlocked,
    required this.hasLicense,
    required this.hasRcBook,
    required this.hasAadhaar,
    required this.hasProfile,
    required this.appliedAt,
  });

  final int id;
  final String name;
  final String phone;
  final String vehicle;
  final String vehicleNumber;
  final String avatarUrl;
  final String status;
  final String statusSubtitle;
  final String walletBalance;
  final int totalRides;
  final double rating;
  final bool isOnline;
  final bool isPending;
  final bool isBlocked;
  final bool hasLicense;
  final bool hasRcBook;
  final bool hasAadhaar;
  final bool hasProfile;
  final DateTime? appliedAt;
}
