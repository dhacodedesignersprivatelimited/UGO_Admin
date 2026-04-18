import '../api/admin_api_contract.dart';
import '../models/domain_enums.dart';
import '../models/promo_models.dart';
import '../models/rider_models.dart';

class UserAdminRepository {
  UserAdminRepository(this._api);

  final AdminApiContract _api;

  Future<List<RiderListItem>> listRiders({String? query}) =>
      _api.listRiders(query: query);

  Future<RiderProfile> getRider(String id) => _api.getRider(id);

  Future<void> setBlocked(String riderId, bool blocked) =>
      _api.setRiderBlocked(riderId, blocked);

  Future<List<RiderComplaint>> complaints({ComplaintStatus? status}) =>
      _api.listComplaints(status: status);

  Future<void> updateComplaint(String id, ComplaintStatus status) =>
      _api.updateComplaintStatus(id, status);

  Future<List<PromoCode>> promoCodes() => _api.listPromoCodes();
}
