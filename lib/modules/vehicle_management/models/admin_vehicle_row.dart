import '/core/network/api_config.dart';

/// Data model for a single admin vehicle (sub-vehicle / vehicle template).
class AdminVehicleRow {
  const AdminVehicleRow({
    required this.id,
    required this.name,
    required this.vehicleTypeId,
    this.vehicleTypeName = '',
    this.rideCategory = '',
    this.seatingCapacity = 0,
    this.luggageCapacity = 0,
    this.imageUrl = '',
    this.baseKmStart,
    this.baseKmEnd,
    this.baseFare,
    this.pricePerKm,
  });

  final int id;
  final String name;
  final int vehicleTypeId;
  final String vehicleTypeName;
  final String rideCategory;
  final int seatingCapacity;
  final int luggageCapacity;
  final String imageUrl;
  final int? baseKmStart;
  final int? baseKmEnd;
  final num? baseFare;
  final num? pricePerKm;

  factory AdminVehicleRow.fromJson(
    Map<String, dynamic> json, {
    String vehicleTypeName = '',
  }) {
    String normalizeImageUrl(dynamic value) {
      final raw = (value ?? '').toString().trim();
      if (raw.isEmpty) return '';
      if (raw.startsWith('http://') ||
          raw.startsWith('https://') ||
          raw.startsWith('data:') ||
          raw.startsWith('blob:')) {
        return raw;
      }
      return '${ApiConfig.baseUrl}/${raw.replaceFirst(RegExp(r'^/'), '')}';
    }

    dynamic g(String key) => json[key];

    int toInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value.trim()) ?? 0;
      return 0;
    }

    int? toNullableInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value.trim());
      return null;
    }

    num? toNullableNum(dynamic value) {
      if (value == null) return null;
      if (value is num) return value;
      if (value is String) return num.tryParse(value.trim());
      return null;
    }

    final id = toInt(g('id') ?? g('vehicle_id') ?? g('vehicleId'));
    final name =
        (g('vehicle_name') ?? g('name') ?? g('vehicleName') ?? '').toString();
    final typeId = toInt(g('vehicle_type_id') ?? g('vehicleTypeId'));
    final rideCategory =
        (g('ride_category') ?? g('rideCategory') ?? '').toString();
    final seating = toInt(g('seating_capacity') ?? g('seatingCapacity'));
    final luggage = toInt(g('luggage_capacity') ?? g('luggageCapacity'));
    final imageUrl = normalizeImageUrl(
      g('vehicle_image_url') ?? g('vehicle_image') ?? g('vehicleImage'),
    );
    final pricingRaw = g('pricing');
    final pricing = pricingRaw is Map<String, dynamic>
        ? pricingRaw
        : pricingRaw is Map
            ? pricingRaw.cast<String, dynamic>()
            : const <String, dynamic>{};

    final baseKmStart = toNullableInt(
      pricing['base_km_start'] ?? g('base_km_start') ?? g('baseKmStart'),
    );
    final baseKmEnd = toNullableInt(
      pricing['base_km_end'] ?? g('base_km_end') ?? g('baseKmEnd'),
    );
    final baseFare = toNullableNum(
      pricing['base_fare'] ?? g('base_fare') ?? g('baseFare'),
    );
    final pricePerKm = toNullableNum(
      pricing['price_per_km'] ?? g('price_per_km') ?? g('pricePerKm'),
    );

    return AdminVehicleRow(
      id: id,
      name: name,
      vehicleTypeId: typeId,
      vehicleTypeName: vehicleTypeName,
      rideCategory: rideCategory,
      seatingCapacity: seating,
      luggageCapacity: luggage,
      imageUrl: imageUrl,
      baseKmStart: baseKmStart,
      baseKmEnd: baseKmEnd,
      baseFare: baseFare,
      pricePerKm: pricePerKm,
    );
  }
}
