import 'add_user_widget.dart' show AddUserWidget;
import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AddUserModel extends FlutterFlowModel<AddUserWidget> {
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
  String? Function(BuildContext, String?)? fcmTokenTextControllerValidator;

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
  }
}
