import '/auth/custom_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'driver_license_widget.dart' show DriverLicenseWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DriverLicenseModel extends FlutterFlowModel<DriverLicenseWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GetDriverById)] action in DriverLicense widget.
  ApiCallResponse? getdriverid;
  // Stores action output result for [Backend Call - API (verifyDocs)] action in Button widget.
  ApiCallResponse? apiResultmsc;
  // Stores action output result for [Backend Call - API (verifyDocs)] action in Button widget.
  ApiCallResponse? kycRejected;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
