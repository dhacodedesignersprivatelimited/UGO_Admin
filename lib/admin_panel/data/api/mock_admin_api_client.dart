import 'dart:math';

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
import 'admin_api_contract.dart';

/// Deterministic in-memory API for UI + ViewModel development.
/// Replace with [HttpAdminApiClient] wired to `UGO_BACKEND` admin routes.
class MockAdminApiClient implements AdminApiContract {
  MockAdminApiClient({Random? random}) : _random = random ?? Random(42);

  final Random _random;

  final List<DriverListItem> _drivers = [
    const DriverListItem(
      id: 'd1',
      displayName: 'Asha Verma',
      phone: '+91-9000000001',
      presence: DriverPresenceStatus.online,
      kycStatus: KycReviewStatus.approved,
      vehicleLabel: 'Sedan · KA01AB1234',
      rating: 4.9,
    ),
    const DriverListItem(
      id: 'd2',
      displayName: 'Rahul Mehta',
      phone: '+91-9000000002',
      presence: DriverPresenceStatus.offline,
      kycStatus: KycReviewStatus.pending,
      vehicleLabel: 'Bike · KA02CD5678',
      rating: 4.6,
    ),
  ];

  final List<RiderListItem> _riders = [
    const RiderListItem(
      id: 'r1',
      displayName: 'Neha Kapoor',
      phone: '+91-8000000001',
      isBlocked: false,
      walletBalance: 320,
    ),
    const RiderListItem(
      id: 'r2',
      displayName: 'Vikram Singh',
      phone: '+91-8000000002',
      isBlocked: true,
      walletBalance: 0,
    ),
  ];

  final List<RideSummary> _rides = [
    RideSummary(
      id: 'ride1',
      riderName: 'Neha Kapoor',
      driverName: 'Asha Verma',
      status: RideLifecycleStatus.inProgress,
      pickupLabel: 'Indiranagar Metro',
      dropLabel: 'EGL Tech Park',
      fare: 248,
      requestedAt: DateTime.now().subtract(const Duration(minutes: 12)),
      driverId: 'd1',
      riderId: 'r1',
    ),
    RideSummary(
      id: 'ride2',
      riderName: 'Vikram Singh',
      driverName: 'Unassigned',
      status: RideLifecycleStatus.requested,
      pickupLabel: 'Koramangala 5th Block',
      dropLabel: 'HSR Layout Sector 2',
      fare: 186,
      requestedAt: DateTime.now().subtract(const Duration(minutes: 3)),
      riderId: 'r2',
    ),
  ];

  final List<WithdrawalRequest> _withdrawals = [
    WithdrawalRequest(
      id: 'w1',
      driverId: 'd2',
      driverName: 'Rahul Mehta',
      amount: 4200,
      status: WithdrawalStatus.pending,
      requestedAt: DateTime.now().subtract(const Duration(hours: 5)),
      bankMasked: 'HDFC ···3210',
    ),
  ];

  final List<RiderComplaint> _complaints = [
    RiderComplaint(
      id: 'c1',
      riderId: 'r1',
      subject: 'Driver delayed pickup',
      body: 'Waited more than 10 minutes at pinned location.',
      status: ComplaintStatus.open,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      rideId: 'ride_prev',
    ),
  ];

  final List<PromoCode> _promos = [
    PromoCode(
      id: 'p1',
      code: 'UGO20',
      discountType: PromoDiscountType.percentage,
      discountValue: 20,
      maxRedemptions: 5000,
      redemptionsUsed: 1200,
      startsAt: DateTime.now().subtract(const Duration(days: 7)),
      endsAt: DateTime.now().add(const Duration(days: 23)),
      isActive: true,
    ),
  ];

  FareSettings _fare = const FareSettings(
    baseFare: 49,
    perKm: 12,
    perMinute: 1.5,
    minimumFare: 89,
    platformCommissionPercent: 18,
    taxPercent: 5,
  );

  final List<SurgeBand> _surge = [
    const SurgeBand(id: 's1', label: 'CBD peak', multiplier: 1.4, active: true),
    const SurgeBand(id: 's2', label: 'Airport corridor', multiplier: 1.2, active: false),
  ];

  final List<AdminNotificationJob> _notifJobs = [];

  Future<void> _delay() => Future<void>.delayed(
        Duration(milliseconds: 180 + _random.nextInt(120)),
      );

