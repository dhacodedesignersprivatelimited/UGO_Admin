import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';
import '/core/utils/view_state.dart';
import 'zones_state.dart';

export 'zones_state.dart';

/// ViewModel for the zone/city management screen.
class ZonesViewModel extends StateNotifier<ZonesState> {
  ZonesViewModel() : super(const ZonesState());

  Future<void> refresh() async {
    state = state.copyWith(status: LoadStatus.loading, clearError: true);
    try {
      final token = currentAuthenticationToken ?? '';
      final res = await GetZonesCall.call(token: token);
      final raw = (res.jsonBody as List? ??
          (res.jsonBody is Map ? (res.jsonBody['data'] as List? ?? []) : []));
      state = state.copyWith(
          status: LoadStatus.success, zones: List<dynamic>.from(raw));
    } catch (e) {
      state = state.copyWith(
          status: LoadStatus.failure, errorMessage: e.toString());
    }
  }

  Future<void> addZone(Map<String, dynamic> data) async {
    final token = currentAuthenticationToken ?? '';
    await AddZoneCall.call(
      token: token,
      name: data['name']?.toString() ?? '',
      cityId: (data['city_id'] as num?)?.toInt() ?? 0,
      type: data['type']?.toString() ?? 'radius',
      centerLat: (data['center_lat'] as num?)?.toDouble(),
      centerLng: (data['center_lng'] as num?)?.toDouble(),
      radiusKm: (data['radius_km'] as num?)?.toDouble(),
    );
    await refresh();
  }

  Future<void> deleteZone(String id) async {
    final token = currentAuthenticationToken ?? '';
    final zoneId = int.tryParse(id);
    if (zoneId == null) return;
    await DeleteZoneCall.call(token: token, zoneId: zoneId);
    await refresh();
  }

  Future<void> updateZone(String id, Map<String, dynamic> data) async {
    final token = currentAuthenticationToken ?? '';
    final zoneId = int.tryParse(id);
    if (zoneId == null) return;
    await UpdateZoneCall.call(
      token: token,
      zoneId: zoneId,
      cityId: (data['city_id'] as num?)?.toInt(),
      name: data['name']?.toString(),
      type: data['type']?.toString(),
      centerLat: (data['center_lat'] as num?)?.toDouble(),
      centerLng: (data['center_lng'] as num?)?.toDouble(),
      radiusKm: (data['radius_km'] as num?)?.toDouble(),
      polygonJson: data['polygon_json'],
      isActive: data['is_active'] as bool?,
    );
    await refresh();
  }

  Future<void> updateCity(String id, {String? name, bool? isActive}) async {
    final token = currentAuthenticationToken ?? '';
    final cityId = int.tryParse(id);
    if (cityId == null) return;
    await UpdateCityCall.call(
      token: token,
      cityId: cityId,
      name: name,
      isActive: isActive,
    );
    await refresh();
  }

  Future<void> deleteCity(String id) async {
    final token = currentAuthenticationToken ?? '';
    final cityId = int.tryParse(id);
    if (cityId == null) return;
    await DeleteCityCall.call(token: token, cityId: cityId);
    await refresh();
  }
}

/// Global zones ViewModel provider.
final zonesViewModelProvider =
    StateNotifierProvider<ZonesViewModel, ZonesState>(
  (_) => ZonesViewModel(),
);
