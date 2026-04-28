import 'package:flutter/material.dart';

import '/modules/vehicle_management/screens/vehicle_catalog_screen.dart';
import 'vehicles_list_model.dart';

export 'vehicles_list_model.dart';

/// Route entry-point for [VehiclesListWidget.routePath].
class VehiclesListWidget extends StatelessWidget {
  const VehiclesListWidget({super.key});

  static String routeName = 'VehiclesList';
  static String routePath = '/vehicles-list';

  @override
  Widget build(BuildContext context) => const VehicleCatalogScreen();
}
