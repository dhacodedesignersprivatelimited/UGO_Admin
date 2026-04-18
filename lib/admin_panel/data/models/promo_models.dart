import 'package:equatable/equatable.dart';

import 'domain_enums.dart';

class PromoCode extends Equatable {
  const PromoCode({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.maxRedemptions,
    required this.redemptionsUsed,
    required this.startsAt,
    required this.endsAt,
    required this.isActive,
  });

  final String id;
  final String code;
  final PromoDiscountType discountType;
  final double discountValue;
  final int maxRedemptions;
  final int redemptionsUsed;
  final DateTime startsAt;
  final DateTime endsAt;
  final bool isActive;

  @override
  List<Object?> get props => [
        id,
        code,
        discountType,
        discountValue,
        maxRedemptions,
        redemptionsUsed,
        startsAt,
        endsAt,
        isActive,
      ];
}
