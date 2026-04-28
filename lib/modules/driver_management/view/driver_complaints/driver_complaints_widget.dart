import '/shared/widgets/admin_drawer.dart';
import '/shared/widgets/admin_pop_scope.dart';
import '/shared/widgets/responsive_body.dart';
import '/index.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';
import '/config/theme/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Note: Ensure you have your model file created if you are using FlutterFlow's standard architecture.
// import 'driver_complaints_model.dart';
// export 'driver_complaints_model.dart';

class DriverComplaintsWidget extends StatefulWidget {
  const DriverComplaintsWidget({super.key});

  static String routeName = 'DriverComplaints';
  static String routePath = '/driver-complaints';

  @override
  State<DriverComplaintsWidget> createState() => _DriverComplaintsWidgetState();
}

class _DriverComplaintsWidgetState extends State<DriverComplaintsWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  // late DriverComplaintsModel _model; // Uncomment if using a model

  // MOCK DATA: Replace this with your actual API call data later
  final List<Map<String, dynamic>> _mockDriverComplaints = [
    {
      'id': 'DCMP-44556',
      'name': 'Rajesh Kumar (Driver)',
      'avatar': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NjQ1NzUyMDB8&ixlib=rb-4.1.0&q=80&w=1080',
      'status': 'Pending',
      'date': 'Oct 28, 2026',
      'preview': 'Passenger booked a Mini Cab but tried to fit 6 people inside. Refused to cancel the ride when informed of the limit.',
    },
    {
      'id': 'DCMP-99882',
      'name': 'Suresh Reddy (Driver)',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NjQ1NzUyMDF8&ixlib=rb-4.1.0&q=80&w=1080',
      'status': 'Resolved',
      'date': 'Oct 26, 2026',
      'preview': 'Passenger made a mess with food in the back seat and refused to pay the cleaning fee.',
    },
    {
      'id': 'DCMP-11223',
      'name': 'Anita Desai (Driver)',
      'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NjQ1NzUyMDJ8&ixlib=rb-4.1.0&q=80&w=1080',
      'status': 'In Review',
      'date': 'Oct 25, 2026',
      'preview': 'Passenger placed the pin at the wrong location and argued aggressively when I arrived at the exact pinned spot.',
    },
  ];

  @override
  void initState() {
    super.initState();
    // _model = createModel(context, () => DriverComplaintsModel()); // Uncomment if using a model
  }

  @override
  void dispose() {
    // _model.dispose(); // Uncomment if using a model
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminPopScope(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
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
              'Driver Complaints',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                color: Colors.white,
                fontSize: 22.0,
              ),
            ),
            centerTitle: false,
            elevation: 0,
          ),
          body: _buildComplaintsList(_mockDriverComplaints),
        ),
      ),
    );
  }

  // --- UI HELPER METHODS ---

  Widget _buildComplaintsList(List<Map<String, dynamic>> complaints) {
    if (complaints.isEmpty) {
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
                  Icons.local_taxi_rounded,
                  size: 64,
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Complaints Found',
                style: FlutterFlowTheme.of(context).titleLarge.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'There are currently no complaints filed by drivers against users.',
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

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: complaints.length,
          itemBuilder: (context, index) {
            final complaint = complaints[index];
            return _buildComplaintTile(complaint);
          },
        ),
      ),
    );
  }

  Widget _buildComplaintTile(Map<String, dynamic> data) {
    final theme = FlutterFlowTheme.of(context);

    // Determine status color
    Color statusColor;
    Color statusBgColor;
    switch (data['status'].toString().toLowerCase()) {
      case 'resolved':
        statusColor = theme.success;
        statusBgColor = theme.success.withValues(alpha: 0.1);
        break;
      case 'in review':
        statusColor = theme.warning;
        statusBgColor = theme.warning.withValues(alpha: 0.1);
        break;
      default: // Pending
        statusColor = theme.error;
        statusBgColor = theme.error.withValues(alpha: 0.1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.alternate, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: Navigate to complaint details page when ready
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Viewing complaint ${data['id']}')),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.alternate, width: 1),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(data['avatar']),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              data['name'],
                              style: theme.titleMedium.override(
                                font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                                color: theme.primaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            data['date'],
                            style: theme.labelSmall.override(
                              font: GoogleFonts.inter(),
                              color: theme.secondaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // ID
                      Text(
                        'ID: ${data['id']}',
                        style: theme.labelSmall.override(
                          font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          color: theme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Preview Text
                      Text(
                        data['preview'],
                        style: theme.bodyMedium.override(
                          font: GoogleFonts.inter(),
                          color: theme.secondaryText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),

                      // Footer Row (Status & Arrow)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              data['status'],
                              style: theme.bodySmall.override(
                                font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                color: statusColor,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: theme.secondaryText,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}