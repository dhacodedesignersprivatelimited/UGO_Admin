import 'package:equatable/equatable.dart';

import 'domain_enums.dart';
import 'vehicle_models.dart';

class DriverKycDocument extends Equatable {
  const DriverKycDocument({
    required this.id,
    required this.label,
    required this.fileUrl,
    required this.status,
    this.reviewerNote,
  });

  final String id;
  final String label;
  final String fileUrl;
  final KycReviewStatus status;
  final String? reviewerNote;

  @override
  List<Object?> get props => [id, label, fileUrl, status, reviewerNote];
}

class DriverWalletSummary extends Equatable {
  const DriverWalletSummary({
    required this.balance,
    required this.pendingWithdrawals,
    required this.lifetimeEarnings,
  });

  final double balance;
  final double pendingWithdrawals;
  final double lifetimeEarnings;

  @override
  List<Object?> get props => [balance, pendingWithdrawals, lifetimeEarnings];
}

class DriverProfile extends Equatable {
  const DriverProfile({
    required this.id,
    required this.displayName,
    required this.phone,
    required this.email,
    required this.city,
    required this.presence,
    required this.kycStatus,
    required this.vehicle,
    required this.wallet,
    required this.rating,
    required this.completedRides,
    this.avatarUrl,
  });

  final String id;
  final String displayName;
  final String phone;
  final String email;
  final String city;
  final DriverPresenceStatus presence;
  final KycReviewStatus kycStatus;
  final DriverVehicle vehicle;
  final DriverWalletSummary wallet;
  final double rating;
  final int completedRides;
  final String? avatarUrl;

  @override
  List<Object?> get props => [
        id,
        displayName,
        phone,
        email,
        city,
        presence,
        kycStatus,
        vehicle,
        wallet,
        rating,
        completedRides,
        avatarUrl,
      ];
}

class DriverListItem extends Equatable {
  const DriverListItem({
    required this.id,
    required this.displayName,
    required this.phone,
    required this.presence,
    required this.kycStatus,
    required this.vehicleLabel,
    required this.rating,
  });

  final String id;
  final String displayName;
  final String phone;
  final DriverPresenceStatus presence;
  final KycReviewStatus kycStatus;
  final String vehicleLabel;
  final double rating;

  @override
  List<Object?> get props =>
      [id, displayName, phone, presence, kycStatus, vehicleLabel, rating];
}

class DriverEarningsPoint extends Equatable {
  const DriverEarningsPoint({
    required this.day,
    required this.amount,
  });

  final DateTime day;
  final double amount;

  @override
  List<Object?> get props => [day, amount];
}
