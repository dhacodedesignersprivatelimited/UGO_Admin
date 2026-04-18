import '../models/analytics_models.dart';
import '../models/domain_enums.dart';
import '../models/driver_models.dart';
import '../models/finance_models.dart';
import '../models/notification_models.dart';
import '../models/promo_models.dart';
import '../models/rider_models.dart';
import '../models/ride_models.dart';
import '../models/settings_models.dart';
import '../models/vehicle_models.dart';

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