  @override
  Future<DashboardAnalytics> fetchDashboardAnalytics() async {
    await _delay();
    return DashboardAnalytics(
      generatedAt: DateTime.now(),
      metrics: const [
        MetricTile(
          id: 'm1',
          title: 'GMV (24h)',
          value: '₹12.4L',
          deltaPercent: 6.2,
          trendUp: true,
        ),
        MetricTile(
          id: 'm2',
          title: 'Completion rate',
          value: '97.1%',
          deltaPercent: 0.8,
          trendUp: true,
        ),
        MetricTile(
          id: 'm3',
          title: 'Avg wait',
          value: '3m 10s',
          deltaPercent: 4.1,
          trendUp: false,
        ),
      ],
      activeDrivers: 128,
      liveRides: _rides.where((r) => r.status == RideLifecycleStatus.inProgress).length,
      completedRides24h: 1840,
    );
  }

  @override
  Future<List<DriverListItem>> listDrivers({String? query}) async {
    await _delay();
    if (query == null || query.isEmpty) return List.of(_drivers);
    final q = query.toLowerCase();
    return _drivers
        .where((d) => d.displayName.toLowerCase().contains(q) || d.phone.contains(q))
        .toList();
  }

  @override
  Future<DriverProfile> getDriver(String id) async {
    await _delay();
    final item = _drivers.firstWhere((d) => d.id == id, orElse: () => _drivers.first);
    return DriverProfile(
      id: item.id,
      displayName: item.displayName,
      phone: item.phone,
      email: '${item.id}@drivers.ugo.test',
      city: 'Bengaluru',
      presence: item.presence,
      kycStatus: item.kycStatus,
      vehicle: DriverVehicle(
        id: 'v-$id',
        registrationNumber: 'KA01AB1234',
        modelName: 'Swift Dzire',
        color: 'Pearl White',
        type: const VehicleTypeRef(id: 'vt1', name: 'Sedan'),
        subtype: const VehicleSubtypeRef(id: 'vs1', label: 'Comfort', vehicleTypeId: 'vt1'),
      ),
      wallet: const DriverWalletSummary(
        balance: 8420,
        pendingWithdrawals: 4200,
        lifetimeEarnings: 412000,
      ),
      rating: item.rating,
      completedRides: 1842,
    );
  }

  @override
  Future<void> setDriverPresence(String driverId, DriverPresenceStatus status) async {
    await _delay();
    final idx = _drivers.indexWhere((d) => d.id == driverId);
    if (idx >= 0) {
      _drivers[idx] = DriverListItem(
        id: _drivers[idx].id,
        displayName: _drivers[idx].displayName,
        phone: _drivers[idx].phone,
        presence: status,
        kycStatus: _drivers[idx].kycStatus,
        vehicleLabel: _drivers[idx].vehicleLabel,
        rating: _drivers[idx].rating,
      );
    }
  }

  @override
  Future<void> setDriverKycStatus(String driverId, KycReviewStatus status) async {
    await _delay();
    final idx = _drivers.indexWhere((d) => d.id == driverId);
    if (idx >= 0) {
      _drivers[idx] = DriverListItem(
        id: _drivers[idx].id,
        displayName: _drivers[idx].displayName,
        phone: _drivers[idx].phone,
        presence: _drivers[idx].presence,
        kycStatus: status,
        vehicleLabel: _drivers[idx].vehicleLabel,
        rating: _drivers[idx].rating,
      );
    }
  }

  @override
  Future<List<RiderListItem>> listRiders({String? query}) async {
    await _delay();
    if (query == null || query.isEmpty) return List.of(_riders);
    final q = query.toLowerCase();
    return _riders
        .where((r) => r.displayName.toLowerCase().contains(q) || r.phone.contains(q))
        .toList();
  }

  @override
  Future<RiderProfile> getRider(String id) async {
    await _delay();
    final item = _riders.firstWhere((r) => r.id == id, orElse: () => _riders.first);
    return RiderProfile(
      id: item.id,
      displayName: item.displayName,
      phone: item.phone,
      email: '${item.id}@riders.ugo.test',
      wallet: RiderWallet(balance: item.walletBalance, currency: 'INR'),
      isBlocked: item.isBlocked,
      completedRides: 64,
    );
  }

  @override
  Future<void> setRiderBlocked(String riderId, bool blocked) async {
    await _delay();
    final idx = _riders.indexWhere((r) => r.id == riderId);
    if (idx >= 0) {
      final cur = _riders[idx];
      _riders[idx] = RiderListItem(
        id: cur.id,
        displayName: cur.displayName,
        phone: cur.phone,
        isBlocked: blocked,
        walletBalance: cur.walletBalance,
      );
    }
  }

  @override
  Future<List<RideSummary>> listRides({RideLifecycleStatus? filter}) async {
    await _delay();
    if (filter == null) return List.of(_rides);
    return _rides.where((r) => r.status == filter).toList();
  }

