import '/backend/api_requests/api_calls.dart';

import 'ride_row_data.dart';

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

  /// Collects unique rider and driver ids from ride maps (same rules as [RideRowData]).
  static void collectIdsFromRides(
    List<dynamic> rides,
    Set<int> userIds,
    Set<int> driverIds,
  ) {
    for (final r in rides) {
      if (r is! Map) continue;
      final m = Map<String, dynamic>.from(r);
      final ui = RideRowData.parseRiderUserId(m);
      final di = RideRowData.parseDriverId(m);
      if (ui != null) userIds.add(ui);
      if (di != null) driverIds.add(di);
    }
  }
}
