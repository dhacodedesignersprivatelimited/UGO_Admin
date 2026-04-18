import '../api/admin_api_contract.dart';
import '../models/domain_enums.dart';
import '../models/ride_models.dart';

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
