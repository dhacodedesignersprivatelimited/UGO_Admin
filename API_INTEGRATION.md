# UGO Admin - API Integration Guide

## Base URL Configuration

Edit `lib/backend/api_requests/api_config.dart`:
- **Production:** `https://ugotaxi.icacorp.org` (default)
- **Alternate:** `https://ugotaxi.icacorp.org` (Postman collection)
- **Local Dev:** `http://localhost:5001` or `http://10.0.2.2:5001` (Android emulator)

---

## ✅ APIs INTEGRATED (Postman Collection)

### 1. Auth (Public)
| API | Method | Path | Call Class |
|-----|--------|------|------------|
| Admin Login | POST | `/api/admins/login` | `LoginCall` |
| Refresh Token | POST | `/api/admins/refresh-token` | `RefreshTokenCall` |

### 2. Profile & Admins
| API | Method | Path | Call Class |
|-----|--------|------|------------|
| Get Profile | GET | `/api/admins/profile` | `GetProfileCall` |
| Get All Admins | GET | `/api/admins/getadmins` | `GetAllAdminsCall` |
| Create Admin | POST | `/api/admins/post` | `CreateAdminCall` (with `role`) |

### 3. Dashboard & Analytics
| API | Method | Path | Call Class |
|-----|--------|------|------------|
| Dashboard Overview | GET | `/api/admins/dashboard` | `DashBoardCall` |
| Rides Analytics | GET | `/api/admins/rides-analytics` | `GetRidersCall`, `RidesAnalyticsCall` |
| Earnings Analytics | GET | `/api/admins/earnings-analytics` | `GetAnalyticsCall`, `EarningsAnalyticsCall` |
| Active Drivers | GET | `/api/admins/active-drivers` | `ActiveDriversCall` |

### 4. Users
| API | Method | Path | Call Class |
|-----|--------|------|------------|
| All Users | GET | `/api/admins/all-users` | `AllUsersCall` |
| Blocked Users | GET | `/api/admins/blocked-users` | `BlockedUsersCall` |
| Block User | POST | `/api/admins/block-user` | `BlockUserCall` (`user_id`, `reason_for_blocking`) |
| Unblock User | POST | `/api/admins/unblock-user` | `UnblockUserCall` (`user_id`) |

### 5. Vehicles
| API | Method | Path | Call Class |
|-----|--------|------|------------|
| Add Vehicle | POST | `/api/admins/vehicles` | `AddVehicleCall` |
| Get All Vehicles | GET | `/api/admins/vehicles` | `GetAllVehiclesCall` |

### 6. KYC & Documents
| API | Method | Path | Call Class |
|-----|--------|------|------------|
| KYC Pending | GET | `/api/admins/kyc-pending` | `KycPendingCall` |
| Verify Driver Documents | POST | `/api/admins/verify-driver-documents` | `VerifyDocsCall` |
| Verify Driver License | POST | `/api/admins/verify-driver-license` | `VerifyDriverLicenseCall` |

### 7. Drivers
| API | Method | Path | Call Class |
|-----|--------|------|------------|
| Get All Drivers | GET | `/api/drivers/getall` | `GetDriversCall` |
| Get Driver By ID | GET | `/api/drivers/:id` | `GetDriverByIdCall` |

### 8. Rides
| API | Method | Path | Call Class |
|-----|--------|------|------------|
| Get All Rides | GET | `/api/rides/getall` | `GetRidesCall` ✅ **Ride Management** |
| Get Ride By ID | GET | `/api/rides/:id` | `GetRideByIdCall` |

### 9. Payments
| API | Method | Path | Call Class |
|-----|--------|------|------------|
| Get All Payments | GET | `/api/payments/getall` | `GetPaymentsCall` |

### 10. Wallets
| API | Method | Path | Call Class |
|-----|--------|------|------------|
| Get All Wallets | GET | `/api/wallets/getall` | `GetWalletsCall` |

