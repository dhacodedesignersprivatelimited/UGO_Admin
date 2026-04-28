import 'package:flutter/material.dart';

import '../../screens/user_management_screen_v2.dart';

class AllusersWidget extends StatelessWidget {
  const AllusersWidget({super.key});

  static String routeName = 'UserManagementScreenV2';
  static String routePath = '/UserManagementScreenV2';

  @override
  Widget build(BuildContext context) {
    return const UserManagementScreenV2();
  }
}