  @override
  Future<RideDetail> getRide(String id) async {
    await _delay();
    final summary = _rides.firstWhere((r) => r.id == id, orElse: () => _rides.first);
    return RideDetail(
      summary: summary,
      pickup: const GeoPoint(latitude: 12.9716, longitude: 77.5946),
      drop: const GeoPoint(latitude: 12.9279, longitude: 77.6271),
      routePolyline: '_p~7Fps6R...mock',
      commission: 18,
      surgeMultiplier: 1.15,
    );
  }

  @override
  Future<void> assignDriverToRide({
    required String rideId,
    required String driverId,
  }) async {
    await _delay();
    final idx = _rides.indexWhere((r) => r.id == rideId);
    if (idx < 0) return;
    final cur = _rides[idx];
    final driver = _drivers.firstWhere((d) => d.id == driverId, orElse: () => _drivers.first);
    _rides[idx] = RideSummary(
      id: cur.id,
      riderName: cur.riderName,
      driverName: driver.displayName,
      status: RideLifecycleStatus.assigned,
      pickupLabel: cur.pickupLabel,
      dropLabel: cur.dropLabel,
      fare: cur.fare,
      requestedAt: cur.requestedAt,
      driverId: driver.id,
      riderId: cur.riderId,
    );
  }

  @override
  Future<void> cancelRideAsAdmin(String rideId, {String? reason}) async {
    await _delay();
    final idx = _rides.indexWhere((r) => r.id == rideId);
    if (idx < 0) return;
    final cur = _rides[idx];
    _rides[idx] = RideSummary(
      id: cur.id,
      riderName: cur.riderName,
      driverName: cur.driverName,
      status: RideLifecycleStatus.cancelledByAdmin,
      pickupLabel: cur.pickupLabel,
      dropLabel: cur.dropLabel,
      fare: cur.fare,
      requestedAt: cur.requestedAt,
      driverId: cur.driverId,
      riderId: cur.riderId,
    );
  }

  @override
  Future<List<WithdrawalRequest>> listWithdrawals({WithdrawalStatus? status}) async {
    await _delay();
    if (status == null) return List.of(_withdrawals);
    return _withdrawals.where((w) => w.status == status).toList();
  }

  @override
  Future<void> decideWithdrawal({
    required String id,
    required WithdrawalStatus decision,
  }) async {
    await _delay();
    final idx = _withdrawals.indexWhere((w) => w.id == id);
    if (idx < 0) return;
    final cur = _withdrawals[idx];
    _withdrawals[idx] = WithdrawalRequest(
      id: cur.id,
      driverId: cur.driverId,
      driverName: cur.driverName,
      amount: cur.amount,
      status: decision,
      requestedAt: cur.requestedAt,
      bankMasked: cur.bankMasked,
    );
  }

  @override
  Future<List<RiderComplaint>> listComplaints({ComplaintStatus? status}) async {
    await _delay();
    if (status == null) return List.of(_complaints);
    return _complaints.where((c) => c.status == status).toList();
  }

  @override
  Future<void> updateComplaintStatus(String id, ComplaintStatus status) async {
    await _delay();
    final idx = _complaints.indexWhere((c) => c.id == id);
    if (idx < 0) return;
    final cur = _complaints[idx];
    _complaints[idx] = RiderComplaint(
      id: cur.id,
      riderId: cur.riderId,
      subject: cur.subject,
      body: cur.body,
      status: status,
      createdAt: cur.createdAt,
      rideId: cur.rideId,
    );
  }

  @override
  Future<List<PromoCode>> listPromoCodes() async {
    await _delay();
    return List.of(_promos);
  }

  @override
  Future<GlobalSettingsSnapshot> getGlobalSettings() async {
    await _delay();
    return GlobalSettingsSnapshot(
      fare: _fare,
      surgeBands: List.of(_surge),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 12)),
    );
  }

  @override
  Future<void> updateFareSettings(FareSettings settings) async {
    await _delay();
    _fare = settings;
  }

  @override
  Future<List<AdminNotificationJob>> listNotificationJobs() async {
    await _delay();
    return List.of(_notifJobs);
  }

  @override
  Future<void> enqueueNotification(AdminNotificationDraft draft) async {
    await _delay();
    _notifJobs.insert(
      0,
      AdminNotificationJob(
        id: 'n${_notifJobs.length + 1}',
        title: draft.title,
        status: 'queued',
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<List<VehicleTypeRef>> listVehicleTypes() async {
    await _delay();
    return const [
      VehicleTypeRef(id: 'vt1', name: 'Sedan'),
      VehicleTypeRef(id: 'vt2', name: 'Bike'),
      VehicleTypeRef(id: 'vt3', name: 'Auto'),
    ];
  }
}
