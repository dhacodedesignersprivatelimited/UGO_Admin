import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/components/admin_scaffold.dart';
import '/index.dart';
import 'ride_management_model.dart';
export 'ride_management_model.dart';

class RideManagementWidget extends StatefulWidget {
  const RideManagementWidget({super.key});

  static String routeName = 'RideManagement';
  static String routePath = '/ride-management';

  @override
  State<RideManagementWidget> createState() => _RideManagementWidgetState();
}

class _RideManagementWidgetState extends State<RideManagementWidget>
    with TickerProviderStateMixin {
  late RideManagementModel _model;
  late TabController _tabController;
  List<dynamic> _allRides = [];
  bool _isLoading = true;
  String? _error;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RideManagementModel());
    _tabController = TabController(length: 4, vsync: this);
    _loadRides();
  }

  Future<void> _loadRides() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await GetRidesCall.call(token: currentAuthenticationToken);
      if (!response.succeeded) {
        setState(() {
          _error = 'Failed to load rides (${response.statusCode})';
          _isLoading = false;
        });
        return;
      }
      final list = GetRidesCall.data(response.jsonBody);
      setState(() {
        _allRides = list ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _model.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return AdminScaffold(
      title: 'Ride Management',
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primary.withOpacity(0.1), theme.secondaryBackground],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(color: theme.primary.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: theme.primary,
              unselectedLabelColor: theme.secondaryText,
              indicatorColor: theme.primary,
              tabs: const [
                Tab(text: 'Running'),
                Tab(text: 'Completed'),
                Tab(text: 'Scheduled'),
                Tab(text: 'Cancelled'),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTripList(_ridesByStatus('running'), 'running', theme),
                      _buildTripList(_ridesByStatus('completed'), 'completed', theme),
                      _buildTripList(_ridesByStatus('scheduled'), 'scheduled', theme),
                      _buildTripList(_ridesByStatus('cancelled'), 'cancelled', theme),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  List<dynamic> _ridesByStatus(String tab) {
    return _allRides.where((r) {
      final s = (r is Map ? r['ride_status'] : r.ride_status)?.toString().toLowerCase() ?? '';
      switch (tab) {
        case 'running':
          return s.contains('progress') || s == 'reached' || s == 'driver_arrived';
        case 'completed':
          return s == 'completed';
        case 'scheduled':
          return s == 'requested' || s == 'accepted' || s.contains('pending');
        case 'cancelled':
          return s.contains('cancel');
        default:
          return false;
      }
    }).toList();
  }

  Widget _buildTripList(List<dynamic> rides, String status, FlutterFlowTheme theme) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: theme.error),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center, style: theme.bodyMedium),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _loadRides,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (rides.isEmpty) {
      return Center(
        child: Text(
          'No $status rides',
          style: theme.bodyLarge.override(font: GoogleFonts.inter()),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadRides,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rides.length,
        itemBuilder: (context, index) {
          final r = rides[index];
          final id = r is Map ? r['id'] : r.id;
          final pickup = r is Map ? r['pickup_location_address'] : r.pickup_location_address;
          final drop = r is Map ? r['drop_location_address'] : r.drop_location_address;
          final fare = r is Map ? r['final_fare'] ?? r['estimated_fare'] : r.final_fare ?? r.estimated_fare;
          final rideStatus = (r is Map ? r['ride_status'] : r.ride_status)?.toString() ?? status;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: CircleAvatar(
                backgroundColor: theme.primary.withOpacity(0.2),
                child: Icon(Icons.local_taxi, color: theme.primary),
              ),
              title: Text(
                'RIDE-${id ?? index + 1}',
                style: theme.titleMedium.override(font: GoogleFonts.inter()),
              ),
              subtitle: Text(
                '${pickup ?? 'N/A'} → ${drop ?? 'N/A'}\n₹${fare ?? '—'}',
                style: theme.bodySmall.override(font: GoogleFonts.inter()),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Chip(
                label: Text(
                  (rideStatus).toUpperCase(),
                  style: const TextStyle(fontSize: 10),
                ),
                backgroundColor: _statusColor(rideStatus.toLowerCase()).withOpacity(0.2),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              onTap: id != null
                  ? () => context.pushNamedAuth(
                        RideDetailsWidget.routeName,
                        context.mounted,
                        queryParameters: {'rideId': id.toString()},
                      )
                  : null,
            ),
          )
              .animate()
              .fadeIn(duration: 300.ms, delay: (index * 40).ms)
              .slideX(begin: 0.03, end: 0, duration: 300.ms, delay: (index * 40).ms, curve: Curves.easeOut);
        },
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'running': return Colors.blue;
      case 'completed': return Colors.green;
      case 'scheduled': return Colors.orange;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}
