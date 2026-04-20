import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';
import '/shared/widgets/admin_drawer.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';
import '/config/theme/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'account_widget.dart' show AccountWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AccountModel extends FlutterFlowModel<AccountWidget> {
  /// State fields for stateful widgets in this page.

  // Stores action output result for fetching Admin Profile via API
  ApiCallResponse? profileResponse;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}