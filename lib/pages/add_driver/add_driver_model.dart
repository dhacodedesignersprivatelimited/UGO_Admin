import 'dart:typed_data';

import 'add_driver_widget.dart' show AddDriverWidget;
import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/uploaded_file.dart';

class AddDriverModel extends FlutterFlowModel<AddDriverWidget> {
  List<Map<String, dynamic>> vehicleTypesList = [];
  bool isLoadingVehicleTypes = false;
  int? selectedVehicleTypeId;

  // Document uploads
  FFUploadedFile profileImage =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  FFUploadedFile licenseFrontImage =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  FFUploadedFile licenseBackImage =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  FFUploadedFile aadhaarFrontImage =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  FFUploadedFile aadhaarBackImage =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  FFUploadedFile panImage =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  FFUploadedFile rcFrontImage =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  FFUploadedFile rcBackImage =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  FFUploadedFile vehicleImage =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  FFUploadedFile registrationImage =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  FFUploadedFile insuranceImage =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  FFUploadedFile pollutionCertificateImage =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  bool isUploadingDoc = false;

  FocusNode? mobileNumberFocusNode;
  TextEditingController? mobileNumberTextController;
  String? Function(BuildContext, String?)? mobileNumberTextControllerValidator;

  FocusNode? firstNameFocusNode;
  TextEditingController? firstNameTextController;
  String? Function(BuildContext, String?)? firstNameTextControllerValidator;

  FocusNode? lastNameFocusNode;
  TextEditingController? lastNameTextController;
  String? Function(BuildContext, String?)? lastNameTextControllerValidator;

  FocusNode? emailFocusNode;
  TextEditingController? emailTextController;
  String? Function(BuildContext, String?)? emailTextControllerValidator;

  FocusNode? fcmTokenFocusNode;
  TextEditingController? fcmTokenTextController;

  FocusNode? cityFocusNode;
  TextEditingController? cityTextController;

  FocusNode? stateFocusNode;
  TextEditingController? stateTextController;

  FocusNode? postalCodeFocusNode;
  TextEditingController? postalCodeTextController;

  FocusNode? referralCodeFocusNode;
  TextEditingController? referralCodeTextController;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    mobileNumberFocusNode?.dispose();
    mobileNumberTextController?.dispose();
    firstNameFocusNode?.dispose();
    firstNameTextController?.dispose();
    lastNameFocusNode?.dispose();
    lastNameTextController?.dispose();
    emailFocusNode?.dispose();
    emailTextController?.dispose();
    fcmTokenFocusNode?.dispose();
    fcmTokenTextController?.dispose();
    cityFocusNode?.dispose();
    cityTextController?.dispose();
    stateFocusNode?.dispose();
    stateTextController?.dispose();
    postalCodeFocusNode?.dispose();
    postalCodeTextController?.dispose();
    referralCodeFocusNode?.dispose();
    referralCodeTextController?.dispose();
  }
}