### 11. Admin Finance
| API | Method | Path | Call Class |
|-----|--------|------|------------|
| Company Wallet | GET | `/api/admin-finance/company-wallet` | `CompanyWalletCall` |
| Commissions | GET | `/api/admin-finance/commissions` | `GetCommissionsCall` |
| Get Finance Settings | GET | `/api/admin-finance/get/finance-settings` | `GetFinanceSettingsCall` |
| Update Finance Settings | PUT | `/api/admin-finance/finance-settings` | `UpdateFinanceSettingsCall` |

### 12. Promo Codes
| API | Method | Path | Call Class |
|-----|--------|------|------------|
| Get Promo Codes | GET | `/api/admins/promo-codes` | `GetPromoCodesCall` |
| Add Promo Code | POST | `/api/admins/promo-codes` | `AddPromoCodeCall` |
| Deactivate Promo | PATCH | `/api/admins/promo-codes/deactivate` | `DeactivatePromoCodeCall` |

### 13. Support & Complaints
| API | Method | Path | Call Class |
|-----|--------|------|------------|
| Get Support Tickets | GET | `/api/admins/support-tickets` | `GetSupportTicketsCall` |
| Get Complaints | GET | `/api/admins/complaints` | `GetComplaintsCall` |

### 14. Notifications
| API | Method | Path | Call Class |
|-----|--------|------|------------|
| Send Broadcast | POST | `/api/admins/notifications/send` | `SendBroadcastNotificationCall` |

---

## ❌ APIs IN POSTMAN NOT YET IN APP

| API | Method | Path | Notes |
|-----|--------|------|-------|
| Get Admin By ID | GET | `/api/admins/:id` | |
| Update Admin | PUT | `/api/admins/:id` | |
| Update Profile | PATCH | `/api/admins/update-profile` | |
| Update Settings | PATCH | `/api/admins/settings` | |
| Delete Admin | DELETE | `/api/admins/:id` | |
| Revenue Analytics | GET | `/api/admins/revenue-analytics` | |
| Driver Performance | GET | `/api/admins/driver-performance` | |
| System Reports | GET | `/api/admins/system-reports` | |
| Financial Reports | GET | `/api/admins/financial-reports` | |
| Respond Support Ticket | POST | `/api/admins/support-tickets/respond` | |
| Update Complaint Status | PATCH | `/api/admins/complaints/update` | |
| Create Ride | POST | `/api/rides/post` | Admin-created ride |
| Cancel Ride | PATCH | `/api/rides/rides/cancel` | |
| Update Ride | PUT | `/api/rides/:id` | |
| Pricing Set | POST | `/api/pricing/set` | |
| Vehicle Types Add | POST | `/api/vehicle-types/add` | |
| User Ride History | GET | `/api/users/ride-history/:userId` | |
| Ratings (user/driver) | GET | `/api/ratings/user/:id`, `/api/ratings/driver/:id` | |
| QR Codes | GET/POST | `/api/qr-codes/*` | |
| Referrals | Various | `/api/referrals/*` | |
| Location APIs | GET | `/api/location/*` | |
| Analytics | GET | `/api/analytics/*` | |

---

## 📁 Files

- **`api_config.dart`** – Base URL
- **`api_calls.dart`** – All integrated API calls
- **`api_calls_admin.dart`** – Empty (APIs merged into api_calls.dart)

---

## Example Usage

```dart
import '/backend/api_requests/api_calls.dart';
import '/auth/custom_auth/auth_util.dart';

// Get rides (Ride Management page)
final response = await GetRidesCall.call(token: currentAuthenticationToken);
final rides = GetRidesCall.data(response.jsonBody);

// Block user
await BlockUserCall.call(
  token: currentAuthenticationToken,
  userId: 123,
  reasonForBlocking: 'Violation',
);

// Add promo code
await AddPromoCodeCall.call(
  token: currentAuthenticationToken,
  codeName: 'NEWUSER50',
  discountType: 'percentage',
  discountValue: 50,
  maxDiscountAmount: 150,
  expiryDate: '2025-12-31',
  usageLimit: 1000,
);
```
