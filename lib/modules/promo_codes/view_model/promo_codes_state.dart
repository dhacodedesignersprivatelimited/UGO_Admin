import 'package:equatable/equatable.dart';
import '/core/utils/view_state.dart';
import '/modules/promo_codes/model/promo_codes_model.dart';

class PromoCodesState extends Equatable with LoadStateMixin {
  const PromoCodesState({
    this.status = LoadStatus.initial,
    this.errorMessage,
    this.codes = const [],
  });

  @override
  final LoadStatus status;
  @override
  final String? errorMessage;
  final List<PromoCode> codes;

  PromoCodesState copyWith({
    LoadStatus? status,
    String? errorMessage,
    bool clearError = false,
    List<PromoCode>? codes,
  }) =>
      PromoCodesState(
        status: status ?? this.status,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        codes: codes ?? this.codes,
      );

  @override
  List<Object?> get props => [status, errorMessage, codes];
}
