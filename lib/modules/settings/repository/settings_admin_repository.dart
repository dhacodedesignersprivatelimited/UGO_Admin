import '/core/network/admin_api_contract.dart';
import '/modules/notifications/model/notifications_model.dart';
import '/modules/settings/model/settings_model.dart';

class SettingsAdminRepository {
  SettingsAdminRepository(this._api);

  final AdminApiContract _api;

  Future<GlobalSettingsSnapshot> globalSettings() => _api.getGlobalSettings();

  Future<void> saveFare(FareSettings settings) => _api.updateFareSettings(settings);

  Future<List<AdminNotificationJob>> notificationJobs() => _api.listNotificationJobs();

  Future<void> enqueueNotification(AdminNotificationDraft draft) =>
      _api.enqueueNotification(draft);
}
