import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/components/admin_drawer.dart';
import '/components/admin_pop_scope.dart';
import '/components/responsive_body.dart';

/// Reusable admin scaffold with orange theme and navigation drawer
class AdminScaffold extends StatelessWidget {
  const AdminScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return AdminPopScope(
      child: Scaffold(
        backgroundColor: theme.primaryBackground,
        appBar: AppBar(
          backgroundColor: theme.primary,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: true,
          title: Text(
            title,
            style: theme.headlineMedium.override(
              font: GoogleFonts.interTight(),
              color: Colors.white,
              fontSize: 22.0,
            ),
          ),
          actions: actions ?? [],
          centerTitle: false,
          elevation: 2.0,
        ),
        drawer: buildAdminDrawer(context),
        body: SafeArea(
          child: ResponsiveContainer(
            padding: EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}
