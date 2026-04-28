import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';
import '/core/network/api_config.dart';

import '../models/user_management_row.dart';

class UserManagementRepository {
  Future<List<UserManagementRow>> getUsers() async {
    final response = await AllUsersCall.call(
      token: currentAuthenticationToken,
      page: 1,
      limit: 500,
    );

    if (!response.succeeded) {
      throw Exception('Could not load users');
    }

    final raw = AllUsersCall.usersdata(response.jsonBody);
    if (raw is! List) return const [];

    return _toRows(raw);
  }

  Future<void> blockUser(int userId) async {
    final response = await BlockUserCall.call(
      userId: userId,
      token: currentAuthenticationToken,
    );
    if (!response.succeeded) {
      throw Exception('Could not block user');
    }
  }

  Future<void> unblockUser(int userId) async {
    final response = await UnblockUserCall.call(
      userId: userId,
      token: currentAuthenticationToken,
    );
    if (!response.succeeded) {
      throw Exception('Could not unblock user');
    }
  }

  Future<void> addUser({
    required String mobileNumber,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final response = await CreateUserCall.call(
      token: currentAuthenticationToken,
      mobileNumber: mobileNumber,
      firstName: firstName,
      lastName: lastName,
      email: email,
    );
    if (!response.succeeded) {
      throw Exception('Could not add user');
    }
  }

  List<UserManagementRow> _toRows(List<dynamic> source) {
    final out = <UserManagementRow>[];
    for (var i = 0; i < source.length; i++) {
      final row = source[i];
      if (row is! Map) continue;
      final d = Map<String, dynamic>.from(row);
      final id = _int(d['user_id'], fallback: i + 1);
      final name = (d['name'] ?? '').toString().trim();
      final phone = (d['phone'] ?? '').toString().trim();
      final email = (d['email'] ?? '').toString().trim();
      final rawAvatar = (d['profile_image'] ?? '').toString().trim();
      final avatar = rawAvatar.isEmpty || rawAvatar == 'null'
          ? ''
          : (rawAvatar.startsWith('http')
              ? rawAvatar
              : '${ApiConfig.baseUrl}/${rawAvatar.replaceFirst(RegExp(r'^/'), '')}');
      final walletBalance = (d['wallet_balance'] ?? 0).toString();
      final totalRides = _int(d['total_rides'], fallback: 0);
      final accountStatus =
          (d['account_status'] ?? 'active').toString().trim().toLowerCase();
      final isBlocked = accountStatus == 'blocked';

      out.add(
        UserManagementRow(
          id: id,
          name: name,
          phone: phone,
          email: email,
          walletBalance: walletBalance,
          totalRides: totalRides,
          isBlocked: isBlocked,
          avatarUrl: avatar,
          status: isBlocked ? 'Blocked' : 'Active',
          statusSubtitle: isBlocked ? 'By Admin' : 'Active',
        ),
      );
    }
    return out;
  }

  int _int(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }
}
