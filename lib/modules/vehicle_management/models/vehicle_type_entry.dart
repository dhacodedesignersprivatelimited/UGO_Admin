import 'admin_vehicle_row.dart';
import '/core/network/api_config.dart';

/// Vehicle type with its nested sub-vehicles.
class VehicleTypeEntry {
  const VehicleTypeEntry({
    required this.id,
    required this.name,
    this.imageUrl = '',
    this.subVehicles = const [],
  });

  final int id;
  final String name;
  final String imageUrl;
  final List<AdminVehicleRow> subVehicles;

  VehicleTypeEntry copyWith({
    int? id,
    String? name,
    String? imageUrl,
    List<AdminVehicleRow>? subVehicles,
  }) {
    return VehicleTypeEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      subVehicles: subVehicles ?? this.subVehicles,
    );
  }

  factory VehicleTypeEntry.fromJson(Map<String, dynamic> json) {
    dynamic g(String key) => json[key];
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


    int toInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value.trim()) ?? 0;
      return 0;
    }

    final id = toInt(g('id') ?? g('vehicle_type_id'));
    final name =
        (g('name') ?? g('vehicle_type') ?? g('vehicleType') ?? '').toString();
    final imageUrl = normalizeImageUrl(g('image') ?? g('imageUrl') ?? g('image_url'));

    List<AdminVehicleRow> subs = [];
    final rawSubs = g('admin_vehicles') ?? g('vehicles') ?? g('subVehicles');
    if (rawSubs is List) {
      for (final item in rawSubs) {
        if (item is Map<String, dynamic>) {
          subs.add(AdminVehicleRow.fromJson(item, vehicleTypeName: name));
        }
      }
    }

    return VehicleTypeEntry(
      id: id,
      name: name,
      imageUrl: imageUrl,
      subVehicles: subs,
    );
  }
}
