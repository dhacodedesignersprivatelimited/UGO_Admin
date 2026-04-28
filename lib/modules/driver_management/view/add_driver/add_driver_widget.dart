import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';
import '/shared/widgets/admin_drawer.dart';
import '/shared/widgets/admin_pop_scope.dart';
import '/index.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';
import '/config/theme/flutter_flow_widgets.dart';
import '/config/theme/upload_data.dart';
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
        fcmToken: 'admin_created', // Hardcoded safely behind the scenes
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
        final msg = getJsonField(response.jsonBody, r'''$.message''')?.toString() ?? 'Failed to create driver';
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
    return AdminPopScope(
      fallbackRouteName: AllusersWidget.routeName,
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
              onPressed: () => context.goNamedAuth(AllusersWidget.routeName, context.mounted),
            ),
            title: Text(
              ' New Driver',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                color: Colors.white,
                fontSize: 22,
              ),
            ),
            elevation: 0,
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;
              final padding = EdgeInsets.symmetric(
                horizontal: isWide ? 32 : 16,
                vertical: isWide ? 24 : 16,
              );
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: padding,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildSectionCard(
                                title: 'Personal Information',
                                icon: Icons.person_rounded,
                                children: [
                                  _buildTextField(
                                    controller: _model.mobileNumberTextController!,
                                    focusNode: _model.mobileNumberFocusNode!,
                                    label: 'Mobile Number *',
                                    hint: 'e.g. 9107988035',
                                    keyboardType: TextInputType.phone,
                                    prefixIcon: Icons.phone_rounded,
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildTextField(
                                          controller: _model.firstNameTextController!,
                                          focusNode: _model.firstNameFocusNode!,
                                          label: 'First Name *',
                                          hint: 'e.g. Hari',
                                          prefixIcon: Icons.person_outline_rounded,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildTextField(
                                          controller: _model.lastNameTextController!,
                                          focusNode: _model.lastNameFocusNode!,
                                          label: 'Last Name *',
                                          hint: 'e.g. Yadav',
                                          prefixIcon: Icons.person_outline_rounded,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: _model.emailTextController!,
                                    focusNode: _model.emailFocusNode!,
                                    label: 'Email Address *',
                                    hint: 'e.g. driver@example.com',
                                    keyboardType: TextInputType.emailAddress,
                                    prefixIcon: Icons.email_rounded,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              _buildSectionCard(
                                title: 'Location & Assignment',
                                icon: Icons.map_rounded,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: _buildTextField(
                                          controller: _model.cityTextController!,
                                          focusNode: _model.cityFocusNode!,
                                          label: 'City',
                                          hint: 'e.g. Hyderabad',
                                          prefixIcon: Icons.location_city_rounded,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildTextField(
                                          controller: _model.stateTextController!,
                                          focusNode: _model.stateFocusNode!,
                                          label: 'State',
                                          hint: 'e.g. TS',
                                          prefixIcon: Icons.map_rounded,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: _model.postalCodeTextController!,
                                    focusNode: _model.postalCodeFocusNode!,
                                    label: 'Postal Code',
                                    hint: 'e.g. 500001',
                                    keyboardType: TextInputType.number,
                                    prefixIcon: Icons.pin_drop_rounded,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              _buildSectionCard(
                                title: 'Vehicle & System Integration',
                                icon: Icons.local_taxi_rounded,
                                children: [
                                  _buildVehicleTypeDropdown(),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: _model.referralCodeTextController!,
                                    focusNode: _model.referralCodeFocusNode!,
                                    label: 'Used Referral Code (optional)',
                                    hint: 'Referral code from another driver',
                                    prefixIcon: Icons.card_giftcard_rounded,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              _buildSectionCard(
                                title: 'Driver & Vehicle Documents',
                                icon: Icons.folder_shared_rounded,
                                children: [
                                  _buildDocumentsSection(),
                                ],
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Sticky Bottom Action Bar
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          offset: const Offset(0, -4),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: FFButtonWidget(
                          onPressed: _isSubmitting ? null : () => _submit(),
                          text: _isSubmitting ? 'Creating Driver Profile...' : 'Complete Driver Onboarding',
                          icon: _isSubmitting
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Icon(Icons.check_circle_rounded, size: 22, color: Colors.white),
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 56,
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                              font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                              color: Colors.white,
                            ),
                            elevation: 3,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // --- UI HELPER METHODS ---

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: FlutterFlowTheme.of(context).primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDocumentsSection() {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload required files to complete driver verification.',
          style: theme.bodySmall.override(
            font: GoogleFonts.inter(),
            color: theme.secondaryText,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            _buildDocTile('Profile Photo', _model.profileImage, (f) => _model.profileImage = f),
            const SizedBox(height: 12),
            _buildDocTile('License Front', _model.licenseFrontImage, (f) => _model.licenseFrontImage = f),
            const SizedBox(height: 12),
            _buildDocTile('License Back', _model.licenseBackImage, (f) => _model.licenseBackImage = f),
            const SizedBox(height: 12),
            _buildDocTile('Aadhaar Front', _model.aadhaarFrontImage, (f) => _model.aadhaarFrontImage = f),
            const SizedBox(height: 12),
            _buildDocTile('Aadhaar Back', _model.aadhaarBackImage, (f) => _model.aadhaarBackImage = f),
            const SizedBox(height: 12),
            _buildDocTile('PAN Card', _model.panImage, (f) => _model.panImage = f),
            const SizedBox(height: 12),
            _buildDocTile('RC Front', _model.rcFrontImage, (f) => _model.rcFrontImage = f),
            const SizedBox(height: 12),
            _buildDocTile('RC Back', _model.rcBackImage, (f) => _model.rcBackImage = f),
            const SizedBox(height: 12),
            _buildDocTile('Vehicle Image', _model.vehicleImage, (f) => _model.vehicleImage = f),
            const SizedBox(height: 12),
            _buildDocTile('Registration Certificate', _model.registrationImage, (f) => _model.registrationImage = f),
            const SizedBox(height: 12),
            _buildDocTile('Vehicle Insurance', _model.insuranceImage, (f) => _model.insuranceImage = f),
            const SizedBox(height: 12),
            _buildDocTile('Pollution Certificate', _model.pollutionCertificateImage, (f) => _model.pollutionCertificateImage = f),
          ],
        ),
      ],
    );
  }

  Widget _buildDocTile(String label, FFUploadedFile file, void Function(FFUploadedFile) onPicked) {
    final hasImage = file.bytes?.isNotEmpty ?? false;
    final theme = FlutterFlowTheme.of(context);

    return InkWell(
      onTap: _model.isUploadingDoc ? null : () => _pickDocumentImage(onPicked),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: hasImage ? theme.primary.withValues(alpha: 0.05) : theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasImage ? theme.primary : theme.alternate,
            width: hasImage ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: hasImage ? theme.primary.withValues(alpha: 0.1) : theme.primaryBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _model.isUploadingDoc
                  ? Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: theme.primary),
                ),
              )
                  : Icon(
                hasImage ? Icons.check_circle_rounded : Icons.insert_drive_file_outlined,
                color: hasImage ? theme.primary : theme.secondaryText,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.bodyMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: hasImage ? theme.primary : theme.primaryText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasImage ? 'Document uploaded successfully' : 'Tap to upload document',
                    style: theme.bodySmall.override(
                      font: GoogleFonts.inter(),
                      color: hasImage ? theme.primary : theme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              hasImage ? Icons.edit_rounded : Icons.cloud_upload_outlined,
              color: hasImage ? theme.primary : theme.secondaryText,
              size: 20,
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
          'Vehicle Category *',
          style: theme.bodyMedium.override(
            font: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.primaryBackground,
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
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.secondaryText),
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Select vehicle type', style: theme.bodyMedium),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              items: types
                  .map((t) {
                final id = castToType<int>(t['id'] ?? t['vehicle_type_id']);
                final name = (t['name'] ?? t['vehicle_type_name'] ?? t['vehicle_type'] ?? 'Vehicle $id')?.toString();
                if (id == null) return null;
                return DropdownMenuItem<int>(
                  value: id,
                  child: Text(name ?? 'Vehicle $id', style: theme.bodyMedium),
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
    final theme = FlutterFlowTheme.of(context);
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.bodyMedium.override(
          font: GoogleFonts.inter(),
          color: theme.secondaryText,
        ),
        hintText: hint,
        hintStyle: theme.bodySmall.override(
          font: GoogleFonts.inter(),
          color: theme.alternate,
        ),
        prefixIcon: Icon(prefixIcon, color: theme.secondaryText, size: 20),
        filled: true,
        fillColor: theme.primaryBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.alternate),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.alternate),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.primary,
            width: 2,
          ),
        ),
      ),
      style: theme.bodyMedium.override(
        font: GoogleFonts.inter(),
      ),
    );
  }
}