import '/core/network/admin_api_contract.dart';
import '/shared/models/domain_enums.dart';
import '/modules/finance_management/model/finance_model.dart';

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
