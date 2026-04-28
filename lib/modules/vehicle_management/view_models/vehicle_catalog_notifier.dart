import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/admin_vehicle_row.dart';
import '../repositories/vehicle_repository.dart';
import '../models/vehicle_type_entry.dart';
import 'vehicle_catalog_state.dart';

class VehicleCatalogNotifier extends StateNotifier<VehicleCatalogState> {
  VehicleCatalogNotifier(this._repository) : super(const VehicleCatalogState());

  final VehicleRepository _repository;
  String? _lastActionError;

  String? get lastActionError => _lastActionError;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _repository.getVehicleTypes(),
        _repository.getAdminVehicles(),
      ]);

      final types = results[0] as List<VehicleTypeEntry>;
      final adminVehicles = results[1] as List<AdminVehicleRow>;

      final vehiclesByType = <int, List<AdminVehicleRow>>{};
      for (final vehicle in adminVehicles) {
        vehiclesByType.putIfAbsent(vehicle.vehicleTypeId, () => []).add(vehicle);
      }

      final mergedTypes = types.map((type) {
        final flatVehicles = vehiclesByType[type.id] ?? const <AdminVehicleRow>[];
        if (flatVehicles.isEmpty) return type;

        final normalizedFlatVehicles = flatVehicles
            .map(
              (v) => AdminVehicleRow(
                id: v.id,
                name: v.name,
                vehicleTypeId: v.vehicleTypeId,
                vehicleTypeName:
                    v.vehicleTypeName.isNotEmpty ? v.vehicleTypeName : type.name,
                rideCategory: v.rideCategory,
                seatingCapacity: v.seatingCapacity,
                luggageCapacity: v.luggageCapacity,
                imageUrl: v.imageUrl,
                baseKmStart: v.baseKmStart,
                baseKmEnd: v.baseKmEnd,
                baseFare: v.baseFare,
                pricePerKm: v.pricePerKm,
              ),
            )
            .toList();

        final byId = <int, AdminVehicleRow>{
          for (final vehicle in type.subVehicles) vehicle.id: vehicle,
        };
        for (final vehicle in normalizedFlatVehicles) {
          // Flat list carries the latest pricing payload, so it should win.
          byId[vehicle.id] = vehicle;
        }

        return type.copyWith(subVehicles: byId.values.toList());
      }).toList();

      state = state.copyWith(isLoading: false, vehicleTypes: mergedTypes);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void setSearchQuery(String value) {
    if (state.searchQuery == value) return;
    state = state.copyWith(searchQuery: value);
  }

  void setFilterTypeId(int? id) {
    if (state.filterTypeId == id) return;
    if (id == null) {
      state = state.copyWith(clearFilterTypeId: true);
    } else {
      state = state.copyWith(filterTypeId: id);
    }
  }

  void clearFilters() {
    state = state.copyWith(searchQuery: '', clearFilterTypeId: true);
  }

  Future<bool> updateVehicle({
    required int vehicleId,
    String? vehicleName,
    String? vehicleType,
    int? seatingCapacity,
    int? luggageCapacity,
  }) async {
    if (state.actionVehicleIds.contains(vehicleId)) return false;
    _lastActionError = null;
    state = state
        .copyWith(actionVehicleIds: [...state.actionVehicleIds, vehicleId]);
    try {
      await _repository.updateVehicle(
        vehicleId: vehicleId,
        vehicleName: vehicleName,
        vehicleType: vehicleType,
        seatingCapacity: seatingCapacity,
        luggageCapacity: luggageCapacity,
      );
      await load();
      return true;
    } catch (e) {
      _lastActionError = e.toString();
      return false;
    } finally {
      state = state.copyWith(
        actionVehicleIds:
            state.actionVehicleIds.where((id) => id != vehicleId).toList(),
      );
    }
  }

  Future<bool> setPricing({
    required int vehicleId,
    required int baseKmStart,
    required int baseKmEnd,
    required num baseFare,
    required num pricePerKm,
  }) async {
    if (state.actionVehicleIds.contains(vehicleId)) return false;
    _lastActionError = null;
    state = state
        .copyWith(actionVehicleIds: [...state.actionVehicleIds, vehicleId]);
    try {
      await _repository.setPricing(
        vehicleId: vehicleId,
        baseKmStart: baseKmStart,
        baseKmEnd: baseKmEnd,
        baseFare: baseFare,
        pricePerKm: pricePerKm,
      );
      await load();
      return true;
    } catch (e) {
      _lastActionError = e.toString();
      return false;
    } finally {
      state = state.copyWith(
        actionVehicleIds:
            state.actionVehicleIds.where((id) => id != vehicleId).toList(),
      );
    }
  }
}

final vehicleCatalogProvider =
    StateNotifierProvider<VehicleCatalogNotifier, VehicleCatalogState>(
  (ref) => VehicleCatalogNotifier(VehicleRepository()),
);
