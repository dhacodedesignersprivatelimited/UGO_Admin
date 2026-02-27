import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/admin_drawer.dart';
import '/index.dart'; // Assumes DriversWidget is exported here
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'driver_license_model.dart';
export 'driver_license_model.dart';

class DriverLicenseWidget extends StatefulWidget {
  const DriverLicenseWidget({
    super.key,
    required this.userId,
  });

  final int? userId;

  static String routeName = 'DriverLicense';
  static String routePath = '/driverLicense';

  @override
  State<DriverLicenseWidget> createState() => _DriverLicenseWidgetState();
}

class _DriverLicenseWidgetState extends State<DriverLicenseWidget> {
  late DriverLicenseModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DriverLicenseModel());

    // Fetch Driver Details On Load
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _fetchDriverData();
    });
  }

  Future<void> _fetchDriverData() async {
    setState(() => _isLoading = true);

    _model.getdriverid = await GetDriverByIdCall.call(
      id: widget.userId,
      token: currentAuthenticationToken,
    );

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // --- Helper to show full-screen image ---
  void _showImageDialog(BuildContext context, String title, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                      font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, color: FlutterFlowTheme.of(context).primaryText),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.6,
              color: Colors.black,
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 1.0,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/error_image.webp',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper for Document Cards ---
  Widget _buildDocumentCard(String title, String jsonPath, IconData icon, Color iconColor) {
    final rawPath = getJsonField(_model.getdriverid?.jsonBody ?? '', jsonPath)?.toString();
    final fullUrl = (rawPath != null && rawPath.isNotEmpty && rawPath != 'null')
        ? 'https://ugotaxi.icacorp.org$rawPath'
        : '';

    return Container(
      width: MediaQuery.of(context).size.width > 600 ? 350 : double.infinity,
      margin: const EdgeInsets.only(bottom: 16.0, right: 16.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6.0,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                      font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    fullUrl.isEmpty ? 'Not Uploaded' : 'Tap to verify',
                    style: FlutterFlowTheme.of(context).labelSmall.override(
                      font: GoogleFonts.inter(),
                      color: fullUrl.isEmpty ? Colors.red : FlutterFlowTheme.of(context).secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            if (fullUrl.isNotEmpty)
              FFButtonWidget(
                onPressed: () => _showImageDialog(context, title, fullUrl),
                text: 'View',
                options: FFButtonOptions(
                  height: 36.0,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                  textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                    color: FlutterFlowTheme.of(context).primary,
                  ),
                  elevation: 0.0,
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamedAuth(AllusersWidget.routeName, context.mounted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          drawer: buildAdminDrawer(context),
          appBar: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primary,
            automaticallyImplyLeading: true,
            leading: FlutterFlowIconButton(
              borderColor: Colors.transparent,
              borderRadius: 30.0,
              buttonSize: 60.0,
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24.0),
              onPressed: _handleBack,
            ),
            title: Text(
              'KYC Verification',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                color: Colors.white,
                fontSize: 20.0,
              ),
            ),
            centerTitle: true,
            elevation: 2.0,
          ),
          body: SafeArea(
            top: true,
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: FlutterFlowTheme.of(context).primary))
                : SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800.0),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Submitted Documents',
                          style: FlutterFlowTheme.of(context).headlineSmall.override(
                            font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Review the driver\'s uploaded identification and vehicle documents.',
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(),
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                        ),
                        const SizedBox(height: 24.0),

                        Wrap(
                          children: [
                            _buildDocumentCard('Driving License', r'''$.data.license_image''', Icons.badge_rounded, Colors.blue),
                            _buildDocumentCard('Profile Picture', r'''$.data.profile_image''', Icons.account_circle_rounded, Colors.purple),
                            _buildDocumentCard('Aadhar Card', r'''$.data.aadhaar_image''', Icons.contact_emergency_rounded, Colors.orange),
                            _buildDocumentCard('PAN Card', r'''$.data.pan_image''', Icons.credit_card_rounded, Colors.green),
                            _buildDocumentCard('Registration (RC)', r'''$.data.rc_image''', Icons.directions_car_rounded, Colors.teal),
                          ],
                        ),

                        const SizedBox(height: 32.0),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).secondaryBackground,
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Verification Decision',
                                style: FlutterFlowTheme.of(context).titleLarge.override(
                                  font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Once approved, the driver will be authorized to accept rides on the platform.',
                                style: FlutterFlowTheme.of(context).bodyMedium,
                              ),
                              const SizedBox(height: 24.0),
                              Row(
                                children: [
                                  Expanded(
                                    child: FFButtonWidget(
                                      onPressed: () async {
                                        _model.kycRejected = await VerifyDocsCall.call(
                                          driverId: widget.userId,
                                          verificationStatus: 'rejected',
                                          token: currentAuthenticationToken,
                                        );

                                        if ((_model.kycRejected?.succeeded ?? false)) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: const Text('Driver KYC Rejected'),
                                              backgroundColor: FlutterFlowTheme.of(context).error,
                                            ),
                                          );
                                          // After decision, navigate back to Drivers widget
                                          context.goNamedAuth(AllusersWidget.routeName, context.mounted);
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Failed: ${(_model.kycRejected?.jsonBody ?? '').toString()}'),
                                              backgroundColor: FlutterFlowTheme.of(context).primaryText,
                                            ),
                                          );
                                        }
                                        setState(() {});
                                      },
                                      text: 'Reject Docs',
                                      icon: const Icon(Icons.close_rounded, size: 18),
                                      options: FFButtonOptions(
                                        height: 50.0,
                                        color: FlutterFlowTheme.of(context).error.withOpacity(0.1),
                                        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                          font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                                          color: FlutterFlowTheme.of(context).error,
                                        ),
                                        elevation: 0.0,
                                        borderSide: BorderSide(color: FlutterFlowTheme.of(context).error, width: 1.5),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16.0),
                                  Expanded(
                                    child: FFButtonWidget(
                                      onPressed: () async {
                                        _model.apiResultmsc = await VerifyDocsCall.call(
                                          driverId: widget.userId,
                                          verificationStatus: 'approved',
                                          token: currentAuthenticationToken,
                                        );

                                        if ((_model.apiResultmsc?.succeeded ?? false)) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: const Text('Driver KYC Approved Successfully!'),
                                              backgroundColor: FlutterFlowTheme.of(context).success,
                                            ),
                                          );
                                          // After decision, navigate back to Drivers widget
                                          context.goNamedAuth(AllusersWidget.routeName, context.mounted);
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Failed: ${(_model.apiResultmsc?.jsonBody ?? '').toString()}'),
                                              backgroundColor: FlutterFlowTheme.of(context).error,
                                            ),
                                          );
                                        }
                                        setState(() {});
                                      },
                                      text: 'Approve KYC',
                                      icon: const Icon(Icons.check_rounded, size: 18),
                                      options: FFButtonOptions(
                                        height: 50.0,
                                        color: const Color(0xFF2E7D32),
                                        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                          font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                                          color: Colors.white,
                                        ),
                                        elevation: 2.0,
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}