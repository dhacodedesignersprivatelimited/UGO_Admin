import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_config.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/admin_drawer.dart';
import '/components/responsive_body.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ride_details_model.dart';
export 'ride_details_model.dart';

class RideDetailsWidget extends StatefulWidget {
  const RideDetailsWidget({super.key, required this.rideId});

  final int? rideId;

  static String routeName = 'RideDetails';
  static String routePath = '/ride-details';

  @override
  State<RideDetailsWidget> createState() => _RideDetailsWidgetState();
}

class _RideDetailsWidgetState extends State<RideDetailsWidget> {
  late RideDetailsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  dynamic _rideData;
  dynamic _userData;
  dynamic _driverData;
  String? _errorMessage;

  static const _riderGradient = [Color(0xFF1565C0), Color(0xFF42A5F5)];
  static const _driverGradient = [Color(0xFF2E7D32), Color(0xFF66BB6A)];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RideDetailsModel());
    SchedulerBinding.instance.addPostFrameCallback((_) => _fetchAllDetails());
  }

  Future<void> _fetchAllDetails() async {
    if (widget.rideId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid ride ID';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _userData = null;
      _driverData = null;
    });
    try {
      final rideResponse = await GetRideByIdCall.call(
        token: currentAuthenticationToken,
        rideId: widget.rideId!,
      );
      if (!mounted) return;
      if (!rideResponse.succeeded) {
        setState(() {
          _errorMessage = getJsonField(rideResponse.jsonBody, r'''$.message''')
                  ?.toString() ??
              'Failed to load ride details';
          _isLoading = false;
        });
        return;
      }

      _rideData = GetRideByIdCall.data(rideResponse.jsonBody);
      final riderId = castToType<int>(getJsonField(_rideData, r'''$.rider_id''') ??
          getJsonField(_rideData, r'''$.user_id'''));
      final driverId = castToType<int>(getJsonField(_rideData, r'''$.driver_id'''));

      dynamic userData;
      dynamic driverData;

      final futures = <Future<void>>[];
      if (riderId != null) {
        futures.add(GetUserByIdCall.call(id: riderId, token: currentAuthenticationToken)
            .then((r) => userData = r.succeeded ? GetUserByIdCall.data(r.jsonBody) : null));
      }
      if (driverId != null) {
        futures.add(GetDriverByIdCall.call(id: driverId, token: currentAuthenticationToken)
            .then((r) => driverData = r.succeeded ? GetDriverByIdCall.data(r.jsonBody) : null));
      }
      await Future.wait(futures);

      if (mounted) {
        setState(() {
          _userData = userData;
          _driverData = driverData;
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

  String _getField(dynamic data, String path) {
    if (data == null) return '—';
    final v = getJsonField(data, path);
    return v?.toString().trim() ?? '—';
  }

  String _fareValue() {
    final f = _getField(_rideData, r'''$.final_fare''');
    final e = _getField(_rideData, r'''$.estimated_fare''');
    if (f != '—' && f.isNotEmpty) return f;
    if (e != '—') return e;
    return '—';
  }

  String _userName(dynamic data) {
    if (data == null) return '—';
    final first = getJsonField(data, r'''$.first_name''')?.toString() ?? '';
    final last = getJsonField(data, r'''$.last_name''')?.toString() ?? '';
    final name = getJsonField(data, r'''$.name''')?.toString();
    if (name != null && name.isNotEmpty) return name;
    return '${first} ${last}'.trim().isEmpty ? '—' : '${first} ${last}'.trim();
  }

  String _imageUrl(String? path) {
    if (path == null || path.isEmpty || path == 'null') return '';
    if (path.startsWith('http')) return path;
    final p = path.startsWith('/') ? path.substring(1) : path;
    return '${ApiConfig.baseUrl}/$p';
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamedAuth(RideManagementWidget.routeName, context.mounted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
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
            onPressed: _handleBack,
          ),
          title: Text(
            'Ride Details',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                  color: Colors.white,
                  fontSize: 20,
                ),
          ),
          elevation: 2,
        ),
        body: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: FlutterFlowTheme.of(context).primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading ride details...',
                      style: FlutterFlowTheme.of(context).bodyMedium,
                    ),
                  ],
                ),
              )
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: FlutterFlowTheme.of(context).error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context).bodyLarge,
                          ),
                          const SizedBox(height: 24),
                          FFButtonWidget(
                            onPressed: _fetchAllDetails,
                            text: 'Retry',
                            options: FFButtonOptions(
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: ResponsiveContainer(
                      maxWidth: 700,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader().animate().fadeIn(duration: 350.ms).slideY(begin: -0.05, end: 0, curve: Curves.easeOutCubic),
                          _buildTripInfoCard().animate().fadeIn(duration: 350.ms, delay: 80.ms).slideY(begin: 0.06, end: 0, delay: 80.ms, curve: Curves.easeOutCubic),
                          _buildRiderCard().animate().fadeIn(duration: 350.ms, delay: 160.ms).slideX(begin: 0.04, end: 0, delay: 160.ms, curve: Curves.easeOutCubic),
                          _buildDriverCard().animate().fadeIn(duration: 350.ms, delay: 240.ms).slideX(begin: 0.04, end: 0, delay: 240.ms, curve: Curves.easeOutCubic),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildHeader() {
    final status = _getField(_rideData, r'''$.ride_status''').toUpperCase().replaceAll('—', 'N/A');
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FlutterFlowTheme.of(context).primary,
            FlutterFlowTheme.of(context).secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: FlutterFlowTheme.of(context).primary.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.local_taxi_rounded, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'RIDE-${widget.rideId ?? ''}',
            style: GoogleFonts.interTight(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              status,
              style: GoogleFonts.interTight(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripInfoCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.route, color: FlutterFlowTheme.of(context).primary, size: 24),
              const SizedBox(width: 10),
              Text(
                'Trip Info',
                style: FlutterFlowTheme.of(context).titleLarge.override(
                      font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                      color: FlutterFlowTheme.of(context).primaryText,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _infoRow(Icons.trip_origin, 'Pickup', _getField(_rideData, r'''$.pickup_location_address''')),
          _infoRow(Icons.location_on, 'Drop', _getField(_rideData, r'''$.drop_location_address''')),
          _infoRow(Icons.currency_rupee, 'Fare', '₹${_fareValue()}'),
          _infoRow(Icons.calendar_today, 'Created', _getField(_rideData, r'''$.created_at''')),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: FlutterFlowTheme.of(context).primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: FlutterFlowTheme.of(context).labelMedium.override(
                        color: FlutterFlowTheme.of(context).secondaryText,
                        fontSize: 12,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiderCard() {
    final riderId = castToType<int>(
        getJsonField(_rideData, r'''$.rider_id''') ?? getJsonField(_rideData, r'''$.user_id'''));
    final name = _userData != null ? _userName(_userData) : 'Rider #${riderId ?? '—'}';
    final phone = _getField(_userData ?? _rideData, r'''$.mobile_number''');
    final email = _getField(_userData, r'''$.email''');
    final imgPath = _userData != null ? getJsonField(_userData, r'''$.profile_image''')?.toString() : null;
    final imgUrl = _imageUrl(imgPath);

    return _buildPersonCard(
      title: 'Rider',
      gradient: _riderGradient,
      icon: Icons.person_rounded,
      name: name,
      subtitle: phone != '—' ? phone : (email != '—' ? email : null),
      avatarUrl: imgUrl.isNotEmpty ? imgUrl : null,
      onTap: riderId != null
          ? () => context.pushNamedAuth(
                UserDetailsWidget.routeName,
                context.mounted,
                queryParameters: {'userId': riderId.toString()},
              )
          : null,
    );
  }

  Widget _buildDriverCard() {
    final driverId = castToType<int>(getJsonField(_rideData, r'''$.driver_id'''));
    final name = _driverData != null
        ? _userName(_driverData)
        : 'Driver #${driverId ?? '—'}';
    String phone = _getField(_rideData, r'''$.driver_phone''');
    if (phone == '—' && _driverData != null) {
      phone = _getField(_driverData, r'''$.phone''');
      if (phone == '—') phone = _getField(_driverData, r'''$.mobile_number''');
    }
    final imgPath = _driverData != null ? getJsonField(_driverData, r'''$.profile_image''')?.toString() : null;
    final imgUrl = _imageUrl(imgPath);

    return _buildPersonCard(
      title: 'Driver',
      gradient: _driverGradient,
      icon: Icons.drive_eta_rounded,
      name: name,
      subtitle: phone != '—' ? phone : null,
      avatarUrl: imgUrl.isNotEmpty ? imgUrl : null,
      onTap: driverId != null
          ? () => context.pushNamedAuth(
                DriverLicenseWidget.routeName,
                context.mounted,
                queryParameters: {'userId': driverId.toString()},
              )
          : null,
    );
  }

  Widget _buildPersonCard({
    required String title,
    required List<Color> gradient,
    required IconData icon,
    required String name,
    String? subtitle,
    String? avatarUrl,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: gradient.last.withOpacity(0.4),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  backgroundImage: avatarUrl != null
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: avatarUrl == null
                      ? Icon(icon, size: 36, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        name,
                        style: GoogleFonts.interTight(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
