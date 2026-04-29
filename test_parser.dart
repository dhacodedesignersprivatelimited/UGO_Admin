import 'dart:convert';

void main() {
  final jsonBody = jsonDecode('''{
    "success": true,
    "statusCode": 200,
    "message": "Dashboard overview retrieved",
    "data": {
        "total_rides": 986,
        "total_earnings": 227464.69,
        "admin_wallet_balance": 224,
        "rides_completed_today": 0,
        "new_users_today": 2,
        "user_statistics": {
            "total": 303,
            "active": 303,
            "inactive": 0,
            "blocked": 0,
            "active_percent": "100.0",
            "inactive_percent": "0.0",
            "blocked_percent": "0.0"
        },
        "driver_statistics": {
            "total": 149,
            "active": 128,
            "pending": 0,
            "blocked": 0,
            "active_percent": "85.9",
            "pending_percent": "0.0",
            "blocked_percent": "0.0"
        }
    }
}''');

  final root = Map<String, dynamic>.from(jsonBody as Map);
  final data = root['data'];
  final m = data is Map ? Map<String, dynamic>.from(data) : Map<String, dynamic>.from(root);

  final uStats = m['user_statistics'] is Map
      ? Map<String, dynamic>.from(m['user_statistics'] as Map)
      : const <String, dynamic>{};
      
  print("uStats: ${uStats}");
  
  final active = uStats['active'];
  print("active: ${active}");
  print("active type: ${active.runtimeType}");
}
