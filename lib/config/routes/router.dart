import 'package:flutter/material.dart';

import '/modules/ride_management/view/ride_management_screen.dart';
import '/config/routes/nav.dart';
import '/config/routes/serialization_util.dart';
import '/index.dart';
import '/modules/finance/finance_module.dart';

GoRouter createRouter(AppStateNotifier appStateNotifier) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: appStateNotifier,
    redirect: (context, state) {
      if (appStateNotifier.loading) return null;
      if (state.uri.path == '/') {
        return appStateNotifier.loggedIn ? '/dashboardPage' : '/login';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      FFRoute(
        name: LoginWidget.routeName,
        path: LoginWidget.routePath,
        requireAuth: false,
        builder: (context, params) => const LoginWidget(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: DashboardScreen.routeName,
        path: DashboardScreen.routePath,
        requireAuth: true,
        builder: (context, params) => const DashboardScreen(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: UserModuleHubScreen.routeName,
        path: UserModuleHubScreen.routePath,
        requireAuth: true,
        builder: (context, params) => const UserModuleHubScreen(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: UserManagementWidget.routeName,
        path: UserManagementWidget.routePath,
        requireAuth: true,
        builder: (context, params) => const UserManagementWidget(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: OperationsModuleHubScreen.routeName,
        path: OperationsModuleHubScreen.routePath,
        requireAuth: true,
        builder: (context, params) => const OperationsModuleHubScreen(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: AllusersWidget.routeName,
        path: AllusersWidget.routePath,
        requireAuth: true,
        builder: (context, params) => const AllusersWidget(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: DriversWidget.routeName,
        path: DriversWidget.routePath,
        requireAuth: true,
        builder: (context, params) => const DriversWidget(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: DriverLicenseWidget.routeName,
        path: DriverLicenseWidget.routePath,
        requireAuth: true,
        builder: (context, params) {
          final userId = params.getParam('userId', ParamType.int) as int?;
          return DriverLicenseWidget(userId: userId);
        },
      ).toRoute(appStateNotifier),
      FFRoute(
        name: DriverDetailsWidget.routeName,
        path: DriverDetailsWidget.routePath,
        requireAuth: true,
        builder: (context, params) {
          final driverId = params.getParam('driverId', ParamType.int) as int?;
          final openDocumentsOnLoad =
              params.getParam('openDocuments', ParamType.bool) as bool? ?? false;
          return DriverDetailsWidget(
            driverId: driverId,
            openDocumentsOnLoad: openDocumentsOnLoad,
          );
        },
      ).toRoute(appStateNotifier),
      FFRoute(
        name: UserDetailsWidget.routeName,
        path: UserDetailsWidget.routePath,
        requireAuth: true,
        builder: (context, params) {
          final userId = params.getParam('userId', ParamType.int) as int?;
          return UserDetailsWidget(userId: userId);
        },
      ).toRoute(appStateNotifier),
      FFRoute(
        name: AddUserWidget.routeName,
        path: AddUserWidget.routePath,
        requireAuth: true,
        builder: (context, params) => const AddUserWidget(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: AddDriverWidget.routeName,
        path: AddDriverWidget.routePath,
        requireAuth: true,
        builder: (context, params) => const AddDriverWidget(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: BlockedUsersWidget.routeName,
        path: BlockedUsersWidget.routePath,
        requireAuth: true,
        builder: (context, params) => const BlockedUsersWidget(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: KycPendingWidget.routeName,
        path: KycPendingWidget.routePath,
        requireAuth: true,
        builder: (context, params) => const KycPendingWidget(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: DriverKycListWidget.routeName,
        path: DriverKycListWidget.routePath,
        requireAuth: true,
        builder: (context, params) => const DriverKycListWidget(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: EarningsScreen.routeName,
        path: EarningsScreen.routePath,
        requireAuth: true,
        builder: (context, params) => const EarningsScreen(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: PromoCodesWidget.routeName,
        path: PromoCodesWidget.routePath,
        requireAuth: true,
        builder: (context, params) => const PromoCodesWidget(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: UserComplaintsWidget.routeName,
        path: UserComplaintsWidget.routePath,
        requireAuth: true,
        builder: (context, params) => const UserComplaintsWidget(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: ReviewsWidget.routeName,
        path: ReviewsWidget.routePath,
        requireAuth: true,
        builder: (context, params) => const ReviewsWidget(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: NotificationsWidget.routeName,
        path: NotificationsWidget.routePath,
        requireAuth: true,
        builder: (context, params) => const NotificationsWidget(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: AddVehicleWidget.routeName,
        path: AddVehicleWidget.routePath,
        requireAuth: true,
        builder: (context, params) => const AddVehicleWidget(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: AddVehicleTypeWidget.routeName,
        path: AddVehicleTypeWidget.routePath,
        requireAuth: true,
        builder: (context, params) => const AddVehicleTypeWidget(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: VehiclesListWidget.routeName,
        path: VehiclesListWidget.routePath,
        requireAuth: true,
        builder: (context, params) => const VehiclesListWidget(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: IncentivesWidget.routeName,
        path: IncentivesWidget.routePath,
        requireAuth: true,
        builder: (context, params) => const IncentivesWidget(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: AddIncentiveWidget.routeName,
        path: AddIncentiveWidget.routePath,
        requireAuth: true,
        builder: (context, params) => const AddIncentiveWidget(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: IncentiveDetailsWidget.routeName,
        path: IncentiveDetailsWidget.routePath,
        requireAuth: true,
        builder: (context, params) => const IncentiveDetailsWidget(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: RideManagementScreen.routeName,
        path: RideManagementScreen.routePath,
        requireAuth: true,
        builder: (context, params) => const RideManagementScreen(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: RideDetailsWidget.routeName,
        path: RideDetailsWidget.routePath,
        requireAuth: true,
        builder: (context, params) {
          final rideId = params.getParam('rideId', ParamType.int) as int?;
          return RideDetailsWidget(rideId: rideId);
        },
      ).toRoute(appStateNotifier),
      FFRoute(
        name: LiveDriverMapWidget.routeName,
        path: LiveDriverMapWidget.routePath,
        requireAuth: true,
        builder: (context, params) => const LiveDriverMapWidget(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: WalletManagementWidget.routeName,
        path: WalletManagementWidget.routePath,
        requireAuth: true,
        builder: (context, params) => const WalletManagementWidget(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: FareSurgeSettingsWidget.routeName,
        path: FareSurgeSettingsWidget.routePath,
        requireAuth: true,
        builder: (context, params) => const FareSurgeSettingsWidget(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: DriverPayoutsScreen.routeName,
        path: DriverPayoutsScreen.routePath,
        requireAuth: true,
        builder: (context, params) => const DriverPayoutsScreen(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: FinanceReportsScreen.routeName,
        path: FinanceReportsScreen.routePath,
        requireAuth: true,
        builder: (context, params) => const FinanceReportsScreen(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: FinanceControlHubScreen.routeName,
        path: FinanceControlHubScreen.routePath,
        requireAuth: true,
        builder: (context, params) {
          final tab = params.getParam('tab', ParamType.int) as int? ?? 0;
          final rideId = params.getParam('rideId', ParamType.int) as int?;
          final userId = params.getParam('userId', ParamType.int) as int?;
          final driverId = params.getParam('driverId', ParamType.int) as int?;
          return FinanceControlHubScreen(
            initialTabIndex: tab,
            initialRideId: rideId,
            initialUserId: userId,
            initialDriverId: driverId,
          );
        },
      ).toRoute(appStateNotifier),
      FFRoute(
        name: FinanceAuditTimelineWidget.routeName,
        path: FinanceAuditTimelineWidget.routePath,
        requireAuth: true,
        builder: (context, params) {
          final userId = params.getParam('userId', ParamType.int) as int?;
          final driverId = params.getParam('driverId', ParamType.int) as int?;
          return FinanceAuditTimelineWidget(userId: userId, driverId: driverId);
        },
      ).toRoute(appStateNotifier),
      FFRoute(
        name: FinanceAutomationWidget.routeName,
        path: FinanceAutomationWidget.routePath,
        requireAuth: true,
        builder: (context, params) => const FinanceAutomationWidget(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: FinanceSlaDashboardWidget.routeName,
        path: FinanceSlaDashboardWidget.routePath,
        requireAuth: true,
        builder: (context, params) => const FinanceSlaDashboardWidget(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: ZoneManagementWidget.routeName,
        path: ZoneManagementWidget.routePath,
        requireAuth: true,
        builder: (context, params) => const ZoneManagementWidget(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: SubAdminsWidget.routeName,
        path: SubAdminsWidget.routePath,
        requireAuth: true,
        builder: (context, params) => const SubAdminsWidget(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: AppSettingsWidget.routeName,
        path: AppSettingsWidget.routePath,
        requireAuth: true,
        builder: (context, params) => const AppSettingsWidget(),
      ).toRoute(appStateNotifier),
      FFRoute(
        name: AccountWidget.routeName,
        path: AccountWidget.routePath,
        requireAuth: true,
        builder: (context, params) => const AccountWidget(),
      ).toRoute(appStateNotifier),
    ],
  );
}
