import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';
import '/config/theme/flutter_flow_icon_button.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';
import '/config/theme/flutter_flow_widgets.dart';
import '/config/theme/upload_data.dart';
import '/config/theme/uploaded_file.dart';
import 'dart:typed_data';
import 'dart:ui';
import 'add_vehicle_widget.dart' show AddVehicleWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddVehicleModel extends FlutterFlowModel<AddVehicleWidget> {
  ///  State fields for stateful widgets in this page.

  // Vehicle types from API
  List<Map<String, dynamic>> vehicleTypesList = [];
  bool isLoadingVehicleTypes = false;
  int? selectedVehicleTypeId;
  String? selectedVehicleTypeName;

  // State field(s) for vehicleName widget.
  FocusNode? vehicleNameFocusNode;
  TextEditingController? vehicleNameTextController;
  String? Function(BuildContext, String?)? vehicleNameTextControllerValidator;
  // State field(s) for vehicleType widget - kept for compatibility, dropdown replaces input
  FocusNode? vehicleTypeFocusNode;
  TextEditingController? vehicleTypeTextController;
  String? Function(BuildContext, String?)? vehicleTypeTextControllerValidator;
  // Ride category for sub-vehicle (pro, standard, etc.)
  String? selectedRideCategory = 'pro';
  // Vehicle type form (Tab 1)
  FocusNode? typeNameFocusNode;
  TextEditingController? typeNameTextController;
  String? Function(BuildContext, String?)? typeNameTextControllerValidator;
  bool isDataUploading_typeImage = false;
  FFUploadedFile uploadedLocalFile_typeImage =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  // State field(s) for seatingCapacity widget.
  FocusNode? seatingCapacityFocusNode;
  TextEditingController? seatingCapacityTextController;
  String? Function(BuildContext, String?)?
      seatingCapacityTextControllerValidator;
  // State field(s) for luggageCapacity widget.
  FocusNode? luggageCapacityFocusNode;
  TextEditingController? luggageCapacityTextController;
  String? Function(BuildContext, String?)?
      luggageCapacityTextControllerValidator;
  bool isDataUploading_uploadDataTws = false;
  FFUploadedFile uploadedLocalFile_uploadDataTws =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');

  // State field(s) for Switch widget.
  bool? switchValue;
  // Stores action output result for [Backend Call - API (addVehicle)] action in Button widget.
  ApiCallResponse? apiResult9zt;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    vehicleNameFocusNode?.dispose();
    vehicleNameTextController?.dispose();

    vehicleTypeFocusNode?.dispose();
    vehicleTypeTextController?.dispose();

    typeNameFocusNode?.dispose();
    typeNameTextController?.dispose();

    seatingCapacityFocusNode?.dispose();
    seatingCapacityTextController?.dispose();

    luggageCapacityFocusNode?.dispose();
    luggageCapacityTextController?.dispose();
  }
}
