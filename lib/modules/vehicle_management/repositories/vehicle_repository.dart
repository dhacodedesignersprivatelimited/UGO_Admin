import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';
import '../models/admin_vehicle_row.dart';
import '../models/vehicle_type_entry.dart';

String _extractApiError(ApiCallResponse response) {
  final body = response.jsonBody;
  if (body is Map) {
    final message = body['message'] ?? body['error'] ?? body['detail'];
    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }
  }

  final raw = response.bodyText.trim();
  if (raw.isNotEmpty && raw != 'null') {
    return raw;
  }
  return 'Unknown server error';
}

class VehicleRepository {
  /// Loads all vehicle types with their nested sub-vehicles from the API.
  Future<List<VehicleTypeEntry>> getVehicleTypes() async {
    // Avoid auth header here so web clients do not trigger CORS preflight.
    final response = await GetVehicleTypesCall.call();
    if (!response.succeeded) {
      throw Exception('Failed to load vehicle types (${response.statusCode})');
    }
    dynamic raw = response.jsonBody;
    if (raw is Map) {
      raw = raw['data'] ?? raw['vehicle_types'] ?? raw['vehicleTypes'];
    }
    if (raw is! List) return [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(VehicleTypeEntry.fromJson)
        .toList();
  }

  /// Loads the flat list of admin vehicles (sub-vehicles) from a separate
  /// endpoint. Used to supplement vehicle type data if needed.
  Future<List<AdminVehicleRow>> getAdminVehicles() async {
    // Avoid auth header here so web clients do not trigger CORS preflight.
    final response = await GetAllVehiclesCall.call();
    if (!response.succeeded) return [];
    dynamic raw = response.jsonBody;
    if (raw is Map) {
      raw = raw['data'] ?? raw['vehicles'];
    }
    if (raw is! List) return [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map((j) => AdminVehicleRow.fromJson(j))
        .toList();
  }

  /// Updates a sub-vehicle's properties.
  Future<void> updateVehicle({
    required int vehicleId,
    String? vehicleName,
    String? vehicleType,
    int? seatingCapacity,
    int? luggageCapacity,
  }) async {
    final response = await UpdateAdminVehicleCall.call(
      token: currentAuthenticationToken,
      vehicleId: vehicleId,
      vehicleName: vehicleName,
      vehicleType: vehicleType,
      seatingCapacity: seatingCapacity,
      luggageCapacity: luggageCapacity,
    );
    if (!response.succeeded) {
      throw Exception('Failed to update vehicle (${response.statusCode})');
    }
  }

  /// Sets the pricing tier for a sub-vehicle.
  Future<void> setPricing({
    required int vehicleId,
    required int baseKmStart,
    required int baseKmEnd,
    required num baseFare,
    required num pricePerKm,
  }) async {
    final response = await SetPricingCall.call(
      token: currentAuthenticationToken,
      vehicleId: vehicleId,
      baseKmStart: baseKmStart,
      baseKmEnd: baseKmEnd,
      baseFare: baseFare,
      pricePerKm: pricePerKm,
    );
    if (!response.succeeded) {
      final reason = _extractApiError(response);
      throw Exception('Failed to set pricing (${response.statusCode}): $reason');
    }
  }
}
