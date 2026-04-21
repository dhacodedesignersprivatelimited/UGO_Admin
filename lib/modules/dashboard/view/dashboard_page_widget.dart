import '/shared/widgets/admin_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dashboard_screen.dart';
import 'dashboard_tokens.dart';
import '../view_model/dashboard_viewmodel.dart';

export '../view_model/dashboard_viewmodel.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  static String routeName = 'DashboardPage';
  static String routePath = '/dashboardPage';

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Kick off data loading via the ViewModel (no setState).
    Future.microtask(() {
      ref.read(dashboardViewModelProvider.notifier).initialize();
      ref.read(dashboardViewModelProvider.notifier).startPolling();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardViewModelProvider);
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
        state: state,
        onRefresh: () =>
            ref.read(dashboardViewModelProvider.notifier).loadAll(),
      ),
    );
  }
}
