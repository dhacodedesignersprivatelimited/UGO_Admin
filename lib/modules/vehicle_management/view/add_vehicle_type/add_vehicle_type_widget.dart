
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

  // --- API LOGIC (UNTOUCHED) ---

  Future<void> _pickImage() async {
    final selectedMedia = await selectMediaWithSourceBottomSheet(
      context: context,
      allowPhoto: true,
    );
    if (selectedMedia != null &&
        selectedMedia
            .every((m) => validateFileFormat(m.storagePath, context))) {
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
          content: const Text('Please enter a vehicle category name'),
          backgroundColor: FlutterFlowTheme.of(context).error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_model.uploadedLocalFile.bytes?.isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please upload a cover image'),
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
            const SnackBar(
              content: Text('Vehicle category added successfully!'),
              backgroundColor: Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
            ),
          );
          _model.nameTextController?.clear();
          setState(() => _model.uploadedLocalFile = FFUploadedFile(
              bytes: Uint8List.fromList([]), originalFilename: ''));

          // Redirect back to catalog after success
          context.goNamedAuth(VehiclesListWidget.routeName, context.mounted);
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

  // --- UI HELPER METHODS ---

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
          font: GoogleFonts.inter(fontWeight: FontWeight.w600),
          color: FlutterFlowTheme.of(context).primaryText,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return AdminPopScope(
      fallbackRouteName: VehiclesListWidget.routeName,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: const Color(0xFFF4F6FA), // Consistent light background
          drawer: buildAdminDrawer(context),
          appBar: AppBar(
            backgroundColor: theme.primary,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
              onPressed: () => context.goNamedAuth(VehiclesListWidget.routeName, context.mounted),
            ),
            title: Text(
              'Add Category',
              style: theme.headlineMedium.override(
                font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                color: Colors.white,
                fontSize: 22,
              ),
            ),
            elevation: 0,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Category Profile',
                        style: theme.headlineMedium.override(
                          font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                          color: theme.primaryText,
                          fontSize: 24,
                        ),
                      ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.05, end: 0),
                      const SizedBox(height: 6),
                      Text(
                        'Create a high-level vehicle grouping (e.g., Auto, Sedan, SUV, Bike).',
                        style: theme.bodyMedium.override(
                          font: GoogleFonts.inter(),
                          color: theme.secondaryText,
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: -0.05, end: 0),
                      const SizedBox(height: 32),

                      // Input Form Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Name Input
                            _buildFieldLabel('Category Name *'),
                            TextFormField(
                              controller: _model.nameTextController,
                              focusNode: _model.nameFocusNode,
                              decoration: InputDecoration(
                                hintText: 'e.g. BIKE AUTO CAR',
                                hintStyle: GoogleFonts.inter(color: Colors.black38, fontSize: 14),
                                prefixIcon: const Icon(Icons.category_rounded, size: 18, color: Colors.black45),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: theme.primary, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                              style: theme.bodyLarge,
                            ).animate().fadeIn(duration: 400.ms, delay: 150.ms).slideY(begin: 0.1, end: 0),

                            const SizedBox(height: 24),

                            // Image Input
                            _buildFieldLabel('Category Display Image *'),
                            InkWell(
                              onTap: _model.isDataUploading ? null : _pickImage,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                height: 160,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: theme.alternate,
                                    width: 2,
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
                                          icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                                          style: IconButton.styleFrom(
                                            backgroundColor: Colors.black.withValues(alpha: 0.6),
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
                                        CircularProgressIndicator(color: theme.primary)
                                      else
                                        Icon(Icons.cloud_upload_outlined, size: 40, color: theme.secondaryText),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Click to browse or drag image here',
                                        style: GoogleFonts.inter(fontSize: 13, color: theme.secondaryText),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),

                            const SizedBox(height: 32),

                            // Submit Button
                            FFButtonWidget(
                              onPressed: _isSubmitting ? null : _submit,
                              text: _isSubmitting ? 'Saving Category...' : 'Create  Category',
                              icon: Icon(
                                _isSubmitting ? Icons.hourglass_empty : Icons.check_circle_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                              options: FFButtonOptions(
                                height: 52,
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                color: theme.primary,
                                textStyle: theme.titleSmall.override(
                                  font: GoogleFonts.interTight(fontWeight: FontWeight.w700),
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                elevation: 2,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ).animate().fadeIn(duration: 400.ms, delay: 250.ms).slideY(begin: 0.15, end: 0),
                          ],
                        ),
                      ).animate().fadeIn(duration: 500.ms, delay: 50.ms).scale(
                          begin: const Offset(0.98, 0.98),
                          end: const Offset(1, 1),
                          curve: Curves.easeOut),
                    ],
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