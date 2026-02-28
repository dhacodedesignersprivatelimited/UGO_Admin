import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_config.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/admin_drawer.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'driver_details_model.dart';
export 'driver_details_model.dart';

class DriverDetailsWidget extends StatefulWidget {
  const DriverDetailsWidget({super.key, required this.driverId});

  final int? driverId;

  static String routeName = 'DriverDetails';
  static String routePath = '/driver-details';

  @override
  State<DriverDetailsWidget> createState() => _DriverDetailsWidgetState();
}

class _DriverDetailsWidgetState extends State<DriverDetailsWidget> {
  late DriverDetailsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = true;
  bool _isUpdatingStatus = false;
  Map<String, dynamic>? _driverData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DriverDetailsModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchDriver());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _fetchDriver() async {
    if (widget.driverId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid driver ID';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await GetDriverByIdCall.call(
        id: widget.driverId,
        token: currentAuthenticationToken,
      );
      if (!mounted) return;
      if (response.succeeded) {
        final data = GetDriverByIdCall.data(response.jsonBody);
        setState(() {
          _driverData = data != null ? Map<String, dynamic>.from(data) : null;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = getJsonField(response.jsonBody, r'''$.message''')
              ?.toString() ??
              'Failed to load driver';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _string(String path) =>
      getJsonField(_driverData ?? {}, path)?.toString() ?? '';

  bool _bool(String path, {bool fallback = false}) {
    final value = getJsonField(_driverData ?? {}, path);
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value != 0;
    return fallback;
  }

  String _formatDate(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return dateTimeFormat('yMMMd', parsed);
  }

  String _displayDate(String raw) {
    if (raw.isEmpty || raw == 'null') return '—';
    return _formatDate(raw);
  }

  String _safeUrl(String raw) {
    if (raw.isEmpty || raw == 'null') return '';
    if (raw.startsWith('http')) return raw;
    return '${ApiConfig.baseUrl}/${raw.replaceFirst(RegExp(r'^/'), '')}';
  }

  Future<void> _toggleOnline(bool nextValue) async {
    if (widget.driverId == null || _isUpdatingStatus) return;
    setState(() => _isUpdatingStatus = true);
    final response = await UpdateDriverCall.call(
      id: widget.driverId!,
      token: currentAuthenticationToken,
      isOnline: nextValue,
    );
    if (!mounted) return;
    setState(() => _isUpdatingStatus = false);
    if (response.succeeded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status updated!')),
      );
      await _fetchDriver();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update status')),
      );
    }
  }

  // --- UI Helpers ---

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha:0.3)),
      ),
      child: Text(
        text.toUpperCase(),
        style: FlutterFlowTheme.of(context).labelSmall.override(
          font: GoogleFonts.inter(fontWeight: FontWeight.bold),
          color: color,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildQuickStat(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha:0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha:0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha:0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value.isEmpty ? '0' : value,
              style: FlutterFlowTheme.of(context).headlineSmall.override(
                font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                color: FlutterFlowTheme.of(context).primaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).labelSmall.override(
                font: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primaryBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: FlutterFlowTheme.of(context).primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: FlutterFlowTheme.of(context).labelMedium.override(
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? '—' : value,
                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children, int delayMs) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: FlutterFlowTheme.of(context).titleLarge.override(
              font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 32, thickness: 1),
          ...children,
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: delayMs.ms).slideY(
        begin: 0.05, end: 0, duration: 400.ms, delay: delayMs.ms, curve: Curves.easeOut);
  }

  void _showImageDialog(String title, String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: FlutterFlowTheme.of(context).titleMedium.override(
                          font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.6,
                  color: Colors.black87,
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 1.0,
                    maxScale: 4.0,
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image,
                                color: FlutterFlowTheme.of(context).alternate, size: 64),
                            const SizedBox(height: 16),
                            Text("Image not available",
                                style: FlutterFlowTheme.of(context).bodyMedium.override(color: Colors.white70))
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocCard(String title, String rawPath) {
    final url = _safeUrl(rawPath);
    final hasUrl = url.isNotEmpty;
    return Container(
      width: MediaQuery.of(context).size.width > 600 ? 320 : double.infinity,
      margin: const EdgeInsets.only(bottom: 16, right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    FlutterFlowTheme.of(context).primary.withValues(alpha:0.8),
                    FlutterFlowTheme.of(context).primary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: FlutterFlowTheme.of(context).primary.withValues(alpha:0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
            ),
            child: const Icon(Icons.description_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                    font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasUrl ? 'Uploaded & Secured' : 'Not uploaded',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                    color: hasUrl
                        ? const Color(0xFF2E7D32) // Success green
                        : FlutterFlowTheme.of(context).error,
                    font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          if (hasUrl)
            FFButtonWidget(
              onPressed: () => _showImageDialog(title, url),
              text: 'View',
              options: FFButtonOptions(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: FlutterFlowTheme.of(context).primary.withValues(alpha:0.1),
                textStyle: FlutterFlowTheme.of(context).labelMedium.override(
                  color: FlutterFlowTheme.of(context).primary,
                  font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                elevation: 0,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photoRaw = _string(r'''$.profile_image''');
    final photoUrl = photoRaw.isNotEmpty && photoRaw != 'null'
        ? (photoRaw.startsWith('http')
        ? photoRaw
        : '${ApiConfig.baseUrl}/${photoRaw.replaceFirst(RegExp(r'^/'), '')}')
        : '';

    final name = '${_string(r'''$.first_name''')} ${_string(r'''$.last_name''')}'.trim();
    final phone = _string(r'''$.mobile_number''');
    final email = _string(r'''$.email''');
    final vehicle = _string(r'''$.adminVehicle.vehicle_name''');
    final vehicleNumber = _string(r'''$.vehicle_number''');
    final rating = _string(r'''$.driver_rating''');
    final totalRides = _string(r'''$.total_rides_completed''');
    final earnings = _string(r'''$.total_earnings''');
    final kycStatus = _string(r'''$.kyc_status''').toLowerCase();
    final isActive = _bool(r'''$.is_active''');
    final isOnline = _bool(r'''$.is_online''');

    // Determine colors
    final kycColor = kycStatus == 'approved' ? const Color(0xFF2E7D32) :
    kycStatus == 'pending' ? const Color(0xFFF57C00) : FlutterFlowTheme.of(context).error;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.goNamedAuth(AllusersWidget.routeName, context.mounted);
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        drawer: buildAdminDrawer(context),
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Driver Profile',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
              color: Colors.white,
              fontSize: 22,
            ),
          ),
          elevation: 0,
          centerTitle: true,
        ),
        body: _isLoading
            ? Center(
            child: CircularProgressIndicator(color: FlutterFlowTheme.of(context).primary)
        )
            : _errorMessage != null
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning_rounded, size: 64, color: FlutterFlowTheme.of(context).error),
                const SizedBox(height: 16),
                Text(_errorMessage!, textAlign: TextAlign.center, style: FlutterFlowTheme.of(context).titleMedium),
                const SizedBox(height: 24),
                FFButtonWidget(
                  onPressed: _fetchDriver,
                  text: 'Try Again',
                  options: FFButtonOptions(
                    height: 44,
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        )
            : RefreshIndicator(
          onRefresh: _fetchDriver,
          color: FlutterFlowTheme.of(context).primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HERO PROFILE SECTION
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                  child: Column(
                    children: [
                      Hero(
                        tag: 'driver_photo_${widget.driverId}',
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: FlutterFlowTheme.of(context).primary, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: FlutterFlowTheme.of(context).primary.withValues(alpha:0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                )
                              ]
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
                            backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                            child: photoUrl.isEmpty
                                ? Icon(Icons.person, size: 50, color: FlutterFlowTheme.of(context).secondaryText)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        name.isNotEmpty ? name : 'Unknown Driver',
                        style: FlutterFlowTheme.of(context).headlineMedium.override(
                          font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone_iphone_rounded, size: 16, color: FlutterFlowTheme.of(context).secondaryText),
                          const SizedBox(width: 4),
                          Text(phone.isNotEmpty ? phone : '—', style: FlutterFlowTheme.of(context).bodyMedium),
                          if (email.isNotEmpty) ...[
                            const SizedBox(width: 16),
                            Icon(Icons.email_rounded, size: 16, color: FlutterFlowTheme.of(context).secondaryText),
                            const SizedBox(width: 4),
                            Text(email, style: FlutterFlowTheme.of(context).bodyMedium),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatusBadge('KYC: $kycStatus', kycColor),
                          const SizedBox(width: 12),
                          _buildStatusBadge(isActive ? 'ACTIVE' : 'INACTIVE', isActive ? const Color(0xFF2E7D32) : FlutterFlowTheme.of(context).error),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Direct Actions inside Hero
                      if (kycStatus == 'pending')
                        FFButtonWidget(
                          onPressed: () => context.goNamedAuth(
                            KycPendingWidget.routeName,
                            context.mounted,
                            queryParameters: {'driverId': widget.driverId.toString()},
                          ),
                          text: 'Review Pending KYC',
                          icon: const Icon(Icons.fact_check_rounded, size: 20),
                          options: FFButtonOptions(
                            height: 48,
                            width: 250,
                            color: const Color(0xFFF57C00),
                            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                              color: Colors.white,
                              font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                            ),
                            borderRadius: BorderRadius.circular(24),
                            elevation: 3,
                          ),
                        ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 2000.ms, color: Colors.white24)
                      else if (kycStatus == 'approved')
                        Container(
                          width: 250,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primaryBackground,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('Online Status', style: FlutterFlowTheme.of(context).bodyLarge.override(font: GoogleFonts.inter(fontWeight: FontWeight.bold))),
                            activeColor: const Color(0xFF2E7D32),
                            value: isOnline,
                            onChanged: _isUpdatingStatus ? null : (val) => _toggleOnline(val),
                          ),
                        ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),

                // MAIN CONTENT PADDING
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // 2. QUICK STATS GRID
                      Row(
                        children: [
                          _buildQuickStat(Icons.star_rounded, 'Rating', rating.isNotEmpty ? rating : 'New', const Color(0xFFFBC02D)),
                          const SizedBox(width: 12),
                          _buildQuickStat(Icons.route_rounded, 'Total Rides', totalRides, FlutterFlowTheme.of(context).primary),
                          const SizedBox(width: 12),
                          _buildQuickStat(Icons.payments_rounded, 'Earnings', '₹$earnings', const Color(0xFF2E7D32)),
                        ],
                      ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 32),

                      // 3. STAGGERED SECTIONS
                      _buildSection('Vehicle Info', [
                        _buildInfoRow(Icons.directions_car_filled, 'Vehicle Assigned', vehicle),
                        _buildInfoRow(Icons.confirmation_number, 'Plate Number', vehicleNumber),
                        _buildInfoRow(Icons.category_rounded, 'Ride Category', _string(r'''$.adminVehicle.ride_category''')),
                        _buildInfoRow(Icons.work_rounded, 'Luggage Capacity', _string(r'''$.adminVehicle.luggage_capacity''')),
                      ], 200),

                      _buildSection('Personal & Location', [
                        _buildInfoRow(Icons.badge_rounded, 'License Number', _string(r'''$.license_number''')),
                        _buildInfoRow(Icons.home_rounded, 'Address', _string(r'''$.address''')),
                        _buildInfoRow(Icons.location_city_rounded, 'City & State', '${_string(r'''$.city''')}, ${_string(r'''$.state''')}'),
                        _buildInfoRow(Icons.my_location_rounded, 'Last Known Location', '${_string(r'''$.current_location_latitude''')}, ${_string(r'''$.current_location_longitude''')}'),
                      ], 300),

                      _buildSection('Banking Details', [
                        _buildInfoRow(Icons.account_balance, 'Account Number', _string(r'''$.bank_account_number''')),
                        _buildInfoRow(Icons.confirmation_num_rounded, 'IFSC Code', _string(r'''$.bank_ifsc_code''')),
                        _buildInfoRow(Icons.person, 'Account Holder', _string(r'''$.bank_holder_name''')),
                      ], 400),

                      // DOCUMENTS GRID
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Verified Documents',
                              style: FlutterFlowTheme.of(context).titleLarge.override(
                                font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Divider(height: 32, thickness: 1),
                            Wrap(
                              alignment: WrapAlignment.start,
                              children: [
                                _buildDocCard('License Front', _string(r'''$.license_front_image''')),
                                _buildDocCard('License Back', _string(r'''$.license_back_image''')),
                                _buildDocCard('Aadhaar Front', _string(r'''$.aadhaar_front_image''')),
                                _buildDocCard('Aadhaar Back', _string(r'''$.aadhaar_back_image''')),
                                _buildDocCard('PAN Card', _string(r'''$.pan_image''')),
                                _buildDocCard('Vehicle Image', _string(r'''$.vehicle_image''')),
                                _buildDocCard('RC Book Front', _string(r'''$.rc_front_image''')),
                                _buildDocCard('RC Book Back', _string(r'''$.rc_back_image''')),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideY(begin: 0.05, end: 0),
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