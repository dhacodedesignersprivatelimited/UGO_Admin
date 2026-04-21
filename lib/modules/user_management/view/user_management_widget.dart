import 'package:flutter/material.dart';
import 'user_management_screen.dart';

class UserManagementWidget extends StatefulWidget {
  const UserManagementWidget({super.key});

  static const String routeName = 'userManagement';
  static const String routePath = '/userManagement';

  @override
  State<UserManagementWidget> createState() => _UserManagementWidgetState();
}

class _UserManagementWidgetState extends State<UserManagementWidget> {
  @override
  Widget build(BuildContext context) {
    return const UserManagementScreen();
  }
}