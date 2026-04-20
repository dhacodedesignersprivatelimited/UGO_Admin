import '/core/network/admin_api_contract.dart';
import '/shared/models/domain_enums.dart';
import '/modules/driver_management/model/drivers_model.dart';
import '/modules/vehicle_management/model/vehicles_model.dart';

class DriverAdminRepository {
  DriverAdminRepository(this._api);

  final AdminApiContract _api;

  Future<List<DriverListItem>> listDrivers({String? query}) =>
      _api.listDrivers(query: query);

  Future<DriverProfile> getDriver(String id) => _api.getDriver(id);

  Future<void> setPresence(String driverId, DriverPresenceStatus status) =>
      _api.setDriverPresence(driverId, status);

  Future<void> setKyc(String driverId, KycReviewStatus status) =>
      _api.setDriverKycStatus(driverId, status);

  Future<List<VehicleTypeRef>> vehicleTypes() => _api.listVehicleTypes();
}
