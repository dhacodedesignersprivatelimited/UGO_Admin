import 'package:equatable/equatable.dart';

import '/shared/models/domain_enums.dart';

class WithdrawalRequest extends Equatable {
  const WithdrawalRequest({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.amount,
    required this.status,
    required this.requestedAt,
    this.bankMasked,
  });

  final String id;
  final String driverId;
  final String driverName;
  final double amount;
  final WithdrawalStatus status;
  final DateTime requestedAt;
  final String? bankMasked;

  @override
  List<Object?> get props =>
      [id, driverId, driverName, amount, status, requestedAt, bankMasked];
}

class WalletLedgerEntry extends Equatable {
  const WalletLedgerEntry({
    required this.id,
    required this.ownerId,
    required this.ownerKind,
    required this.amount,
    required this.label,
    required this.createdAt,
  });

  final String id;
  final String ownerId;
  final String ownerKind;
  final double amount;
  final String label;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, ownerId, ownerKind, amount, label, createdAt];
}
