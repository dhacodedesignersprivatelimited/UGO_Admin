import '/backend/api_requests/api_calls.dart';

/// Loads rider ([GetUserByIdCall]) and driver ([GetDriverByIdCall]) maps by id.
class RidePartyFetch {
  static Map<String, dynamic>? _asMap(dynamic d) {
    if (d == null) return null;
    if (d is Map<String, dynamic>) return d;
    if (d is Map) return Map<String, dynamic>.from(d);
    return null;
  }

  static Future<Map<int, Map<String, dynamic>>> fetchUsersByIds(
    Set<int> ids,
    String token,
  ) async {
    if (ids.isEmpty) return {};
    final out = <int, Map<String, dynamic>>{};
    await Future.wait(ids.map((id) async {
      try {
        final resp = await GetUserByIdCall.call(id: id, token: token);
        if (!resp.succeeded) return;
        final d = GetUserByIdCall.data(resp.jsonBody);
        if (d != null) out[id] = d;
      } catch (_) {}
    }));
    return out;
  }

  static Future<Map<int, Map<String, dynamic>>> fetchDriversByIds(
    Set<int> ids,
    String token,
  ) async {
    if (ids.isEmpty) return {};
    final out = <int, Map<String, dynamic>>{};
    await Future.wait(ids.map((id) async {
      try {
        final resp = await GetDriverByIdCall.call(id: id, token: token);
        if (!resp.succeeded) return;
        final d = _asMap(GetDriverByIdCall.data(resp.jsonBody));
        if (d != null) out[id] = d;
      } catch (_) {}
    }));
    return out;
  }

  /// Collects unique rider (`rider_id` / `user_id`) and `driver_id` values from ride maps.
  static void collectIdsFromRides(
    List<dynamic> rides,
    Set<int> userIds,
    Set<int> driverIds,
  ) {
    for (final r in rides) {
      if (r is! Map) continue;
      final m = Map<String, dynamic>.from(r);
      final u = m['rider_id'] ?? m['user_id'];
      final d = m['driver_id'];
      final ui = u is int ? u : int.tryParse(u?.toString() ?? '');
      final di = d is int ? d : int.tryParse(d?.toString() ?? '');
      if (ui != null) userIds.add(ui);
      if (di != null) driverIds.add(di);
    }
  }
}
