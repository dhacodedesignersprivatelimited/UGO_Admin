import 'allusers_widget.dart' show AllusersWidget;
import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AllusersModel extends FlutterFlowModel<AllusersWidget> {
  /// All pending KYC driver IDs (no page limit)
  List<int> pendingKycDriverIds = [];

  /// Full list of pending KYC drivers for display
  List<dynamic> pendingKycDrivers = [];

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
