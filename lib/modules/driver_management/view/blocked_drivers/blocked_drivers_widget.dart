import '/shared/widgets/admin_drawer.dart';
import '/shared/widgets/admin_pop_scope.dart';
import '/shared/widgets/responsive_body.dart';
import '/index.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';
import '/config/theme/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class BlockedDriversWidget extends StatefulWidget {
  const BlockedDriversWidget({super.key});

  static String routeName = 'BlockedDrivers';
  static String routePath = '/blocked-drivers';

  @override
  State<BlockedDriversWidget> createState() => _BlockedDriversWidgetState();
}

class _BlockedDriversWidgetState extends State<BlockedDriversWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // MOCK DATA: Replace this with your actual API call data
  List<Map<String, dynamic>> _mockBlockedDrivers = [
    {
      'id': 'DRV-8472',
      'name': 'Rajesh Kumar',
      'avatar': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NjQ1NzUyMDB8&ixlib=rb-4.1.0&q=80&w=1080',
      'phone': '+91 98765 43210',
      'vehicle': 'Mini Cab - TS 09 EA 1234',
      'reason': 'Multiple reports of reckless driving and refusing to use the app navigation.',
    },
    {
      'id': 'DRV-9122',
      'name': 'Suresh Reddy',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NjQ1NzUyMDF8&ixlib=rb-4.1.0&q=80&w=1080',
      'phone': '+91 91234 56789',
      'vehicle': 'Auto Rickshaw - TS 07 AB 9876',
      'reason': 'Asking passengers for offline payments and canceling rides excessively.',
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _unblockDriver(String driverId, String driverName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Unblock Driver',
          style: FlutterFlowTheme.of(context).headlineSmall.override(
            font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
          ),
        ),
        content: Text(
          'Are you sure you want to restore $driverName\'s access to the driver platform?',
          style: FlutterFlowTheme.of(context).bodyMedium,
        ),
        actionsPadding: const EdgeInsets.all(16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: FlutterFlowTheme.of(context).secondaryText),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Unblock Driver'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // TODO: Replace with your actual Unblock API Call
      setState(() {
        _mockBlockedDrivers.removeWhere((driver) => driver['id'] == driverId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Driver unblocked successfully'),
          backgroundColor: Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminPopScope(
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        drawer: buildAdminDrawer(context),
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
            onPressed: () => context.goNamedAuth(DashboardScreen.routeName, context.mounted),
          ),
          title: Text(
            'Blocked Drivers',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
              color: Colors.white,
              fontSize: 22.0,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 24),
              onPressed: () {
                // TODO: Refresh your API data here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Refreshing list...')),
                );
              },
              tooltip: 'Refresh List',
            ),
          ],
          elevation: 0,
        ),
        body: _mockBlockedDrivers.isEmpty
            ? _buildEmptyState()
            : _buildDriverList(),
      ),
    );
  }

  // --- UI HELPER METHODS ---

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primaryBackground,
                shape: BoxShape.circle,
                border: Border.all(color: FlutterFlowTheme.of(context).alternate),
              ),
              child: Icon(
                Icons.verified_user_rounded,
                size: 64,
                color: FlutterFlowTheme.of(context).success,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No blocked drivers',
              style: FlutterFlowTheme.of(context).titleLarge.override(
                font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your driver fleet is in good standing. Any drivers blocked by administrators will appear here.',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(),
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverList() {
    return ResponsiveContainer(
      maxWidth: 800,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _mockBlockedDrivers.length + 1,
        itemBuilder: (context, index) {
          // Header Row
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Icon(Icons.block_rounded, size: 20, color: FlutterFlowTheme.of(context).secondaryText),
                  const SizedBox(width: 8),
                  Text(
                    '${_mockBlockedDrivers.length} Restricted Driver${_mockBlockedDrivers.length == 1 ? '' : 's'}',
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                      font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
                  ),
                ],
              ),
            );
          }

          final driver = _mockBlockedDrivers[index - 1];
          return _buildDriverCard(driver);
        },
      ),
    );
  }

  Widget _buildDriverCard(Map<String, dynamic> driver) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.alternate),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Avatar, Info, Action
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.alternate, width: 1),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(driver['avatar']),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Driver Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              driver['name'],
                              style: theme.titleMedium.override(
                                font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                                color: theme.primaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                driver['id'],
                                style: theme.labelSmall.override(
                                  font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                  color: theme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.phone_rounded, size: 14, color: theme.secondaryText),
                          const SizedBox(width: 4),
                          Text(
                            driver['phone'],
                            style: theme.bodySmall.override(
                              font: GoogleFonts.inter(),
                              color: theme.secondaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.local_taxi_rounded, size: 14, color: theme.secondaryText),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              driver['vehicle'],
                              style: theme.bodySmall.override(
                                font: GoogleFonts.inter(),
                                color: theme.secondaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Unblock Button
                FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.success.withValues(alpha: 0.1),
                    foregroundColor: theme.success,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.lock_open_rounded, size: 18),
                  label: Text(
                    'Unblock',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  onPressed: () => _unblockDriver(driver['id'], driver['name']),
                ),
              ],
            ),

            // Bottom Row: Reason Box
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.error.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.error.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: theme.error,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reason for Restriction',
                          style: theme.labelSmall.override(
                            font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                            color: theme.error,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          driver['reason'],
                          style: theme.bodyMedium.override(
                            font: GoogleFonts.inter(),
                            color: theme.primaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}