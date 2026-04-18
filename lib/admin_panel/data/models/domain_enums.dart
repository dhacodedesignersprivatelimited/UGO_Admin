enum DriverPresenceStatus { online, offline, blocked }

enum KycReviewStatus { pending, approved, rejected }

enum RideLifecycleStatus {
  requested,
  assigned,
  arrived,
  inProgress,
  completed,
  cancelledByRider,
  cancelledByDriver,
  cancelledByAdmin,
}

enum WithdrawalStatus { pending, approved, rejected, paid }

enum ComplaintStatus { open, inReview, resolved, escalated }

enum PromoDiscountType { percentage, fixedAmount }
