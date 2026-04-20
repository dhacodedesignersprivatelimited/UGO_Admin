/// Typed route names for the modular admin shell. Legacy FlutterFlow routes
/// continue to live in [createRouter]; these hubs wrap navigation to them.
class AdminRouteCatalog {
  static const driverHub = DriverModulePaths.routeName;
  static const userHub = UserModulePaths.routeName;
  static const operationsHub = OperationsModulePaths.routeName;
}

class DriverModulePaths {
  static const routeName = 'adminDriverHub';
  static const routePath = '/admin/drivers';
}

class UserModulePaths {
  static const routeName = 'adminUserHub';
  static const routePath = '/admin/users';
}

class OperationsModulePaths {
  static const routeName = 'adminOpsHub';
  static const routePath = '/admin/operations';
}
