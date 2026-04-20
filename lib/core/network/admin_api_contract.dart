import '/modules/dashboard/model/dashboard_model.dart';
import '/shared/models/domain_enums.dart';
import '/modules/driver_management/model/drivers_model.dart';
import '/modules/finance_management/model/finance_model.dart';
import '/modules/notifications/model/notifications_model.dart';
import '/modules/promo_codes/model/promo_codes_model.dart';
import '/modules/user_management/model/users_model.dart';
import '/modules/ride_management/model/rides_model.dart';
import '/modules/settings/model/settings_model.dart';
import '/modules/vehicle_management/model/vehicles_model.dart';

/// REST-shaped contract for the admin panel. Swap [MockAdminApiClient] with
/// an implementation that uses `http` + [ApiConfig] from the existing layer.
abstract class AdminApiContract {
  Future<DashboardAnalytics> fetchDashboardAnalytics();

  Future<List<DriverListItem>> listDrivers({String? query});
  Future<DriverProfile> getDriver(String id);
  Future<void> setDriverPresence(String driverId, DriverPresenceStatus status);
  Future<void> setDriverKycStatus(String driverId, KycReviewStatus status);

  Future<List<RiderListItem>> listRiders({String? query});
  Future<RiderProfile> getRider(String id);
  Future<void> setRiderBlocked(String riderId, bool blocked);

  Future<List<RideSummary>> listRides({RideLifecycleStatus? filter});
  Future<RideDetail> getRide(String id);
  Future<void> assignDriverToRide({
    required String rideId,
    required String driverId,
  });
  Future<void> cancelRideAsAdmin(String rideId, {String? reason});

  Future<List<WithdrawalRequest>> listWithdrawals({WithdrawalStatus? status});
  Future<void> decideWithdrawal({
    required String id,
    required WithdrawalStatus decision,
  });

  Future<List<RiderComplaint>> listComplaints({ComplaintStatus? status});
  Future<void> updateComplaintStatus(String id, ComplaintStatus status);

  Future<List<PromoCode>> listPromoCodes();
  Future<GlobalSettingsSnapshot> getGlobalSettings();
  Future<void> updateFareSettings(FareSettings settings);

  Future<List<AdminNotificationJob>> listNotificationJobs();
  Future<void> enqueueNotification(AdminNotificationDraft draft);

  Future<List<VehicleTypeRef>> listVehicleTypes();
}
