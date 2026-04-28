import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '/shared/widgets/admin_pop_scope.dart';
import '/shared/widgets/admin_drawer.dart';
import '/config/theme/flutter_flow_theme.dart';

class WalletAdjustScreen extends ConsumerStatefulWidget {
  const WalletAdjustScreen({super.key});

  static String routeName = 'WalletAdjustScreen';
  static String routePath = '/wallet-adjust';

  @override
  ConsumerState<WalletAdjustScreen> createState() => _WalletAdjustScreenState();
}

class _WalletAdjustScreenState extends ConsumerState<WalletAdjustScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

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
            'Adjust Wallet',
            style: theme.headlineMedium.override(
              font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
              color: Colors.white,
              fontSize: 22,
            ),
          ),
        ),
        body: Center(
          child: Text(
            'Wallet Adjust Console (Coming Soon)',
            style: theme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
