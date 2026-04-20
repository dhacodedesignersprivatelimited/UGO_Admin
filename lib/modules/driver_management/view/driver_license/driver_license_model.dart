import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';
import '/config/theme/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'driver_license_widget.dart' show DriverLicenseWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DriverLicenseModel extends FlutterFlowModel<DriverLicenseWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (getDriverById)] action.
  ApiCallResponse? getdriverid;

  // Stores action output result for [Backend Call - API (verifyDocs)] for Approve.
  ApiCallResponse? apiResultmsc;

  // Stores action output result for [Backend Call - API (verifyDocs)] for Reject.
  ApiCallResponse? kycRejected;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}