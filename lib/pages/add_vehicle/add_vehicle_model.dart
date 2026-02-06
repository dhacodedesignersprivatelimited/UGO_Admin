import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import 'dart:ui';
import 'add_vehicle_widget.dart' show AddVehicleWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddVehicleModel extends FlutterFlowModel<AddVehicleWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for vehicleName widget.
  FocusNode? vehicleNameFocusNode;
  TextEditingController? vehicleNameTextController;
  String? Function(BuildContext, String?)? vehicleNameTextControllerValidator;
  // State field(s) for vehicleType widget.
  FocusNode? vehicleTypeFocusNode;
  TextEditingController? vehicleTypeTextController;
  String? Function(BuildContext, String?)? vehicleTypeTextControllerValidator;
  // State field(s) for priceperkm widget.
  FocusNode? priceperkmFocusNode;
  TextEditingController? priceperkmTextController;
  String? Function(BuildContext, String?)? priceperkmTextControllerValidator;
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

    priceperkmFocusNode?.dispose();
    priceperkmTextController?.dispose();

    seatingCapacityFocusNode?.dispose();
    seatingCapacityTextController?.dispose();

    luggageCapacityFocusNode?.dispose();
    luggageCapacityTextController?.dispose();
  }
}
