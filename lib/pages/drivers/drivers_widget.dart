import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/api_requests/api_config.dart';
import '/components/admin_drawer.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart'; // Assumes DashboardPageWidget and DriverLicenseWidget are exported here
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'drivers_model.dart';
export 'drivers_model.dart';

class DriversWidget extends StatefulWidget {
  const DriversWidget({super.key});

  static String routeName = 'drivers';
  static String routePath = '/drivers';

  @override
  State<DriversWidget> createState() => _DriversWidgetState();
}

class _DriversWidgetState extends State<DriversWidget> {
  late DriversModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Store the future so it doesn't refetch every time you switch tabs
  late Future<ApiCallResponse> _driversFuture;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DriversModel());

    // Fetch once on init
    _driversFuture = GetDriversCall.call(token: currentAuthenticationToken);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _safeUrl(String? raw) {
    if (raw == null || raw.isEmpty || raw == 'null') return '';
    if (raw.startsWith('http')) return raw;
    return '${ApiConfig.baseUrl}/${raw.replaceFirst(RegExp(r'^/'), '')}';
  }

  bool _boolValue(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value != 0;
    return false;
  }

  Future<void> _openEditDriverDialog(Map<String, dynamic> data) async {
    final firstNameController =
        TextEditingController(text: data['first_name']?.toString() ?? '');
    final lastNameController =
        TextEditingController(text: data['last_name']?.toString() ?? '');
    final emailController =
        TextEditingController(text: data['email']?.toString() ?? '');
    final mobileController =
        TextEditingController(text: data['mobile_number']?.toString() ?? '');
    final preferredCityController = TextEditingController(
        text: data['preferred_city_id']?.toString() ?? '');
    final accountStatusController =
        TextEditingController(text: data['account_status']?.toString() ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Driver'),
        content: SizedBox(
          width: 360,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: mobileController,
                  decoration: const InputDecoration(labelText: 'Mobile Number'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: preferredCityController,
                  decoration: const InputDecoration(labelText: 'Preferred City ID'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: accountStatusController,
                  decoration: const InputDecoration(labelText: 'Account Status'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != true) return;

    final preferredCityId =
        int.tryParse(preferredCityController.text.trim());
    setState(() => _isUpdating = true);
    final response = await UpdateDriverCall.call(
      id: data['id'] as int,
      token: currentAuthenticationToken,
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      email: emailController.text.trim(),
      mobileNumber: mobileController.text.trim(),
      preferredCityId: preferredCityId,
      accountStatus: accountStatusController.text.trim(),
      isOnline: _boolValue(data['is_online']),
      isActive: _boolValue(data['is_active']),
    );
    if (!mounted) return;
    setState(() => _isUpdating = false);
    if (response.succeeded) {
      showSnackbar(context, 'Driver updated successfully');
    } else {
      showSnackbar(context, 'Failed to update driver');
    }
  }

  Future<void> _openDriverDetails(int driverId) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: FutureBuilder<ApiCallResponse>(
            future:
                GetDriverByIdCall.call(id: driverId, token: currentAuthenticationToken),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                          color: FlutterFlowTheme.of(context).primary),
                      const SizedBox(height: 16),
                      Text('Loading driver details...',
                          style: FlutterFlowTheme.of(context).bodyMedium),
                    ],
                  ),
                );
              }

              final response = snapshot.data!;
              if (!response.succeeded) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: FlutterFlowTheme.of(context).error),
                      const SizedBox(height: 16),
                      Text('Failed to load driver details',
                          style: FlutterFlowTheme.of(context).bodyLarge),
                    ],
                  ),
                );
              }

              final data =
                  Map<String, dynamic>.from(GetDriverByIdCall.data(response.jsonBody) ?? {});
              final name =
                  '${data['first_name'] ?? ''} ${data['last_name'] ?? ''}'.trim();
              final photoUrl = _safeUrl(data['profile_image']?.toString());
              final kycStatus =
                  (data['kyc_status']?.toString() ?? 'pending').toLowerCase();
              final isActive = _boolValue(data['is_active']);

              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).alternate,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor:
                              FlutterFlowTheme.of(context).primary.withValues(alpha:0.1),
                          backgroundImage:
                              photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                          child: photoUrl.isEmpty
                              ? Icon(Icons.person,
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 32)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name.isNotEmpty ? name : 'Driver',
                                style: FlutterFlowTheme.of(context)
                                    .titleLarge
                                    .override(
                                      font: GoogleFonts.interTight(
                                          fontWeight: FontWeight.bold),
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data['mobile_number']?.toString() ?? '—',
                                style: FlutterFlowTheme.of(context).bodyMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                data['email']?.toString() ?? '—',
                                style: FlutterFlowTheme.of(context)
                                    .bodySmall
                                    .override(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: _isUpdating
                              ? null
                              : () => _openEditDriverDialog(data),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: FlutterFlowTheme.of(context).alternate),
                    const SizedBox(height: 8),
                    _detailRow('KYC Status', kycStatus.toUpperCase()),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Active Driver'),
                      subtitle: Text(
                        isActive ? 'Driver is active' : 'Driver is inactive',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              color:
                                  FlutterFlowTheme.of(context).secondaryText,
                            ),
                      ),
                      value: isActive,
                      onChanged: _isUpdating
                          ? null
                          : (val) async {
                              setState(() => _isUpdating = true);
                              final response = await UpdateDriverCall.call(
                                id: data['id'] as int,
                                token: currentAuthenticationToken,
                                isActive: val,
                                isOnline: _boolValue(data['is_online']),
                              );
                              if (mounted) {
                                setState(() => _isUpdating = false);
                                if (response.succeeded) {
                                  showSnackbar(
                                      context, 'Active status updated');
                                } else {
                                  showSnackbar(
                                      context, 'Failed to update status');
                                }
                              }
                            },
                    ),
                    _detailRow('Is Online',
                        _boolValue(data['is_online']) ? 'Yes' : 'No'),
                    _detailRow('Account Status',
                        data['account_status']?.toString() ?? '—'),
                    _detailRow('Preferred City ID',
                        data['preferred_city_id']?.toString() ?? '—'),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
            ),
          ),
          Text(
            value.isEmpty ? '—' : value,
            style: FlutterFlowTheme.of(context).bodyMedium,
          ),
        ],
      ),
    );
  }

  // --- Helper to build the filtered list ---
  Widget _buildDriverList(List<dynamic> drivers, String emptyMessage) {
    if (drivers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.drive_eta_rounded, size: 64, color: FlutterFlowTheme.of(context).alternate),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800.0), // Responsive Constraint
        child: ListView.builder(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 40),
          itemCount: drivers.length,
          itemBuilder: (context, index) {
            final d = drivers[index];
            final firstName = getJsonField(d, r'''$.first_name''')?.toString() ?? '';
            final lastName = getJsonField(d, r'''$.last_name''')?.toString() ?? '';
            final name = '$firstName $lastName'.trim().isNotEmpty ? '$firstName $lastName'.trim() : 'Driver ${index + 1}';

            final vehicle = getJsonField(d, r'''$.vehicle_type''')?.toString() ??
                getJsonField(d, r'''$.vehicles[0].vehicle_model''')?.toString() ?? '—';

            final img = getJsonField(d, r'''$.profile_image''')?.toString();
            final driverId = castToType<int>(getJsonField(d, r'''$.id'''));

            final statusStr = (getJsonField(d, r'''$.kyc_status''')?.toString() ??
                    getJsonField(d, r'''$.verification_status''')?.toString() ??
                    'pending')
                .toLowerCase();

            // Define Badge Colors based on status
            Color badgeColor;
            Color badgeTextColor;
            if (statusStr == 'approved') {
              badgeColor = const Color(0xFFE8F5E9); // Light Green
              badgeTextColor = const Color(0xFF2E7D32); // Dark Green
            } else if (statusStr == 'rejected') {
              badgeColor = const Color(0xFFFFEBEE); // Light Red
              badgeTextColor = const Color(0xFFC62828); // Dark Red
            } else {
              badgeColor = const Color(0xFFFFF3E0); // Light Orange
              badgeTextColor = const Color(0xFFEF6C00); // Dark Orange
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      if (driverId == null) return;
                      _openDriverDetails(driverId);
                    },
                              child: Padding(
                      padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                            width: 60,
                            height: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                              border: Border.all(color: FlutterFlowTheme.of(context).primary.withValues(alpha:0.3), width: 2),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: (img != null && img.isNotEmpty && img != 'null')
                                  ? Image.network(
                                img.startsWith('http')
                                    ? img
                                    : '${ApiConfig.baseUrl}/${img.replaceFirst(RegExp(r'^/'), '')}',
                                        fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Icon(Icons.person, color: FlutterFlowTheme.of(context).primary, size: 30),
                              )
                                  : Icon(Icons.person, color: FlutterFlowTheme.of(context).primary, size: 30),
                            ),
                          ),
                          const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                  name,
                                  style: FlutterFlowTheme.of(context).titleMedium.override(
                                    font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.directions_car_rounded, size: 14, color: FlutterFlowTheme.of(context).secondaryText),
                                    const SizedBox(width: 4),
                                    Text(
                                      vehicle,
                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                        font: GoogleFonts.inter(),
                                        color: FlutterFlowTheme.of(context).secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                  color: badgeColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  statusStr.toUpperCase(),
                                  style: FlutterFlowTheme.of(context).labelSmall.override(
                                    font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                                    color: badgeTextColor,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Icon(Icons.chevron_right_rounded, color: FlutterFlowTheme.of(context).primary),
                            ],
                          ),
                        ],
                      ),
                    ),
                                ),
                              ),
                            ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          context.goNamedAuth(DashboardPageWidget.routeName, context.mounted);
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        // Wrap with DefaultTabController to enable tabs
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            drawer: buildAdminDrawer(context),
            appBar: AppBar(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              automaticallyImplyLeading: true,
              foregroundColor: Colors.white,
              title: Text(
                'Driver Management',
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                  color: Colors.white,
                  fontSize: 22.0,
                ),
              ),
              centerTitle: true,
              elevation: 0.0,
              // Add the TabBar to the AppBar
              bottom: const TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                indicatorWeight: 3.0,
                tabs: [
                  Tab(text: 'PENDING'),
                  Tab(text: 'APPROVED'),
                  Tab(text: 'REJECTED'),
                ],
              ),
            ),
            body: SafeArea(
              top: true,
              child: FutureBuilder<ApiCallResponse>(
                future: _driversFuture, // Using the stored future
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          FlutterFlowTheme.of(context).primary,
                        ),
                      ),
                    );
                  }

                  final response = snapshot.data!;
                  if (!response.succeeded) {
                    return Center(
                      child: Text(
                        'Failed to load drivers.',
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                          font: GoogleFonts.inter(color: FlutterFlowTheme.of(context).error),
                        ),
                      ),
                    );
                  }

                  final allDrivers = GetDriversCall.data(response.jsonBody)?.toList() ?? [];

                  // Filter the drivers based on their verification status
                  // (Defaults to 'pending' if the API field is null/missing)
                  final pendingDrivers = allDrivers.where((d) {
                    final status = (getJsonField(d, r'''$.verification_status''')?.toString() ?? 'pending').toLowerCase();
                    return status == 'pending';
                  }).toList();

                  final approvedDrivers = allDrivers.where((d) {
                    final status = (getJsonField(d, r'''$.verification_status''')?.toString() ?? 'pending').toLowerCase();
                    return status == 'approved';
                  }).toList();

                  final rejectedDrivers = allDrivers.where((d) {
                    final status = (getJsonField(d, r'''$.verification_status''')?.toString() ?? 'pending').toLowerCase();
                    return status == 'rejected';
                  }).toList();

                  // TabBarView must match the length of DefaultTabController
                  return TabBarView(
                    children: [
                      _buildDriverList(pendingDrivers, 'No pending KYC requests.'),
                      _buildDriverList(approvedDrivers, 'No approved drivers found.'),
                      _buildDriverList(rejectedDrivers, 'No rejected drivers found.'),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}