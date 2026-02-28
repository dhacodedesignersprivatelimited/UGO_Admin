import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/components/admin_drawer.dart';
import '/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_driver_model.dart';
export 'add_driver_model.dart';

class AddDriverWidget extends StatefulWidget {
  const AddDriverWidget({super.key});

  static String routeName = 'AddDriver';
  static String routePath = '/add-driver';

  @override
  State<AddDriverWidget> createState() => _AddDriverWidgetState();
}

class _AddDriverWidgetState extends State<AddDriverWidget> {
  late AddDriverModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddDriverModel());
    _model.mobileNumberTextController ??= TextEditingController();
    _model.mobileNumberFocusNode ??= FocusNode();
    _model.firstNameTextController ??= TextEditingController();
    _model.firstNameFocusNode ??= FocusNode();
    _model.lastNameTextController ??= TextEditingController();
    _model.lastNameFocusNode ??= FocusNode();
    _model.emailTextController ??= TextEditingController();
    _model.emailFocusNode ??= FocusNode();
    _model.fcmTokenTextController ??= TextEditingController();
    _model.fcmTokenFocusNode ??= FocusNode();
    _model.cityTextController ??= TextEditingController();
    _model.cityFocusNode ??= FocusNode();
    _model.stateTextController ??= TextEditingController();
    _model.stateFocusNode ??= FocusNode();
    _model.postalCodeTextController ??= TextEditingController();
    _model.postalCodeFocusNode ??= FocusNode();
    _model.referralCodeTextController ??= TextEditingController();
    _model.referralCodeFocusNode ??= FocusNode();
    _loadVehicleTypes();
  }

  Future<void> _loadVehicleTypes() async {
    safeSetState(() => _model.isLoadingVehicleTypes = true);
    try {
      final response = await GetVehicleTypesCall.call(
        token: currentAuthenticationToken,
      );
      if (mounted && response.succeeded) {
        dynamic raw = response.jsonBody;
        if (raw is Map) raw = getJsonField(raw, r'''$.data''');
        if (raw == null && response.jsonBody is Map) {
          raw = getJsonField(response.jsonBody, r'''$.vehicle_types''') ??
              getJsonField(response.jsonBody, r'''$.vehicleTypes''');
        }
        List<Map<String, dynamic>> list = [];
        if (raw is List) {
          for (final item in raw) {
            if (item is Map) list.add(Map<String, dynamic>.from(item));
          }
        }
        safeSetState(() {
          _model.vehicleTypesList = list;
          _model.isLoadingVehicleTypes = false;
        });
      } else {
        safeSetState(() => _model.isLoadingVehicleTypes = false);
      }
    } catch (_) {
      if (mounted) safeSetState(() => _model.isLoadingVehicleTypes = false);
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _pickDocumentImage(void Function(FFUploadedFile) onPicked) async {
    final selectedMedia = await selectMediaWithSourceBottomSheet(
      context: context,
      allowPhoto: true,
    );
    if (selectedMedia != null &&
        selectedMedia.every((m) => validateFileFormat(m.storagePath, context))) {
      safeSetState(() => _model.isUploadingDoc = true);
      try {
        final files = selectedMedia
            .map((m) => FFUploadedFile(
                  name: m.storagePath.split('/').last,
                  bytes: m.bytes,
                  height: m.dimensions?.height,
                  width: m.dimensions?.width,
                  blurHash: m.blurHash,
                  originalFilename: m.originalFilename,
                ))
            .toList();
        if (files.isNotEmpty) {
          onPicked(files.first);
          safeSetState(() {});
        }
      } finally {
        safeSetState(() => _model.isUploadingDoc = false);
      }
    }
  }

  FFUploadedFile? _fileOrNull(FFUploadedFile f) =>
      (f.bytes?.isNotEmpty ?? false) ? f : null;

  Future<void> _submit() async {
    final mobile = _model.mobileNumberTextController!.text.trim();
    final firstName = _model.firstNameTextController!.text.trim();
    final lastName = _model.lastNameTextController!.text.trim();
    final email = _model.emailTextController!.text.trim();
    final fcmToken = _model.fcmTokenTextController!.text.trim();
    final city = _model.cityTextController!.text.trim();
    final state = _model.stateTextController!.text.trim();
    final postalCode = _model.postalCodeTextController!.text.trim();
    final referralCode = _model.referralCodeTextController!.text.trim();

    if (mobile.isEmpty || firstName.isEmpty || lastName.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill mobile, first name, last name, and email')),
      );
      return;
    }

    if (_model.selectedVehicleTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vehicle type')),
      );
      return;
    }

    final driver = <String, dynamic>{
      'mobile_number': mobile,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      if (city.isNotEmpty) 'city': city,
      if (state.isNotEmpty) 'state': state,
      if (postalCode.isNotEmpty) 'postal_code': postalCode,
      if (referralCode.isNotEmpty) 'used_referral_code': referralCode,
    };
    final vehicle = <String, dynamic>{
      'vehicle_type_id': _model.selectedVehicleTypeId!,
    };

    safeSetState(() => _isSubmitting = true);
    try {
      final response = await CreateDriverCall.call(
        token: currentAuthenticationToken,
        driver: driver,
        vehicle: vehicle,
        fcmToken: fcmToken.isEmpty ? 'admin_created' : fcmToken,
        profileImage: _fileOrNull(_model.profileImage),
        licenseFrontImage: _fileOrNull(_model.licenseFrontImage),
        licenseBackImage: _fileOrNull(_model.licenseBackImage),
        aadhaarFrontImage: _fileOrNull(_model.aadhaarFrontImage),
        aadhaarBackImage: _fileOrNull(_model.aadhaarBackImage),
        panImage: _fileOrNull(_model.panImage),
        rcFrontImage: _fileOrNull(_model.rcFrontImage),
        rcBackImage: _fileOrNull(_model.rcBackImage),
        vehicleImage: _fileOrNull(_model.vehicleImage),
        registrationImage: _fileOrNull(_model.registrationImage),
        insuranceImage: _fileOrNull(_model.insuranceImage),
        pollutionCertificateImage: _fileOrNull(_model.pollutionCertificateImage),
      );

      if (!mounted) return;
      if (response.succeeded) {
        final data = CreateDriverCall.data(response.jsonBody);
        final driverObj = data != null ? getJsonField(data, r'''$.driver''') : null;
        final driverId = getJsonField(driverObj, r'''$.id''');
        final refCode = getJsonField(driverObj, r'''$.referral_code''')?.toString();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Driver created! ID: $driverId${refCode != null ? ' | Ref: $refCode' : ''}',
              ),
              backgroundColor: const Color(0xFF2E7D32),
            ),
          );
          context.goNamedAuth(AllusersWidget.routeName, context.mounted);
        }
      } else {
        final msg = getJsonField(response.jsonBody, r'''$.message''')
                ?.toString() ??
            'Failed to create driver';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red.shade700),
        );
      }
    } finally {
      if (mounted) safeSetState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.goNamedAuth(AllusersWidget.routeName, context.mounted);
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
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
              onPressed: () =>
                  context.goNamedAuth(AllusersWidget.routeName, context.mounted),
            ),
            title: Text(
              'Create Driver',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                    color: Colors.white,
                    fontSize: 22,
                  ),
            ),
            elevation: 2,
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;
              final padding = EdgeInsets.symmetric(
                horizontal: isWide ? 32 : 16,
                vertical: isWide ? 24 : 16,
              );
              return SingleChildScrollView(
                padding: padding,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 700),
                    child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  controller: _model.mobileNumberTextController!,
                  focusNode: _model.mobileNumberFocusNode!,
                  label: 'Mobile Number *',
                  hint: 'e.g. 9107988035',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_rounded,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _model.firstNameTextController!,
                  focusNode: _model.firstNameFocusNode!,
                  label: 'First Name *',
                  hint: 'e.g. harideep',
                  prefixIcon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _model.lastNameTextController!,
                  focusNode: _model.lastNameFocusNode!,
                  label: 'Last Name *',
                  hint: 'e.g. yadav',
                  prefixIcon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _model.emailTextController!,
                  focusNode: _model.emailFocusNode!,
                  label: 'Email *',
                  hint: 'e.g. driver@example.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_rounded,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _model.fcmTokenTextController!,
                  focusNode: _model.fcmTokenFocusNode!,
                  label: 'FCM Token (optional)',
                  hint: 'Leave empty if unknown',
                  prefixIcon: Icons.token_rounded,
                ),
                const SizedBox(height: 20),
                _buildVehicleTypeDropdown(),
                const SizedBox(height: 20),
                Text(
                  'Address (optional)',
                  style: FlutterFlowTheme.of(context).titleSmall.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField(
                        controller: _model.cityTextController!,
                        focusNode: _model.cityFocusNode!,
                        label: 'City',
                        hint: 'e.g. Delhi',
                        prefixIcon: Icons.location_city_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _model.stateTextController!,
                        focusNode: _model.stateFocusNode!,
                        label: 'State',
                        hint: 'e.g. Delhi',
                        prefixIcon: Icons.map_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _model.postalCodeTextController!,
                  focusNode: _model.postalCodeFocusNode!,
                  label: 'Postal Code',
                  hint: 'e.g. 110001',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.pin_drop_rounded,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _model.referralCodeTextController!,
                  focusNode: _model.referralCodeFocusNode!,
                  label: 'Used Referral Code (optional)',
                  hint: 'Referral code from another driver',
                  prefixIcon: Icons.card_giftcard_rounded,
                ),
                const SizedBox(height: 28),
                _buildDocumentsSection(constraints.maxWidth),
                const SizedBox(height: 32),
                FFButtonWidget(
                  onPressed: _isSubmitting ? null : () => _submit(),
                  text: _isSubmitting ? 'Creating...' : 'Create Driver',
                  icon: _isSubmitting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.drive_eta_rounded, size: 22, color: Colors.white),
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 52,
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                          font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          color: Colors.white,
                        ),
                    elevation: 2,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentsSection(double maxWidth) {
    final theme = FlutterFlowTheme.of(context);
    final isNarrow = maxWidth < 400;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Documents (optional)',
          style: theme.titleMedium.override(
            font: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Upload license, Aadhaar, PAN, RC & vehicle documents',
          style: theme.bodySmall.override(
            font: GoogleFonts.inter(),
            color: theme.secondaryText,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: isNarrow ? 8 : 12,
          runSpacing: isNarrow ? 8 : 12,
          children: [
            _buildDocTile('Profile', _model.profileImage, (f) => _model.profileImage = f, isNarrow),
            _buildDocTile('License Front', _model.licenseFrontImage, (f) => _model.licenseFrontImage = f, isNarrow),
            _buildDocTile('License Back', _model.licenseBackImage, (f) => _model.licenseBackImage = f, isNarrow),
            _buildDocTile('Aadhaar Front', _model.aadhaarFrontImage, (f) => _model.aadhaarFrontImage = f, isNarrow),
            _buildDocTile('Aadhaar Back', _model.aadhaarBackImage, (f) => _model.aadhaarBackImage = f, isNarrow),
            _buildDocTile('PAN', _model.panImage, (f) => _model.panImage = f, isNarrow),
            _buildDocTile('RC Front', _model.rcFrontImage, (f) => _model.rcFrontImage = f, isNarrow),
            _buildDocTile('RC Back', _model.rcBackImage, (f) => _model.rcBackImage = f, isNarrow),
            _buildDocTile('Vehicle', _model.vehicleImage, (f) => _model.vehicleImage = f, isNarrow),
            _buildDocTile('Registration', _model.registrationImage, (f) => _model.registrationImage = f, isNarrow),
            _buildDocTile('Insurance', _model.insuranceImage, (f) => _model.insuranceImage = f, isNarrow),
            _buildDocTile('Pollution Cert', _model.pollutionCertificateImage, (f) => _model.pollutionCertificateImage = f, isNarrow),
          ],
        ),
      ],
    );
  }

  Widget _buildDocTile(String label, FFUploadedFile file, void Function(FFUploadedFile) onPicked, bool isNarrow) {
    final hasImage = file.bytes?.isNotEmpty ?? false;
    final theme = FlutterFlowTheme.of(context);
    final size = isNarrow ? 130.0 : 156.0;
    return InkWell(
      onTap: _model.isUploadingDoc
          ? null
          : () => _pickDocumentImage(onPicked),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: size,
        height: isNarrow ? 100 : 120,
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasImage ? theme.primary.withValues(alpha:0.5) : theme.alternate,
            width: hasImage ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_model.isUploadingDoc)
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2, color: theme.primary),
              )
            else if (hasImage)
              Icon(Icons.check_circle_rounded, color: theme.primary, size: 36)
            else
              Icon(Icons.add_photo_alternate_rounded, color: theme.secondaryText, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.bodySmall.override(font: GoogleFonts.inter()),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleTypeDropdown() {
    final types = _model.vehicleTypesList;
    final theme = FlutterFlowTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vehicle Type *',
          style: theme.titleSmall.override(
            font: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.alternate),
          ),
          child: _model.isLoadingVehicleTypes
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _model.selectedVehicleTypeId,
                    isExpanded: true,
                    hint: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Select vehicle type'),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    items: types
                        .map((t) {
                          final id = castToType<int>(t['id'] ?? t['vehicle_type_id']);
                          final name = (t['name'] ?? t['vehicle_type_name'] ?? t['vehicle_type'] ?? 'Vehicle $id')?.toString();
                          if (id == null) return null;
                          return DropdownMenuItem<int>(
                            value: id,
                            child: Text(name ?? 'Vehicle $id'),
                          );
                        })
                        .whereType<DropdownMenuItem<int>>()
                        .toList(),
                    onChanged: (v) => setState(() => _model.selectedVehicleTypeId = v),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    required IconData prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(prefixIcon, color: FlutterFlowTheme.of(context).primary),
        filled: true,
        fillColor: FlutterFlowTheme.of(context).secondaryBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: FlutterFlowTheme.of(context).alternate),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: FlutterFlowTheme.of(context).primary,
            width: 2,
          ),
        ),
      ),
      style: FlutterFlowTheme.of(context).bodyMedium.override(
            font: GoogleFonts.inter(),
          ),
    );
  }
}
