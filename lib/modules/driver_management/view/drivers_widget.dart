import 'package:flutter/material.dart';
import 'driver_management_screen.dart';

class DriversWidget extends StatefulWidget {
  const DriversWidget({super.key});

  static String routeName = 'drivers';
  static String routePath = '/drivers';

  @override
  State<DriversWidget> createState() => _DriversWidgetState();
}

class _DriversWidgetState extends State<DriversWidget> {
  @override
  Widget build(BuildContext context) {
    return const DriverManagementScreen();
  }
}
