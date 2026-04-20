import 'notifications_widget.dart' show NotificationsWidget;
import 'package:flutter/material.dart';
import '/config/theme/flutter_flow_util.dart';
import '/config/theme/form_field_controller.dart';

class NotificationsModel extends FlutterFlowModel<NotificationsWidget> {
  FocusNode? titleFocusNode;
  TextEditingController? titleTextController;
  String? Function(BuildContext, String?)? titleTextControllerValidator;

  FocusNode? messageFocusNode;
  TextEditingController? messageTextController;
  String? Function(BuildContext, String?)? messageTextControllerValidator;

  FormFieldController<List<String>>? choiceChipsValueController;
  String? get choiceChipsValue =>
      choiceChipsValueController?.value?.firstOrNull;
  set choiceChipsValue(String? val) =>
      choiceChipsValueController?.value = val != null ? [val] : [];

  String? selectedPriority = 'high';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    titleFocusNode?.dispose();
    titleTextController?.dispose();
    messageFocusNode?.dispose();
    messageTextController?.dispose();
  }
}
