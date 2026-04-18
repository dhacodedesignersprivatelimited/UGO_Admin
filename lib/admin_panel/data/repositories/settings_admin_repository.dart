import '../api/admin_api_contract.dart';
import '../models/notification_models.dart';
import '../models/settings_models.dart';

class SettingsAdminRepository {
  SettingsAdminRepository(this._api);

  final AdminApiContract _api;

  Future<GlobalSettingsSnapshot> globalSettings() => _api.getGlobalSettings();

  Future<void> saveFare(FareSettings settings) => _api.updateFareSettings(settings);

  Future<List<AdminNotificationJob>> notificationJobs() => _api.listNotificationJobs();

  Future<void> enqueueNotification(AdminNotificationDraft draft) =>
      _api.enqueueNotification(draft);
}
