import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';
import '/modules/vehicle_management/model/vehicles_model.dart';
import '/core/utils/view_state.dart';
import 'vehicles_state.dart';

export 'vehicles_state.dart';

/// ViewModel for the vehicle-types management screen.
class VehiclesViewModel extends StateNotifier<VehiclesState> {
  VehiclesViewModel() : super(const VehiclesState());

  Future<void> refresh() async {
    state = state.copyWith(status: LoadStatus.loading, clearError: true);
    try {
      final token = currentAuthenticationToken ?? '';
      final res = await GetVehicleTypesCall.call(token: token);
      final raw = (res.jsonBody as List? ?? []);
      final vehicles = raw
          .map((e) => VehicleTypeRef(
                id: e['id']?.toString() ?? '',
                name: e['vehicle_type']?.toString() ?? e['name']?.toString() ?? '',
                imageUrl: e['vehicle_image']?.toString() ?? e['image_url']?.toString(),
              ))
          .toList();
      state = state.copyWith(status: LoadStatus.success, vehicles: vehicles);
    } catch (e) {
      state = state.copyWith(
          status: LoadStatus.failure, errorMessage: e.toString());
    }
  }
}

/// Global vehicles ViewModel provider.
final vehiclesViewModelProvider =
    StateNotifierProvider<VehiclesViewModel, VehiclesState>(
  (_) => VehiclesViewModel(),
);
