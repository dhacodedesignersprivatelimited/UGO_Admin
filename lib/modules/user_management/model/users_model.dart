import 'package:equatable/equatable.dart';

import '/shared/models/domain_enums.dart';

class RiderWallet extends Equatable {
  const RiderWallet({
    required this.balance,
    required this.currency,
  });

  final double balance;
  final String currency;

  @override
  List<Object?> get props => [balance, currency];
}

class RiderProfile extends Equatable {
  const RiderProfile({
    required this.id,
    required this.displayName,
    required this.phone,
    required this.email,
    required this.wallet,
    required this.isBlocked,
    required this.completedRides,
    this.avatarUrl,
  });

  final String id;
  final String displayName;
  final String phone;
  final String email;
  final RiderWallet wallet;
  final bool isBlocked;
  final int completedRides;
  final String? avatarUrl;

  @override
  List<Object?> get props =>
      [id, displayName, phone, email, wallet, isBlocked, completedRides, avatarUrl];
}

class RiderListItem extends Equatable {
  const RiderListItem({
    required this.id,
    required this.displayName,
    required this.phone,
    required this.isBlocked,
    required this.walletBalance,
  });

  final String id;
  final String displayName;
  final String phone;
  final bool isBlocked;
  final double walletBalance;

  @override
  List<Object?> get props => [id, displayName, phone, isBlocked, walletBalance];
}

class RiderComplaint extends Equatable {
  const RiderComplaint({
    required this.id,
    required this.riderId,
    required this.subject,
    required this.body,
    required this.status,
    required this.createdAt,
    this.rideId,
  });

  final String id;
  final String riderId;
  final String subject;
  final String body;
  final ComplaintStatus status;
  final DateTime createdAt;
  final String? rideId;

  @override
  List<Object?> get props =>
      [id, riderId, subject, body, status, createdAt, rideId];
}
