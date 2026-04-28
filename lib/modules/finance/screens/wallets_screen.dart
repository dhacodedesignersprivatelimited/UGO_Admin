import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '/shared/widgets/admin_pop_scope.dart';
import '/shared/widgets/admin_drawer.dart';
import '/config/theme/flutter_flow_theme.dart';

import 'user_wallets_screen.dart';
import 'driver_wallets_screen.dart';

class WalletsScreen extends ConsumerStatefulWidget {
  const WalletsScreen({super.key});

  static String routeName = 'WalletsScreen';
  static String routePath = '/wallets';

  @override
  ConsumerState<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends ConsumerState<WalletsScreen> with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return AdminPopScope(
      child: Scaffold(
        key: scaffoldKey,
        drawer: buildAdminDrawer(context),
        backgroundColor: theme.primaryBackground,
        appBar: AppBar(
          backgroundColor: theme.primary,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
          centerTitle: true,
          title: Text(
            'Manage Wallets',
            style: theme.headlineMedium.override(
              font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
              color: Colors.white,
              fontSize: 22,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'User Wallets'),
              Tab(text: 'Driver Wallets'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            // Using the screens we created earlier as nested widgets
            UserWalletsScreen(),
            DriverWalletsScreen(),
          ],
        ),
      ),
    );
  }
}
