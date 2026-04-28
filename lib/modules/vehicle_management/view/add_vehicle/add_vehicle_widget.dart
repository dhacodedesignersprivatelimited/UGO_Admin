import 'dart:typed_data';

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
import 'package:flutter_animate/flutter_animate.dart';
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

class _AddVehicleWidgetState extends State<AddVehicleWidget>
    with TickerProviderStateMixin {
  late AddVehicleModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSubmittingType = false;
  bool _isSubmittingSubType = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddVehicleModel());
    _tabController = TabController(length: 2, vsync: this);

    _model.vehicleNameTextController ??= TextEditingController();
    _model.vehicleNameFocusNode ??= FocusNode();
    _model.vehicleTypeTextController ??= TextEditingController();
    _model.vehicleTypeFocusNode ??= FocusNode();
    _model.typeNameTextController ??= TextEditingController();
    _model.typeNameFocusNode ??= FocusNode();
    _model.seatingCapacityTextController ??= TextEditingController();
    _model.seatingCapacityFocusNode ??= FocusNode();
    _model.luggageCapacityTextController ??= TextEditingController();
    _model.luggageCapacityFocusNode ??= FocusNode();
    _model.switchValue = true;

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

  Future<void> _pickTypeImage() async {
    final selectedMedia = await selectMediaWithSourceBottomSheet(
      context: context,
      allowPhoto: true,
    );
    if (selectedMedia != null &&
        selectedMedia
            .every((m) => validateFileFormat(m.storagePath, context))) {
      safeSetState(() => _model.isDataUploading_typeImage = true);
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
          safeSetState(() => _model.uploadedLocalFile_typeImage = files.first);
        }
      } finally {
        safeSetState(() => _model.isDataUploading_typeImage = false);
      }
    }
  }

  void _resetTypeForm() {
    _model.typeNameTextController?.clear();
    safeSetState(() => _model.uploadedLocalFile_typeImage =
        FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: ''));
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

  Future<void> _submitVehicleType() async {
    final name = _model.typeNameTextController?.text.trim() ?? '';
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
    if (_model.uploadedLocalFile_typeImage.bytes?.isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please upload an image for the vehicle type'),
          backgroundColor: FlutterFlowTheme.of(context).error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _isSubmittingType = true);
    try {
      final response = await AddVehicleTypeCall.call(
        name: name,
        image: _model.uploadedLocalFile_typeImage,
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
          _resetTypeForm();
          _loadVehicleTypes();
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
      if (mounted) setState(() => _isSubmittingType = false);
    }
  }

  int? _vehicleTypeIdFromMap(Map<String, dynamic> type) {
    final rawId =
        getJsonField(type, r'''$.id''') ?? getJsonField(type, r'''$._id''');
    if (rawId is int) return rawId;
    return int.tryParse(rawId.toString());
  }

  String _vehicleTypeNameFromMap(Map<String, dynamic> type) {
    return getJsonField(type, r'''$.name''')?.toString() ?? 'Unknown';
  }

  String? _vehicleTypeImageUrlFromMap(Map<String, dynamic> type) {
    final imgPath = getJsonField(type, r'''$.image''')?.toString();
    if (imgPath == null || imgPath.isEmpty) return null;
    return imgPath.startsWith('http')
        ? imgPath
        : '${ApiConfig.baseUrl}$imgPath';
  }

  Future<void> _openEditVehicleTypeDialog(Map<String, dynamic> type) async {
    final vehicleTypeId = _vehicleTypeIdFromMap(type);
    if (vehicleTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vehicle type ID is missing.'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
      return;
    }

    final nameController =
        TextEditingController(text: _vehicleTypeNameFromMap(type));
    FFUploadedFile? selectedImage;
    Uint8List? selectedImageBytes;
    bool isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Vehicle Type'),
              content: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Type Name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final selectedMedia =
                            await selectMediaWithSourceBottomSheet(
                          context: dialogContext,
                          allowPhoto: true,
                        );
                        if (selectedMedia == null ||
                            !selectedMedia.every(
                              (m) => validateFileFormat(
                                  m.storagePath, dialogContext),
                            )) {
                          return;
                        }
                        final files = selectedMedia
                            .map(
                              (m) => FFUploadedFile(
                                name: m.storagePath.split('/').last,
                                bytes: m.bytes,
                                height: m.dimensions?.height,
                                width: m.dimensions?.width,
                                blurHash: m.blurHash,
                                originalFilename: m.originalFilename,
                              ),
                            )
                            .toList();
                        if (files.isEmpty) return;
                        setDialogState(() {
                          selectedImage = files.first;
                          selectedImageBytes = files.first.bytes;
                        });
                      },
                      icon: const Icon(Icons.image_outlined),
                      label: Text(
                        selectedImageBytes == null
                            ? 'Change Image (optional)'
                            : 'Image selected',
                      ),
                    ),
                    if (selectedImageBytes != null) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          selectedImageBytes!,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isSaving ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: const Text('Name is required.'),
                                backgroundColor:
                                    FlutterFlowTheme.of(this.context).error,
                              ),
                            );
                            return;
                          }
                          setDialogState(() => isSaving = true);
                          final response = await UpdateVehicleTypeCall.call(
                            token: currentAuthenticationToken,
                            vehicleTypeId: vehicleTypeId,
                            name: name,
                            image: selectedImage,
                          );
                          if (!mounted) return;
                          Navigator.of(dialogContext).pop();
                          if (response.succeeded) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Vehicle type updated successfully.'),
                              ),
                            );
                            _loadVehicleTypes();
                          } else {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Update failed: ${response.jsonBody ?? response.statusCode}',
                                ),
                                backgroundColor:
                                    FlutterFlowTheme.of(this.context).error,
                              ),
                            );
                          }
                        },
                  child: Text(isSaving ? 'Saving...' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
  }

  void _showDeleteVehicleTypeApiMissing() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Delete Vehicle Type API is not available yet.',
        ),
        backgroundColor: FlutterFlowTheme.of(context).warning,
      ),
    );
  }

  Future<void> _submitVehicleSubType() async {
    final vehicleName = _model.vehicleNameTextController?.text.trim() ?? '';
    final seating = _model.seatingCapacityTextController?.text.trim() ?? '';
    final luggage = _model.luggageCapacityTextController?.text.trim() ?? '';

    if (vehicleName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter vehicle name'),
          backgroundColor: FlutterFlowTheme.of(context).error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_model.vehicleTypesList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add a vehicle type first (Tab 1)'),
          backgroundColor: FlutterFlowTheme.of(context).error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_model.selectedVehicleTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a vehicle type'),
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
            SnackBar(
              content: const Text('Vehicle sub type added successfully!'),
              backgroundColor: const Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
            ),
          );
          _resetSubTypeForm();
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
    _tabController.dispose();
    _model.dispose();
    super.dispose();
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: FlutterFlowTheme.of(context).titleSmall.override(
            font: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType ?? TextInputType.text,
      decoration: InputDecoration(
        hintText: hintText,
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: FlutterFlowTheme.of(context).bodyLarge,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminPopScope(
      fallbackRouteName: VehiclesListWidget.routeName,
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
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon:
                  const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
              onPressed: () => scaffoldKey.currentState?.openDrawer(),
            ),
            title: Text(
              'Add Vehicle',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                    color: Colors.white,
                    fontSize: 20,
                  ),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              tabs: const [
                Tab(text: 'Vehicle Type'),
                Tab(text: 'Vehicle Sub Type'),
              ],
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
                  FlutterFlowTheme.of(context).primary.withValues(alpha: 0.12),
                  FlutterFlowTheme.of(context).secondaryBackground,
                ],
              ),
            ),
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVehicleTypeTab(),
                _buildVehicleSubTypeTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleTypeTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add Vehicle Type',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                    color: FlutterFlowTheme.of(context).primaryText,
                    fontSize: 22,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Create a new vehicle type (e.g. Auto, Car, Bike)',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(),
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: FlutterFlowTheme.of(context)
                        .primary
                        .withValues(alpha: 0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Vehicle Type Name'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _model.typeNameTextController!,
                    focusNode: _model.typeNameFocusNode!,
                    hintText: 'e.g. AUTO, SEDAN, SUV, BIKE',
                  ),
                  const SizedBox(height: 24),
                  _buildFieldLabel('Vehicle Type Image'),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _model.isDataUploading_typeImage
                        ? null
                        : _pickTypeImage,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            FlutterFlowTheme.of(context)
                                .primary
                                .withValues(alpha: 0.1),
                            FlutterFlowTheme.of(context)
                                .secondary
                                .withValues(alpha: 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: FlutterFlowTheme.of(context)
                              .primary
                              .withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: _model.uploadedLocalFile_typeImage.bytes
                                  ?.isNotEmpty ??
                              false
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.memory(
                                    _model.uploadedLocalFile_typeImage.bytes!,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.white),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.black54,
                                      ),
                                      onPressed: _pickTypeImage,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_model.isDataUploading_typeImage)
                                    const CircularProgressIndicator()
                                  else
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 48,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Tap to upload image',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(),
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FFButtonWidget(
                    onPressed: _isSubmittingType ? null : _submitVehicleType,
                    text: _isSubmittingType ? 'Adding...' : 'Add Vehicle Type',
                    icon: Icon(
                      _isSubmittingType
                          ? Icons.hourglass_empty
                          : Icons.add_circle_outline,
                      size: 22,
                      color: Colors.white,
                    ),
                    options: FFButtonOptions(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                font: GoogleFonts.interTight(
                                    fontWeight: FontWeight.bold),
                                color: Colors.white,
                              ),
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'View Vehicle Types',
                          style:
                              FlutterFlowTheme.of(context).titleMedium.override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Refresh types',
                        onPressed: _model.isLoadingVehicleTypes
                            ? null
                            : _loadVehicleTypes,
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                    ],
                  ),
                  if (_model.isLoadingVehicleTypes)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (!_model.isLoadingVehicleTypes &&
                      _model.vehicleTypesList.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context)
                            .primary
                            .withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'No vehicle types found.',
                        style: FlutterFlowTheme.of(context).bodyMedium,
                      ),
                    ),
                  if (!_model.isLoadingVehicleTypes &&
                      _model.vehicleTypesList.isNotEmpty)
                    ..._model.vehicleTypesList.map((type) {
                      final id = _vehicleTypeIdFromMap(type);
                      final name = _vehicleTypeNameFromMap(type);
                      final imageUrl = _vehicleTypeImageUrlFromMap(type);
                      return Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: FlutterFlowTheme.of(context).alternate,
                          ),
                        ),
                        child: Row(
                          children: [
                            if (imageUrl != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 44,
                                    height: 44,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primary
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.directions_car,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primary
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.directions_car,
                                  color: FlutterFlowTheme.of(context).primary,
                                ),
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                  ),
                                  if (id != null)
                                    Text(
                                      'ID: $id',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall,
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Edit',
                              onPressed: () => _openEditVehicleTypeDialog(type),
                              icon: Icon(
                                Icons.edit_outlined,
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              onPressed: _showDeleteVehicleTypeApiMissing,
                              icon: Icon(
                                Icons.delete_outline,
                                color: FlutterFlowTheme.of(context).error,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleSubTypeTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add Vehicle Sub Type',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                    color: FlutterFlowTheme.of(context).primaryText,
                    fontSize: 22,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add a sub vehicle under a vehicle type with details',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(),
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: FlutterFlowTheme.of(context)
                        .primary
                        .withValues(alpha: 0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFieldLabel('Vehicle Name'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _model.vehicleNameTextController!,
                    focusNode: _model.vehicleNameFocusNode!,
                    hintText: 'e.g. Toyota Camry, Auto Pro',
                  ),
                  const SizedBox(height: 20),
                  _buildFieldLabel('Vehicle Type'),
                  const SizedBox(height: 8),
                  if (_model.isLoadingVehicleTypes)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: FlutterFlowTheme.of(context).primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Loading vehicle types...',
                            style: FlutterFlowTheme.of(context).bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  if (!_model.isLoadingVehicleTypes &&
                      _model.vehicleTypesList.isNotEmpty)
                    DropdownButtonFormField<int>(
                      value: _model.selectedVehicleTypeId,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            FlutterFlowTheme.of(context).secondaryBackground,
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
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      hint: Text(
                        'Select vehicle type',
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                      ),
                      items: _model.vehicleTypesList.map((vt) {
                        final id = getJsonField(vt, r'''$.id''') ??
                            getJsonField(vt, r'''$._id''');
                        final name =
                            getJsonField(vt, r'''$.name''')?.toString() ??
                                'Unknown';
                        final imgPath =
                            getJsonField(vt, r'''$.image''')?.toString();
                        final imgUrl = imgPath != null && imgPath.isNotEmpty
                            ? (imgPath.startsWith('http')
                                ? imgPath
                                : '${ApiConfig.baseUrl}$imgPath')
                            : null;
                        final validImg = imgUrl != null && imgUrl.isNotEmpty;
                        return DropdownMenuItem<int>(
                          value: castToType<int>(id),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (validImg)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    imgUrl!,
                                    width: 36,
                                    height: 36,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.directions_car,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              if (validImg) const SizedBox(width: 12),
                              Flexible(
                                fit: FlexFit.loose,
                                child: Text(
                                  name,
                                  style: FlutterFlowTheme.of(context).bodyLarge,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (v) {
                        safeSetState(() {
                          _model.selectedVehicleTypeId = v;
                          final selected = _model.vehicleTypesList.where((x) {
                            final id = getJsonField(x, r'''$.id''') ??
                                getJsonField(x, r'''$._id''');
                            return castToType<int>(id) == v;
                          }).firstOrNull;
                          _model.selectedVehicleTypeName = selected != null
                              ? getJsonField(selected, r'''$.name''')
                                  ?.toString()
                              : null;
                        });
                      },
                    ),
                  if (!_model.isLoadingVehicleTypes &&
                      _model.vehicleTypesList.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context)
                            .primary
                            .withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Add a vehicle type in the first tab first',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              color: FlutterFlowTheme.of(context).primaryText,
                            ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  _buildFieldLabel('Ride Category'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _model.selectedRideCategory ?? 'pro',
                    decoration: InputDecoration(
                      filled: true,
                      fillColor:
                          FlutterFlowTheme.of(context).secondaryBackground,
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
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    items: const ['pro', 'normal'].map((v) {
                      return DropdownMenuItem<String>(
                        value: v,
                        child: Text(v[0].toUpperCase() + v.substring(1)),
                      );
                    }).toList(),
                    onChanged: (v) => safeSetState(
                        () => _model.selectedRideCategory = v ?? 'pro'),
                  ),
                  const SizedBox(height: 20),
                  _buildFieldLabel('Seating Capacity'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _model.seatingCapacityTextController!,
                    focusNode: _model.seatingCapacityFocusNode!,
                    hintText: 'e.g. 4, 6',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  _buildFieldLabel('Luggage Capacity'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _model.luggageCapacityTextController!,
                    focusNode: _model.luggageCapacityFocusNode!,
                    hintText: 'e.g. 2',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  _buildFieldLabel('Vehicle Image'),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final selectedMedia =
                          await selectMediaWithSourceBottomSheet(
                        context: context,
                        allowPhoto: true,
                      );
                      if (selectedMedia != null &&
                          selectedMedia.every((m) =>
                              validateFileFormat(m.storagePath, context))) {
                        safeSetState(
                            () => _model.isDataUploading_uploadDataTws = true);
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
                            safeSetState(() => _model
                                .uploadedLocalFile_uploadDataTws = files.first);
                          }
                        } finally {
                          safeSetState(() =>
                              _model.isDataUploading_uploadDataTws = false);
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            FlutterFlowTheme.of(context)
                                .primary
                                .withValues(alpha: 0.1),
                            FlutterFlowTheme.of(context)
                                .secondary
                                .withValues(alpha: 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: FlutterFlowTheme.of(context)
                              .primary
                              .withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: _model.uploadedLocalFile_uploadDataTws.bytes
                                  ?.isNotEmpty ??
                              false
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.memory(
                                    _model
                                        .uploadedLocalFile_uploadDataTws.bytes!,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 48,
                                    color: FlutterFlowTheme.of(context).primary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap to upload vehicle image',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      TextButton(
                        onPressed:
                            _isSubmittingSubType ? null : _resetSubTypeForm,
                        child: Text(
                          'Reset',
                          style: FlutterFlowTheme.of(context)
                              .bodyLarge
                              .override(
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                              ),
                        ),
                      ),
                      FFButtonWidget(
                        onPressed:
                            _isSubmittingSubType ? null : _submitVehicleSubType,
                        text: _isSubmittingSubType
                            ? 'Saving...'
                            : 'Save Vehicle Sub Type',
                        icon: _isSubmittingSubType
                            ? null
                            : Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                        options: FFButtonOptions(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.interTight(
                                        fontWeight: FontWeight.w600),
                                    color: Colors.white,
                                  ),
                          elevation: 2,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
