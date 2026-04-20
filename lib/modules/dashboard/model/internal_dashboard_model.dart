// BLoC/MVVM: dashboard state is now managed by [DashboardCubit].
// [DashboardPageModel] is kept as a type alias for backward compatibility
// while page-level widgets are migrated to [DashboardState].
export '../view_model/dashboard_cubit.dart' show DashboardCubit, DashboardState;

// Legacy alias — widgets still referencing DashboardPageModel will use
// the ChangeNotifier-based ViewModel until they are individually migrated.
export '../view_model/dashboard_viewmodel.dart' show DashboardPageModel;
