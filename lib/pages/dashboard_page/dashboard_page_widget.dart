import '/components/admin_drawer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dashboard/view/dashboard_screen.dart';
import 'dashboard/dashboard_tokens.dart';
import 'dashboard_page_model.dart';

export 'dashboard_page_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static String routeName = 'DashboardPage';
  static String routePath = '/dashboardPage';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardPageModel _model;

  @override
  void initState() {
    super.initState();
    _model = DashboardPageModel();
    _model.initialize();
    _model.startUserDriverStatsPolling();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardTokens.pageBackground,
      appBar: AppBar(
        backgroundColor: DashboardTokens.primaryOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'DASHBOARD',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            fontSize: 15,
            color: Colors.white,
          ),
        ),
      ),
      drawer: buildAdminDrawer(context),
      body: DashboardScreenView(
        model: _model,
        onRefresh: _model.loadAll,
      ),
    );
  }
}
