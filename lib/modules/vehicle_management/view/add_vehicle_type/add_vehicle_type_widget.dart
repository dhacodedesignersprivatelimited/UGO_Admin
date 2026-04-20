import 'dart:typed_data';

import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';
import '/shared/widgets/admin_drawer.dart';
import '/shared/widgets/admin_pop_scope.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';
import '/config/theme/flutter_flow_widgets.dart';
import '/config/theme/upload_data.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_vehicle_type_model.dart';
export 'add_vehicle_type_model.dart';

class AddVehicleTypeWidget extends StatefulWidget {
  const AddVehicleTypeWidget({super.key});

  static String routeName = 'AddVehicleType';
  static String routePath = '/addVehicleType';

  @override
  State<AddVehicleTypeWidget> createState() => _AddVehicleTypeWidgetState();
}

class _AddVehicleTypeWidgetState extends State<AddVehicleTypeWidget>
    with TickerProviderStateMixin {
  late AddVehicleTypeModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddVehicleTypeModel());
    _model.nameTextController ??= TextEditingController();
    _model.nameFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final selectedMedia = await selectMediaWithSourceBottomSheet(
      context: context,
      allowPhoto: true,
    );
    if (selectedMedia != null &&
        selectedMedia.every((m) => validateFileFormat(m.storagePath, context))) {
      setState(() => _model.isDataUploading = true);
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
          setState(() => _model.uploadedLocalFile = files.first);
        }
      } finally {
        setState(() => _model.isDataUploading = false);
      }
    }
  }

  Future<void> _submit() async {
    final name = _model.nameTextController?.text.trim() ?? '';
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a vehicle type name'),
          backgroundColor: FlutterFlowTheme.of(context).error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_model.uploadedLocalFile.bytes?.isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please upload an image'),
          backgroundColor: FlutterFlowTheme.of(context).error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final response = await AddVehicleTypeCall.call(
        name: name,
        image: _model.uploadedLocalFile,
        token: currentAuthenticationToken,
      );

      if (mounted) {
        if (response.succeeded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Vehicle type added successfully!'),
              backgroundColor: const Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
            ),
          );
          _model.nameTextController?.clear();
          setState(() => _model.uploadedLocalFile =
              FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: ''));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed: ${response.jsonBody ?? "Unknown error"}'),
              backgroundColor: FlutterFlowTheme.of(context).error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminPopScope(
      fallbackRouteName: VehiclesListWidget.routeName,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          key: scaffoldKey,
          drawer: buildAdminDrawer(context),
          appBar: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primary,
            automaticallyImplyLeading: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
              onPressed: () =>
                  context.goNamedAuth(VehiclesListWidget.routeName, context.mounted),
            ),
            title: Text(
              'Add Vehicle Type',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                    color: Colors.white,
                    fontSize: 20,
                  ),
            ),
            elevation: 2,
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  FlutterFlowTheme.of(context).primary.withValues(alpha:0.15),
                  FlutterFlowTheme.of(context).secondaryBackground,
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Add Vehicle Type',
                      style: FlutterFlowTheme.of(context).headlineMedium.override(
                            font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                            color: FlutterFlowTheme.of(context).primaryText,
                            fontSize: 28,
                          ),
                    )
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideX(begin: -0.2, end: 0, curve: Curves.easeOut),
                    const SizedBox(height: 8),
                    Text(
                      'Create a new vehicle type with name and image',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(),
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 100.ms)
                        .slideX(begin: -0.1, end: 0, curve: Curves.easeOut),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: FlutterFlowTheme.of(context).primary.withValues(alpha:0.08),
                            blurRadius: 30,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Vehicle Type Name',
                            style: FlutterFlowTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _model.nameTextController,
                            focusNode: _model.nameFocusNode,
                            decoration: InputDecoration(
                              hintText: 'e.g. AUTO, BIKE, CAR',
                              filled: true,
                              fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            style: FlutterFlowTheme.of(context).bodyLarge,
                          )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 150.ms)
                              .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
                          const SizedBox(height: 24),
                          Text(
                            'Vehicle Type Image',
                            style: FlutterFlowTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _model.isDataUploading ? null : _pickImage,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              height: 160,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    FlutterFlowTheme.of(context).primary.withValues(alpha:0.1),
                                    FlutterFlowTheme.of(context).secondary.withValues(alpha:0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).primary.withValues(alpha:0.3),
                                  width: 2,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: _model.uploadedLocalFile.bytes?.isNotEmpty ?? false
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.memory(
                                            _model.uploadedLocalFile.bytes!,
                                            fit: BoxFit.cover,
                                          ),
                                          Positioned(
                                            bottom: 8,
                                            right: 8,
                                            child: IconButton(
                                              icon: const Icon(Icons.edit, color: Colors.white),
                                              style: IconButton.styleFrom(
                                                backgroundColor: Colors.black54,
                                              ),
                                              onPressed: _pickImage,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          if (_model.isDataUploading)
                                            const CircularProgressIndicator()
                                          else
                                            Icon(
                                              Icons.add_photo_alternate_outlined,
                                              size: 48,
                                              color: FlutterFlowTheme.of(context).primary,
                                            ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Tap to upload image',
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                  font: GoogleFonts.inter(),
                                                  color: FlutterFlowTheme.of(context).secondaryText,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 200.ms)
                              .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
                          const SizedBox(height: 32),
                          FFButtonWidget(
                            onPressed: _isSubmitting ? null : _submit,
                            text: _isSubmitting ? 'Adding...' : 'Add Vehicle Type',
                            icon: Icon(
                              _isSubmitting ? Icons.hourglass_empty : Icons.add_circle_outline,
                              size: 22,
                              color: Colors.white,
                            ),
                            options: FFButtonOptions(
                              height: 56,
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                                    color: Colors.white,
                                  ),
                              elevation: 4,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 250.ms)
                              .slideY(begin: 0.15, end: 0, curve: Curves.easeOut),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 50.ms)
                        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), curve: Curves.easeOut),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
