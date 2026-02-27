import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'sub_admins_widget.dart' show SubAdminsWidget;

class SubAdminsModel extends FlutterFlowModel<SubAdminsWidget> {
  FocusNode? adminNameFocusNode;
  TextEditingController? adminNameTextController;
  FocusNode? emailFocusNode;
  TextEditingController? emailTextController;
  FocusNode? passwordFocusNode;
  TextEditingController? passwordTextController;
  String? selectedRole = 'MANAGER';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    adminNameFocusNode?.dispose();
    adminNameTextController?.dispose();
    emailFocusNode?.dispose();
    emailTextController?.dispose();
    passwordFocusNode?.dispose();
    passwordTextController?.dispose();
  }
}
