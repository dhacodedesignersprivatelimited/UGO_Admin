import '/core/network/admin_api_contract.dart';
import '/shared/models/domain_enums.dart';
import '/modules/ride_management/model/rides_model.dart';

class RidesAdminRepository {
  RidesAdminRepository(this._api);

  final AdminApiContract _api;

  Future<List<RideSummary>> listRides({RideLifecycleStatus? filter}) =>
      _api.listRides(filter: filter);

  Future<RideDetail> getRide(String id) => _api.getRide(id);

  Future<void> assignDriver({
    required String rideId,
    required String driverId,
  }) =>
      _api.assignDriverToRide(rideId: rideId, driverId: driverId);

  Future<void> cancel(String rideId, {String? reason}) =>
      _api.cancelRideAsAdmin(rideId, reason: reason);
}
