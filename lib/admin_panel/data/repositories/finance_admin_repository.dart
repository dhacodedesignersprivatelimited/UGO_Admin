import '../api/admin_api_contract.dart';
import '../models/domain_enums.dart';
import '../models/finance_models.dart';

class FinanceAdminRepository {
  FinanceAdminRepository(this._api);

  final AdminApiContract _api;

  Future<List<WithdrawalRequest>> withdrawals({WithdrawalStatus? status}) =>
      _api.listWithdrawals(status: status);

  Future<void> decideWithdrawal({
    required String id,
    required WithdrawalStatus decision,
  }) =>
      _api.decideWithdrawal(id: id, decision: decision);
}
