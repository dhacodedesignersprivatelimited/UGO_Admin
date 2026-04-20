import 'package:equatable/equatable.dart';
import '/core/utils/view_state.dart';
import '/modules/settings/model/settings_model.dart';

class SettingsState extends Equatable with LoadStateMixin {
  const SettingsState({
    this.status = LoadStatus.initial,
    this.errorMessage,
    this.snapshot,
  });

  @override
  final LoadStatus status;
  @override
  final String? errorMessage;
  final GlobalSettingsSnapshot? snapshot;

  SettingsState copyWith({
    LoadStatus? status,
    String? errorMessage,
    bool clearError = false,
    GlobalSettingsSnapshot? snapshot,
  }) =>
      SettingsState(
        status: status ?? this.status,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        snapshot: snapshot ?? this.snapshot,
      );

  @override
  List<Object?> get props => [status, errorMessage, snapshot];
}
