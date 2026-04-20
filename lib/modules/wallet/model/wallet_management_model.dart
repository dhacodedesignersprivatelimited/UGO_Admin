class WalletModel {
  final int? id;
  final String type; // rider / driver / admin
  final double balance;

  final int? userId;
  final int? driverId;
  final int? adminId;

  final String name;
  final String phone;
  final String? avatar;

  WalletModel({
    this.id,
    required this.type,
    required this.balance,
    this.userId,
    this.driverId,
    this.adminId,
    required this.name,
    required this.phone,
    this.avatar,
  });

  /// 🔥 FROM API JSON
  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: _parseInt(json['id'] ?? json['wallet_id']),
      type: _resolveType(json),
      balance: _parseDouble(
        json['balance'] ??
            json['wallet_balance'] ??
            json['amount'],
      ),

      userId: _parseInt(json['user_id']),
      driverId: _parseInt(json['driver_id']),
      adminId: _parseInt(json['admin_id']),

      name: _resolveName(json),
      phone: _resolvePhone(json),
      avatar: json['profile_image'] ??
          json['avatar'] ??
          json['photo'],
    );
  }

  /// 🔄 TO JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "type": type,
      "balance": balance,
      "user_id": userId,
      "driver_id": driverId,
      "admin_id": adminId,
      "name": name,
      "phone": phone,
      "avatar": avatar,
    };
  }

  /// ---------------- HELPERS ----------------

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    return int.tryParse(v.toString());
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0.0;
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static String _resolveType(Map<String, dynamic> json) {
    final raw = (json['type'] ??
        json['user_type'] ??
        json['wallet_type'] ??
        "")
        .toString()
        .toLowerCase();

    if (raw.contains("driver")) return "driver";
    if (raw.contains("admin")) return "admin";
    return "rider";
  }

  static String _resolveName(Map<String, dynamic> json) {
    final first = json['first_name'] ?? "";
    final last = json['last_name'] ?? "";

    final full = "$first $last".trim();

    if (full.isNotEmpty) return full;

    return json['name'] ??
        json['username'] ??
        json['email'] ??
        "Unknown";
  }

  static String _resolvePhone(Map<String, dynamic> json) {
    return json['mobile_number'] ??
        json['phone'] ??
        json['contact'] ??
        "";
  }
}