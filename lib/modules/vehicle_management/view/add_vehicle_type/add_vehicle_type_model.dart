import 'dart:typed_data';

import '/config/theme/flutter_flow_util.dart';
import '/config/theme/uploaded_file.dart';
import 'add_vehicle_type_widget.dart' show AddVehicleTypeWidget;
import 'package:flutter/material.dart';

class AddVehicleTypeModel extends FlutterFlowModel<AddVehicleTypeWidget> {
  FocusNode? nameFocusNode;
  TextEditingController? nameTextController;
  String? Function(BuildContext, String?)? nameTextControllerValidator;

  bool isDataUploading = false;
  FFUploadedFile uploadedLocalFile =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    nameFocusNode?.dispose();
    nameTextController?.dispose();
  }
}
