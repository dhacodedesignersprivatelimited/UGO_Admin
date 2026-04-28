import '../models/vehicle_type_entry.dart';

class VehicleCatalogState {
  const VehicleCatalogState({
    this.isLoading = true,
    this.errorMessage,
    this.vehicleTypes = const [],
    this.searchQuery = '',
    this.filterTypeId,
    this.actionVehicleIds = const [],
  });

  final bool isLoading;
  final String? errorMessage;
  final List<VehicleTypeEntry> vehicleTypes;
  final String searchQuery;
  final int? filterTypeId;
  final List<int> actionVehicleIds;

  // ── Computed ──────────────────────────────────────────────────────────────

  int get totalTypes => vehicleTypes.length;

  int get totalSubVehicles =>
      vehicleTypes.fold(0, (sum, t) => sum + t.subVehicles.length);

  /// Vehicle types filtered by [filterTypeId] and [searchQuery].
  List<VehicleTypeEntry> get filteredTypes {
    var types = vehicleTypes;

    if (filterTypeId != null) {
      types = types.where((t) => t.id == filterTypeId).toList();
    }

    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return types;

    final result = <VehicleTypeEntry>[];
    for (final t in types) {
      final typeMatches = t.name.toLowerCase().contains(q);
      if (typeMatches) {
        result.add(t);
        continue;
      }
      final filteredSubs = t.subVehicles
          .where((v) =>
              v.name.toLowerCase().contains(q) ||
              v.rideCategory.toLowerCase().contains(q))
          .toList();
      if (filteredSubs.isNotEmpty) {
        result.add(t.copyWith(subVehicles: filteredSubs));
      }
    }
    return result;
  }

  bool get hasActiveFilter =>
      searchQuery.trim().isNotEmpty || filterTypeId != null;

  // ── copyWith ──────────────────────────────────────────────────────────────

  VehicleCatalogState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    List<VehicleTypeEntry>? vehicleTypes,
    String? searchQuery,
    int? filterTypeId,
    bool clearFilterTypeId = false,
    List<int>? actionVehicleIds,
  }) {
    return VehicleCatalogState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      vehicleTypes: vehicleTypes ?? this.vehicleTypes,
      searchQuery: searchQuery ?? this.searchQuery,
      filterTypeId:
          clearFilterTypeId ? null : (filterTypeId ?? this.filterTypeId),
      actionVehicleIds: actionVehicleIds ?? this.actionVehicleIds,
    );
  }
}
