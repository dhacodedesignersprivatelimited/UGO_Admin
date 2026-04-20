import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/modules/settings/model/settings_model.dart';
import '/modules/settings/repository/settings_admin_repository.dart';
import '/shared/providers/app_providers.dart';
import '/core/utils/view_state.dart';
import 'settings_state.dart';

export 'settings_state.dart';

/// ViewModel for the global app-settings screen.
class SettingsViewModel extends StateNotifier<SettingsState> {
  SettingsViewModel(this._repo) : super(const SettingsState());

  final SettingsAdminRepository _repo;

  Future<void> refresh() async {
    state = state.copyWith(status: LoadStatus.loading, clearError: true);
    try {
      final snapshot = await _repo.globalSettings();
      state = state.copyWith(status: LoadStatus.success, snapshot: snapshot);
    } catch (e) {
      state = state.copyWith(
          status: LoadStatus.failure, errorMessage: e.toString());
    }
  }

  Future<void> saveFareSettings(FareSettings fareData) async {
    state = state.copyWith(status: LoadStatus.loading, clearError: true);
    try {
      await _repo.saveFare(fareData);
      await refresh();
    } catch (e) {
      state = state.copyWith(
          status: LoadStatus.failure, errorMessage: e.toString());
    }
  }
}

final _settingsRepoProvider = Provider<SettingsAdminRepository>((ref) {
  return ref.watch(adminDepsProvider).settings;
});

/// Global settings ViewModel provider.
final settingsViewModelProvider =
    StateNotifierProvider<SettingsViewModel, SettingsState>((ref) {
  return SettingsViewModel(ref.watch(_settingsRepoProvider));
});
