
import '/core/auth/auth_util.dart';
import '/core/network/api_config.dart';
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
import 'add_vehicle_model.dart';
export 'add_vehicle_model.dart';

class AddVehicleWidget extends StatefulWidget {
  const AddVehicleWidget({super.key});

  static String routeName = 'AddVehicle';
  static String routePath = '/addVehicle';

  @override
  State<AddVehicleWidget> createState() => _AddVehicleWidgetState();
}

class _AddVehicleWidgetState extends State<AddVehicleWidget> {
  late AddVehicleModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSubmittingSubType = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddVehicleModel());

    // Initialize required fields for Sub-Vehicle
    _model.vehicleNameTextController ??= TextEditingController();
    _model.vehicleNameFocusNode ??= FocusNode();
    _model.seatingCapacityTextController ??= TextEditingController();
    _model.seatingCapacityFocusNode ??= FocusNode();
    _model.luggageCapacityTextController ??= TextEditingController();
    _model.luggageCapacityFocusNode ??= FocusNode();
    _model.switchValue = true;

    _loadVehicleTypes();
  }

  // --- API LOGIC ---

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

  void _resetSubTypeForm() {
    _model.vehicleNameTextController?.clear();
    _model.seatingCapacityTextController?.clear();
    _model.luggageCapacityTextController?.clear();
    safeSetState(() {
      _model.selectedVehicleTypeId = null;
      _model.selectedVehicleTypeName = null;
      _model.selectedRideCategory = 'pro';
      _model.uploadedLocalFile_uploadDataTws =
          FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
      _model.switchValue = true;
    });
  }

  Future<void> _submitVehicleSubType() async {
    final vehicleName = _model.vehicleNameTextController?.text.trim() ?? '';
    final seating = _model.seatingCapacityTextController?.text.trim() ?? '';
    final luggage = _model.luggageCapacityTextController?.text.trim() ?? '';

    if (vehicleName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a vehicle name'),
          backgroundColor: FlutterFlowTheme.of(context).error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_model.vehicleTypesList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please create a Parent Category first.'),
          backgroundColor: FlutterFlowTheme.of(context).error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_model.selectedVehicleTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please assign this vehicle to a Parent Category'),
          backgroundColor: FlutterFlowTheme.of(context).error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmittingSubType = true);
    try {
      final response = await AddVehicleCall.call(
        vehicleTypeId: _model.selectedVehicleTypeId!,
        rideCategory: _model.selectedRideCategory ?? 'pro',
        vehicleName: vehicleName,
        seatingCapacity: seating,
        luggageCapacity: luggage,
        vehicleImage:
        _model.uploadedLocalFile_uploadDataTws.bytes?.isNotEmpty ?? false
            ? _model.uploadedLocalFile_uploadDataTws
            : null,
        token: currentAuthenticationToken,
      );

      if (mounted) {
        if (response.succeeded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vehicle added successfully!'),
              backgroundColor: Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
            ),
          );
          _resetSubTypeForm();
          // Navigate back to the list after success
          context.goNamedAuth(VehiclesListWidget.routeName, context.mounted);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed: ${getJsonField(response.jsonBody, r'''$.message''') ?? response.jsonBody ?? "Unknown error"}',
              ),
              backgroundColor: FlutterFlowTheme.of(context).error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isSubmittingSubType = false);
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
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

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    TextInputType? keyboardType,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType ?? TextInputType.text,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.inter(color: Colors.black38, fontSize: 14),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18, color: Colors.black45) : null,
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
          borderSide: BorderSide(color: FlutterFlowTheme.of(context).primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      style: FlutterFlowTheme.of(context).bodyMedium,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return AdminPopScope(
        fallbackRouteName: VehiclesListWidget.routeName,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: const Color(0xFFF4F6FA), // Light SaaS Background
            drawer: buildAdminDrawer(context),
            appBar: AppBar(
              backgroundColor: theme.primary,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
                onPressed: () => context.goNamedAuth(VehiclesListWidget.routeName, context.mounted),
              ),
              title: Text(
                'Add Sub Vehicle',
                style: theme.headlineMedium.override(
                  font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
              elevation: 0,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Vehicle Profile',
                        style: theme.headlineSmall.override(
                          font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                          color: theme.primaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add a sub vehicle model and configure its capacity attributes.',
                        style: theme.bodyMedium.override(color: theme.secondaryText),
                      ),
                      const SizedBox(height: 24),

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

                            // Vehicle Name
                            _buildFieldLabel('Sub Model Name *'),
                            _buildTextField(
                              controller: _model.vehicleNameTextController!,
                              focusNode: _model.vehicleNameFocusNode!,
                              hintText: 'e.g. Toyota Innova, Honda City',
                              prefixIcon: Icons.directions_car_rounded,
                            ),
                            const SizedBox(height: 20),

                            // Dropdowns Row
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildFieldLabel('Parent Category *'),
                                      if (_model.isLoadingVehicleTypes)
                                        const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 16),
                                          child: Center(child: CircularProgressIndicator()),
                                        )
                                      else if (_model.vehicleTypesList.isEmpty)
                                        Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: theme.error.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'No Categories found. Create one first.',
                                            style: GoogleFonts.inter(color: theme.error, fontSize: 13),
                                          ),
                                        )
                                      else
                                        DropdownButtonFormField<int>(
                                          value: _model.selectedVehicleTypeId,
                                          decoration: InputDecoration(
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
                                          hint: Text('Select Category', style: GoogleFonts.inter(color: Colors.black38)),
                                          items: _model.vehicleTypesList.map((vt) {
                                            final id = getJsonField(vt, r'''$.id''') ?? getJsonField(vt, r'''$._id''');
                                            final name = getJsonField(vt, r'''$.name''')?.toString() ?? 'Unknown';
                                            return DropdownMenuItem<int>(
                                              value: castToType<int>(id),
                                              child: Text(name, style: GoogleFonts.inter()),
                                            );
                                          }).toList(),
                                          onChanged: (v) {
                                            safeSetState(() {
                                              _model.selectedVehicleTypeId = v;
                                            });
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildFieldLabel('Service Tier *'),
                                      DropdownButtonFormField<String>(
                                        value: _model.selectedRideCategory ?? 'pro',
                                        decoration: InputDecoration(
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
                                        items: const ['pro', 'normal'].map((v) {
                                          return DropdownMenuItem<String>(
                                            value: v,
                                            child: Text(v[0].toUpperCase() + v.substring(1), style: GoogleFonts.inter()),
                                          );
                                        }).toList(),
                                        onChanged: (v) => safeSetState(() => _model.selectedRideCategory = v ?? 'pro'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Capacities Row
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildFieldLabel('Passenger Seats *'),
                                      _buildTextField(
                                        controller: _model.seatingCapacityTextController!,
                                        focusNode: _model.seatingCapacityFocusNode!,
                                        hintText: 'e.g. 4',
                                        keyboardType: TextInputType.number,
                                        prefixIcon: Icons.airline_seat_recline_normal_rounded,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildFieldLabel('Luggage Limit *'),
                                      _buildTextField(
                                        controller: _model.luggageCapacityTextController!,
                                        focusNode: _model.luggageCapacityFocusNode!,
                                        hintText: 'e.g. 2 bags',
                                        keyboardType: TextInputType.number,
                                        prefixIcon: Icons.work_outline_rounded,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Image Uploader
                            _buildFieldLabel('Vehicle Preview Image *'),
                            InkWell(
                              onTap: () async {
                                final selectedMedia = await selectMediaWithSourceBottomSheet(
                                  context: context,
                                  allowPhoto: true,
                                );
                                if (selectedMedia != null &&
                                    selectedMedia.every((m) => validateFileFormat(m.storagePath, context))) {
                                  safeSetState(() => _model.isDataUploading_uploadDataTws = true);
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
                                      safeSetState(() => _model.uploadedLocalFile_uploadDataTws = files.first);
                                    }
                                  } finally {
                                    safeSetState(() => _model.isDataUploading_uploadDataTws = false);
                                  }
                                }
                              },
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
                                child: _model.uploadedLocalFile_uploadDataTws.bytes?.isNotEmpty ?? false
                                    ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.memory(
                                        _model.uploadedLocalFile_uploadDataTws.bytes!,
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        child: IconButton(
                                          icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                                          style: IconButton.styleFrom(
                                            backgroundColor: Colors.black.withValues(alpha: 0.6),
                                          ),
                                          onPressed: () {}, // Handled by container tap
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                    : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_model.isDataUploading_uploadDataTws)
                                        CircularProgressIndicator(color: theme.primary)
                                      else
                                        Icon(Icons.directions_car_rounded, size: 40, color: theme.secondaryText),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Click to browse or drag image here',
                                        style: GoogleFonts.inter(fontSize: 13, color: theme.secondaryText),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Actions Footer
                            Container(
                              padding: const EdgeInsets.only(top: 16),
                              decoration: BoxDecoration(
                                border: Border(top: BorderSide(color: Colors.grey.shade200)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: _isSubmittingSubType ? null : _resetSubTypeForm,
                                    child: Text('Reset Fields', style: GoogleFonts.inter(color: theme.secondaryText)),
                                  ),
                                  const SizedBox(width: 16),
                                  FilledButton.icon(
                                    onPressed: _isSubmittingSubType ? null : _submitVehicleSubType,
                                    icon: Icon(
                                      _isSubmittingSubType ? Icons.hourglass_empty : Icons.check_circle_rounded,
                                      size: 18,
                                    ),
                                    label: Text(
                                      _isSubmittingSubType ? 'Saving Profile...' : 'Save Specific Vehicle',
                                      style: GoogleFonts.interTight(fontWeight: FontWeight.w600, fontSize: 15),
                                    ),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFF2E7D32),
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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