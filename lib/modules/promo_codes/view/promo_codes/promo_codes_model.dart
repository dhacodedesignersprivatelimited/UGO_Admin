import 'promo_codes_widget.dart' show PromoCodesWidget;
import 'package:flutter/material.dart';
import '/config/theme/flutter_flow_util.dart';

class PromoCodesModel extends FlutterFlowModel<PromoCodesWidget> {
  FocusNode? codeNameFocusNode;
  TextEditingController? codeNameTextController;
  String? Function(BuildContext, String?)? codeNameTextControllerValidator;

  FocusNode? discountValueFocusNode;
  TextEditingController? discountValueTextController;
  String? Function(BuildContext, String?)? discountValueTextControllerValidator;

  FocusNode? maxDiscountFocusNode;
  TextEditingController? maxDiscountTextController;
  String? Function(BuildContext, String?)? maxDiscountTextControllerValidator;

  FocusNode? expiryDateFocusNode;
  TextEditingController? expiryDateTextController;
  String? Function(BuildContext, String?)? expiryDateTextControllerValidator;

  FocusNode? usageLimitFocusNode;
  TextEditingController? usageLimitTextController;
  String? Function(BuildContext, String?)? usageLimitTextControllerValidator;

  String? selectedDiscountType = 'percentage';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    codeNameFocusNode?.dispose();
    codeNameTextController?.dispose();
    discountValueFocusNode?.dispose();
    discountValueTextController?.dispose();
    maxDiscountFocusNode?.dispose();
    maxDiscountTextController?.dispose();
    expiryDateFocusNode?.dispose();
    expiryDateTextController?.dispose();
    usageLimitFocusNode?.dispose();
    usageLimitTextController?.dispose();
  }
}
