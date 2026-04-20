import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';
import '/shared/widgets/admin_drawer.dart';
import '/shared/widgets/admin_pop_scope.dart';
import '/index.dart'; // Assumes DriversWidget is exported here
import '/config/theme/flutter_flow_icon_button.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';
import '/config/theme/flutter_flow_widgets.dart';
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
  bool _isUpdating = false;

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

  dynamic _driverData() {
    return GetDriverByIdCall.data(_model.getdriverid?.jsonBody ?? '');
  }

  bool _driverBool(String jsonPath, {bool fallback = false}) {
    final value = getJsonField(_driverData() ?? {}, jsonPath);
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return fallback;
  }

  String _driverString(String jsonPath) {
    return getJsonField(_driverData() ?? {}, jsonPath)?.toString() ?? '';
  }

  int? _driverInt(String jsonPath) {
    final value = getJsonField(_driverData() ?? {}, jsonPath);
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  Future<void> _updateDriver({
    bool? isOnline,
    bool? isActive,
    String? firstName,
    String? lastName,
    String? email,
    String? mobileNumber,
    int? preferredCityId,
    String? accountStatus,
  }) async {
    if (widget.userId == null) return;
    setState(() => _isUpdating = true);
    final response = await UpdateDriverCall.call(
      id: widget.userId!,
      token: currentAuthenticationToken,
      isOnline: isOnline,
      isActive: isActive,
      firstName: firstName,
      lastName: lastName,
      email: email,
      mobileNumber: mobileNumber,
      preferredCityId: preferredCityId,
      accountStatus: accountStatus,
    );
    if (!mounted) return;
    setState(() => _isUpdating = false);
    if (response.succeeded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Driver updated successfully'),
          backgroundColor: FlutterFlowTheme.of(context).success,
        ),
      );
      await _fetchDriverData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Update failed (${response.statusCode})'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }

  Future<void> _openEditDriverDialog() async {
    final result = await showDialog<_DriverEditData>(
      context: context,
      builder: (ctx) => _EditDriverDialog(
        firstName: _driverString(r'''$.first_name'''),
        lastName: _driverString(r'''$.last_name'''),
        email: _driverString(r'''$.email'''),
        mobileNumber: _driverString(r'''$.mobile_number'''),
        preferredCityId: _driverInt(r'''$.preferred_city_id'''),
        accountStatus: _driverString(r'''$.account_status'''),
      ),
    );
    if (result == null) return;
    await _updateDriver(
      firstName: result.firstName,
      lastName: result.lastName,
      email: result.email,
      mobileNumber: result.mobileNumber,
      preferredCityId: result.preferredCityId,
      accountStatus: result.accountStatus,
    );
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
            color: Colors.black.withValues(alpha:0.03),
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
                color: iconColor.withValues(alpha:0.1),
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
                  color: FlutterFlowTheme.of(context).primary.withValues(alpha:0.1),
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
    return AdminPopScope(
      onCannotPop: _handleBack,
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
                          border:
                              Border.all(color: FlutterFlowTheme.of(context).alternate),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha:0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Driver Status',
                                  style: FlutterFlowTheme.of(context)
                                      .titleLarge
                                      .override(
                                        font: GoogleFonts.interTight(
                                            fontWeight: FontWeight.bold),
                                      ),
                                ),
                                FFButtonWidget(
                                  onPressed:
                                      _isUpdating ? null : _openEditDriverDialog,
                                  text: 'Edit Details',
                                  options: FFButtonOptions(
                                    height: 36,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14),
                                    color: FlutterFlowTheme.of(context).primary,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          color: Colors.white,
                                          font: GoogleFonts.inter(),
                                          fontWeight: FontWeight.w600,
                                        ),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Update active and online status for this driver.',
                              style: FlutterFlowTheme.of(context).bodyMedium,
                            ),
                            const SizedBox(height: 16.0),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Active'),
                              subtitle: Text(
                                _driverBool(r'''$.is_active''')
                                    ? 'Driver is active'
                                    : 'Driver is inactive',
                                style: FlutterFlowTheme.of(context)
                                    .bodySmall
                                    .override(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                              ),
                              value: _driverBool(r'''$.is_active'''),
                              onChanged: _isUpdating
                                  ? null
                                  : (val) => _updateDriver(isActive: val),
                            ),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Online'),
                              subtitle: Text(
                                _driverBool(r'''$.is_online''')
                                    ? 'Driver is online'
                                    : 'Driver is offline',
                                style: FlutterFlowTheme.of(context)
                                    .bodySmall
                                    .override(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                              ),
                              value: _driverBool(r'''$.is_online'''),
                              onChanged: _isUpdating
                                  ? null
                                  : (val) => _updateDriver(isOnline: val),
                            ),
                          ],
                        ),
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
                                color: Colors.black.withValues(alpha:0.04),
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
                                        color: FlutterFlowTheme.of(context).error.withValues(alpha:0.1),
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
                        if (_driverString(r'''$.kyc_status''').toLowerCase() ==
                            'pending') ...[
                          const SizedBox(height: 20.0),
                          FFButtonWidget(
                            onPressed: () => context.goNamedAuth(
                                DriverKycListWidget.routeName, context.mounted),
                            text: 'Go to Driver KYC List',
                            options: FFButtonOptions(
                              height: 48.0,
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    color: Colors.white,
                                    font: GoogleFonts.interTight(
                                        fontWeight: FontWeight.bold),
                                  ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ],
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

class _DriverEditData {
  _DriverEditData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobileNumber,
    required this.preferredCityId,
    required this.accountStatus,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String mobileNumber;
  final int? preferredCityId;
  final String accountStatus;
}

class _EditDriverDialog extends StatefulWidget {
  const _EditDriverDialog({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobileNumber,
    required this.preferredCityId,
    required this.accountStatus,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String mobileNumber;
  final int? preferredCityId;
  final String accountStatus;

  @override
  State<_EditDriverDialog> createState() => _EditDriverDialogState();
}

class _EditDriverDialogState extends State<_EditDriverDialog> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _preferredCityController;
  late TextEditingController _accountStatusController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.firstName);
    _lastNameController = TextEditingController(text: widget.lastName);
    _emailController = TextEditingController(text: widget.email);
    _mobileController = TextEditingController(text: widget.mobileNumber);
    _preferredCityController = TextEditingController(
        text: widget.preferredCityId?.toString() ?? '');
    _accountStatusController = TextEditingController(text: widget.accountStatus);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _preferredCityController.dispose();
    _accountStatusController.dispose();
    super.dispose();
  }

  void _submit() {
    final preferredCityId =
        int.tryParse(_preferredCityController.text.trim());
    Navigator.pop(
      context,
      _DriverEditData(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        mobileNumber: _mobileController.text.trim(),
        preferredCityId: preferredCityId,
        accountStatus: _accountStatusController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Driver Details'),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _mobileController,
                decoration: const InputDecoration(labelText: 'Mobile Number'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _preferredCityController,
                decoration: const InputDecoration(labelText: 'Preferred City ID'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _accountStatusController,
                decoration: const InputDecoration(labelText: 'Account Status'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: FlutterFlowTheme.of(context).primary,
            foregroundColor: Colors.white,
            textStyle: FlutterFlowTheme.of(context).labelMedium.override(
                  color: Colors.white,
                  font: GoogleFonts.inter(),
                  fontWeight: FontWeight.w600,
                ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}