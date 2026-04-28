import 'package:flutter/material.dart';

import '../../screens/user_management_screen_v2.dart';

class AllusersWidget extends StatelessWidget {
  const AllusersWidget({super.key});

  static String routeName = 'Allusers';
  static String routePath = '/allusers';

  @override
  Widget build(BuildContext context) {
    return const UserManagementScreenV2();
  }
}