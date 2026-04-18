import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';

/// Pops the GoRouter stack when the user presses the system back button and a
/// route can be popped; otherwise navigates to the dashboard (or a custom
/// fallback). Use around admin [Scaffold]s that show the navigation drawer.
///
/// Omit on the root [DashboardScreen] so the OS back button can exit the app.
class AdminPopScope extends StatelessWidget {
  const AdminPopScope({
    super.key,
    required this.child,
    this.fallbackRouteName,
    this.onCannotPop,
  }) : assert(
          fallbackRouteName == null || onCannotPop == null,
          'Use only one of fallbackRouteName or onCannotPop.',
        );

  final Widget child;

  /// When [onCannotPop] is null, navigates to this named route if nothing can pop.
  final String? fallbackRouteName;

  /// When the router cannot pop, invoked instead of a dashboard navigation.
  /// Use for detail screens with custom back behavior (e.g. return to list).
  final VoidCallback? onCannotPop;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    return PopScope(
      canPop: router.canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (onCannotPop != null) {
          onCannotPop!();
        } else {
          context.goNamedAuth(
            fallbackRouteName ?? DashboardScreen.routeName,
            context.mounted,
          );
        }
      },
      child: child,
    );
  }
}
