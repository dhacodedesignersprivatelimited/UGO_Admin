import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/auth/auth_util.dart';
import '/core/network/api_calls.dart';
import '/modules/promo_codes/model/promo_codes_model.dart';
import '/shared/models/domain_enums.dart';
import '/core/utils/view_state.dart';
import 'promo_codes_state.dart';

export 'promo_codes_state.dart';

/// ViewModel for the promo-codes management screen.
class PromoCodesViewModel extends StateNotifier<PromoCodesState> {
  PromoCodesViewModel() : super(const PromoCodesState());

  Future<void> refresh() async {
    state = state.copyWith(status: LoadStatus.loading, clearError: true);
    try {
      final token = currentAuthenticationToken ?? '';
      final res = await GetPromoCodesCall.call(token: token);
      final rawList = (res.jsonBody as List? ??
          (res.jsonBody is Map ? (res.jsonBody['data'] as List? ?? []) : []));
      final codes = rawList.map((e) {
        final m = e as Map<String, dynamic>;
        return PromoCode(
          id: m['id']?.toString() ?? '',
          code: m['code_name']?.toString() ?? m['code']?.toString() ?? '',
          discountType: (m['discount_type']?.toString() ?? '').contains('fixed')
              ? PromoDiscountType.fixedAmount
              : PromoDiscountType.percentage,
          discountValue: (m['discount_value'] as num?)?.toDouble() ?? 0.0,
          maxRedemptions: (m['usage_limit'] as num?)?.toInt() ?? 0,
          redemptionsUsed: (m['used_count'] as num?)?.toInt() ?? 0,
          startsAt: DateTime.tryParse(m['created_at']?.toString() ?? '') ?? DateTime.now(),
          endsAt: DateTime.tryParse(m['expiry_date']?.toString() ?? '') ?? DateTime.now().add(const Duration(days: 30)),
          isActive: m['is_active'] as bool? ?? true,
        );
      }).toList();
      state = state.copyWith(
        status: LoadStatus.success,
        codes: codes,
      );
    } catch (e) {
      state = state.copyWith(
          status: LoadStatus.failure, errorMessage: e.toString());
    }
  }

  Future<void> createCode(Map<String, dynamic> data) async {
    final token = currentAuthenticationToken ?? '';
    await AddPromoCodeCall.call(
      token: token,
      codeName: data['code_name']?.toString(),
      discountType: data['discount_type']?.toString(),
      discountValue: (data['discount_value'] as num?)?.toDouble(),
      maxDiscountAmount: (data['max_discount_amount'] as num?)?.toDouble(),
      expiryDate: data['expiry_date']?.toString(),
      usageLimit: data['usage_limit'] as int?,
    );
    await refresh();
  }

  Future<void> deleteCode(String id) async {
    final token = currentAuthenticationToken ?? '';
    await DeactivatePromoCodeCall.call(token: token, promoId: int.tryParse(id) ?? 0);
    await refresh();
  }
}

/// Global promo codes ViewModel provider.
final promoCodesViewModelProvider =
    StateNotifierProvider<PromoCodesViewModel, PromoCodesState>(
  (_) => PromoCodesViewModel(),
);
