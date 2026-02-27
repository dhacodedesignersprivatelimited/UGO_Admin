import 'dart:convert';

import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_config.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

class LoginCall {
  static Future<ApiCallResponse> call({
    String? email = '',
    String? password = '',
  }) async {
    final ffApiRequestBody = '''
{
  "email": "${escapeStringForJson(email)}",
  "password": "${escapeStringForJson(password)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'login',
      apiUrl: '${ApiConfig.apiBase}/admins/login',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static dynamic admin(dynamic response) => getJsonField(
        response,
        r'''$.data.admin''',
      );
  static String? accessToken(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data.accessToken''',
      ));
  static String? refreshtoken(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data.refreshToken''',
      ));
}

class AddVehicleTypeCall {
  /// POST /api/vehicle-types/add (form-data: name, image)
  static Future<ApiCallResponse> call({
    required String name,
    FFUploadedFile? image,
    String? token = '',
  }) async {
    final params = <String, dynamic>{'name': name};
    if (image != null && (image.bytes?.isNotEmpty ?? false)) {
      params['image'] = image;
    }
    return ApiManager.instance.makeApiCall(
      callName: 'addVehicleType',
      apiUrl: '${ApiConfig.apiBase}/vehicle-types/add',
      callType: ApiCallType.POST,
      headers: {
        if ((token ?? '').isNotEmpty) 'Authorization': 'Bearer $token',
      },
      params: params,
      bodyType: BodyType.MULTIPART,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static Map<String, dynamic>? data(dynamic response) =>
      getJsonField(response, r'''$.data''') as Map<String, dynamic>?;
}

class AddVehicleCall {
  /// POST /api/admins/vehicles - multipart form (matches Postman Create Vehicle)
  /// Params: vehicle_type_id, ride_category, vehicle_name, seating_capacity, luggage_capacity, vehicle_image
  static Future<ApiCallResponse> call({
    required int vehicleTypeId,
    String? rideCategory = '',
    String? vehicleName = '',
    String? seatingCapacity = '',
    String? luggageCapacity = '',
    FFUploadedFile? vehicleImage,
    String? token = '',
  }) async {
    final params = <String, dynamic>{
      'vehicle_type_id': vehicleTypeId.toString(),
      'ride_category': rideCategory ?? '',
      'vehicle_name': vehicleName ?? '',
      'seating_capacity': seatingCapacity ?? '',
      'luggage_capacity': luggageCapacity ?? '',
    };
    if (vehicleImage != null && (vehicleImage.bytes?.isNotEmpty ?? false)) {
      params['vehicle_image'] = vehicleImage;
    }
    return ApiManager.instance.makeApiCall(
      callName: 'addVehicle',
      apiUrl: '${ApiConfig.apiBase}/admins/vehicles',
      callType: ApiCallType.POST,
      headers: {
        if ((token ?? '').isNotEmpty) 'Authorization': 'Bearer $token',
      },
      params: params,
      bodyType: BodyType.MULTIPART,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetRidersCall {
  static Future<ApiCallResponse> call({
    String? token = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'GetRiders',
      apiUrl: '${ApiConfig.apiBase}/admins/rides-analytics',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static dynamic data(dynamic response) => getJsonField(
        response,
        r'''$.data''',
      );
  static int? totalrides(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.total_rides''',
      ));
}

class GetAnalyticsCall {
  static Future<ApiCallResponse> call({
    String? token = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'GetAnalytics',
      apiUrl:
          '${ApiConfig.apiBase}/admins/earnings-analytics?period=weekly',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static dynamic data(dynamic response) => getJsonField(
        response,
        r'''$.data''',
      );
  static int? totalearnings(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.total_earnings''',
      ));
}

class ActiveDriversCall {
  static Future<ApiCallResponse> call({
    String? token = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'ActiveDrivers',
      apiUrl: '${ApiConfig.apiBase}/admins/active-drivers',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static dynamic data(dynamic response) => getJsonField(
        response,
        r'''$.data''',
      );
  static int? activedrivers(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.total''',
      ));
}

class AllUsersCall {
  static Future<ApiCallResponse> call({
    String? token = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'AllUsers',
      apiUrl: '${ApiConfig.apiBase}/admins/all-users',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static dynamic data(dynamic response) => getJsonField(
        response,
        r'''$.data''',
      );
  static int? userall(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.total''',
      ));
  static List? usersdata(dynamic response) => getJsonField(
        response,
        r'''$.data.users''',
        true,
      ) as List?;
  static List<int>? usersid(dynamic response) => (getJsonField(
        response,
        r'''$.data.users[:].user_id''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  static List<String>? usersname(dynamic response) => (getJsonField(
        response,
        r'''$.data.users[:].name''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

/// GET {{baseURL}}/api/users/:id - fetch user details by id
class GetUserByIdCall {
  static Future<ApiCallResponse> call({
    required int id,
    String? token = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getUserById',
      apiUrl: '${ApiConfig.apiBase}/users/$id',
      callType: ApiCallType.GET,
      headers: {
        if ((token ?? '').isNotEmpty) 'Authorization': 'Bearer $token',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static Map<String, dynamic>? data(dynamic response) =>
      getJsonField(response, r'''$.data''') as Map<String, dynamic>?;
}

/// POST {{baseURL}}/api/users/post - admin creates user
class CreateUserCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required String mobileNumber,
    required String firstName,
    required String lastName,
    required String email,
    String? fcmToken = '',
  }) async {
    final body = '''
{
  "mobile_number": "${escapeStringForJson(mobileNumber)}",
  "first_name": "${escapeStringForJson(firstName)}",
  "last_name": "${escapeStringForJson(lastName)}",
  "email": "${escapeStringForJson(email)}",
  "fcm_token": "${escapeStringForJson(fcmToken ?? '')}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'createUser',
      apiUrl: '${ApiConfig.apiBase}/users/post',
      callType: ApiCallType.POST,
      headers: {
        if ((token ?? '').isNotEmpty) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      params: {},
      body: body,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static Map<String, dynamic>? data(dynamic response) =>
      getJsonField(response, r'''$.data''') as Map<String, dynamic>?;
}

/// POST {{baseURL}}/api/drivers/signup-with-vehicle - multipart form
/// Params: driver (JSON), vehicle (JSON), fcm_token, + image uploads
class CreateDriverCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required Map<String, dynamic> driver,
    required Map<String, dynamic> vehicle,
    String? fcmToken = '',
    FFUploadedFile? profileImage,
    FFUploadedFile? licenseImage,
    FFUploadedFile? licenseFrontImage,
    FFUploadedFile? licenseBackImage,
    FFUploadedFile? aadhaarImage,
    FFUploadedFile? aadhaarFrontImage,
    FFUploadedFile? aadhaarBackImage,
    FFUploadedFile? panImage,
    FFUploadedFile? rcFrontImage,
    FFUploadedFile? rcBackImage,
    FFUploadedFile? vehicleImage,
    FFUploadedFile? registrationImage,
    FFUploadedFile? insuranceImage,
    FFUploadedFile? pollutionCertificateImage,
  }) async {
    final params = <String, dynamic>{
      'driver': json.encode(driver),
      'vehicle': json.encode(vehicle),
      'fcm_token': fcmToken ?? '',
    };
    void addFile(String key, FFUploadedFile? file) {
      if (file != null && (file.bytes?.isNotEmpty ?? false)) {
        params[key] = file;
      }
    }
    addFile('profile_image', profileImage);
    addFile('license_image', licenseImage);
    addFile('license_front_image', licenseFrontImage);
    addFile('license_back_image', licenseBackImage);
    addFile('aadhaar_image', aadhaarImage);
    addFile('aadhaar_front_image', aadhaarFrontImage);
    addFile('aadhaar_back_image', aadhaarBackImage);
    addFile('pan_image', panImage);
    addFile('rc_front_image', rcFrontImage);
    addFile('rc_back_image', rcBackImage);
    addFile('vehicle_image', vehicleImage);
    addFile('registration_image', registrationImage);
    addFile('insurance_image', insuranceImage);
    addFile('pollution_certificate_image', pollutionCertificateImage);

    return ApiManager.instance.makeApiCall(
      callName: 'createDriver',
      apiUrl: '${ApiConfig.apiBase}/drivers/signup-with-vehicle',
      callType: ApiCallType.POST,
      headers: {
        if ((token ?? '').isNotEmpty) 'Authorization': 'Bearer $token',
      },
      params: params,
      bodyType: BodyType.MULTIPART,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static Map<String, dynamic>? data(dynamic response) =>
      getJsonField(response, r'''$.data''') as Map<String, dynamic>?;
}

class GetDriversCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    int? userid,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'get drivers',
      apiUrl: '${ApiConfig.apiBase}/drivers/getall',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List? data(dynamic response) => getJsonField(
        response,
        r'''$.data''',
        true,
      ) as List?;
  static List<int>? id(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].id''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
}

class VerifyDocsCall {
  /// POST {{baseURL}}/api/admins/verify-driver-documents
  /// Body: { driver_id, verification_status, notes }
  /// Response: { success, data: { driver_id, kyc_status, kyc_approved_date } }
  static Future<ApiCallResponse> call({
    int? driverId,
    String? verificationStatus = 'approved',
    String? notes,
    String? token = '',
  }) async {
    final status = verificationStatus ?? 'approved';
    final defaultNotes = status.toLowerCase() == 'approved'
        ? 'All documents verified'
        : 'Documents rejected';
    final ffApiRequestBody = '''
{
  "driver_id": $driverId,
  "verification_status": "${escapeStringForJson(status)}",
  "notes": "${escapeStringForJson(notes ?? defaultNotes)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'verifyDocs',
      apiUrl: '${ApiConfig.apiBase}/admins/verify-driver-documents',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static Map<String, dynamic>? data(dynamic response) =>
      getJsonField(response, r'''$.data''') as Map<String, dynamic>?;
  static String? kycStatus(dynamic response) =>
      getJsonField(response, r'''$.data.kyc_status''')?.toString();
  static String? kycApprovedDate(dynamic response) =>
      getJsonField(response, r'''$.data.kyc_approved_date''')?.toString();
}

class DashBoardCall {
  static Future<ApiCallResponse> call({
    String? token = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'dashBoard',
      apiUrl: '${ApiConfig.apiBase}/admins/dashboard',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static dynamic totalRides(dynamic response) => getJsonField(
        response,
        r'''$.data.total_rides''',
      );
  static int? activedrivers(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.active_drivers''',
      ));
  static int? totalusers(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.total_users''',
      ));
  static double? totalearnings(dynamic response) =>
      castToType<double>(getJsonField(
        response,
        r'''$.data.total_earnings''',
      ));
  static int? todayrides(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.rides_completed_today''',
      ));
  static int? newuserstoday(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.new_users_today''',
      ));
  static dynamic data(dynamic response) => getJsonField(
        response,
        r'''$.data''',
      );
}

class GetDriverByIdCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    int? id,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'GetDriverById',
      apiUrl: '${ApiConfig.apiBase}/drivers/$id',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static dynamic data(dynamic response) => getJsonField(
        response,
        r'''$.data''',
      );
  static String? drivername(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data.first_name''',
      ));
  static String? licenseimage(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data.license_image''',
      ));
  static String? aadharimage(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data.aadhaar_image''',
      ));
  static String? panimage(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.pan_image''',
      ));
  static String? profileimage(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data.profile_image''',
      ));
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}




// ============ 1. Auth (Public) ============
class RefreshTokenCall {
  static Future<ApiCallResponse> call({String? refreshToken = ''}) async {
    final body = '{"refreshToken": "${escapeStringForJson(refreshToken)}"}';
    return ApiManager.instance.makeApiCall(
      callName: 'refreshToken',
      apiUrl: '${ApiConfig.apiBase}/admins/refresh-token',
      callType: ApiCallType.POST,
      headers: {'Content-Type': 'application/json'},
      params: {},
      body: body,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

// ============ 2. Profile & Admins ============
class GetProfileCall {
  static Future<ApiCallResponse> call({String? token = ''}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getProfile',
      apiUrl: '${ApiConfig.apiBase}/admins/profile',
      callType: ApiCallType.GET,
      headers: {'Authorization': 'Bearer $token'},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetAllAdminsCall {
  static Future<ApiCallResponse> call({String? token = ''}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getAllAdmins',
      apiUrl: '${ApiConfig.apiBase}/admins/getadmins',
      callType: ApiCallType.GET,
      headers: {'Authorization': 'Bearer $token'},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CreateAdminCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    String? adminName = '',
    String? email = '',
    String? password = '',
    String? role = 'SUPER_ADMIN',
  }) async {
    final body = '''
{
  "adminName": "${escapeStringForJson(adminName)}",
  "email": "${escapeStringForJson(email)}",
  "password": "${escapeStringForJson(password)}",
  "role": "${escapeStringForJson(role)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'createAdmin',
      apiUrl: '${ApiConfig.apiBase}/admins/post',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      params: {},
      body: body,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetAdminByIdCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required int adminId,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getAdminById',
      apiUrl: '${ApiConfig.apiBase}/admins/$adminId',
      callType: ApiCallType.GET,
      headers: {'Authorization': 'Bearer $token'},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class UpdateAdminCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required int adminId,
    String? name,
    String? email,
    String? role,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;
    if (role != null) body['role'] = role;
    return ApiManager.instance.makeApiCall(
      callName: 'updateAdmin',
      apiUrl: '${ApiConfig.apiBase}/admins/$adminId',
      callType: ApiCallType.PUT,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      params: {},
      body: json.encode(body),
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class DeleteAdminCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required int adminId,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'deleteAdmin',
      apiUrl: '${ApiConfig.apiBase}/admins/$adminId',
      callType: ApiCallType.DELETE,
      headers: {'Authorization': 'Bearer $token'},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

// ============ 4. Users & Drivers - Block/Unblock ============
class BlockUserCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required int userId,
    String? reasonForBlocking = '',
  }) async {
    final body = '''
{
  "user_id": $userId,
  "reason_for_blocking": "${escapeStringForJson(reasonForBlocking)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'blockUser',
      apiUrl: '${ApiConfig.apiBase}/admins/block-user',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      params: {},
      body: body,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class UnblockUserCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required int userId,
  }) async {
    final body = '{"user_id": $userId}';
    return ApiManager.instance.makeApiCall(
      callName: 'unblockUser',
      apiUrl: '${ApiConfig.apiBase}/admins/unblock-user',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      params: {},
      body: body,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class BlockedUsersCall {
  static Future<ApiCallResponse> call({String? token = ''}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'blockedUsers',
      apiUrl: '${ApiConfig.apiBase}/admins/blocked-users',
      callType: ApiCallType.GET,
      headers: {'Authorization': 'Bearer $token'},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

// ============ 5. Vehicles ============
/// GET admin vehicles (sub vehicles) - matches Postman {{baseURL}}/api/admins/api/admins/vehicles
class GetAllVehiclesCall {
  static Future<ApiCallResponse> call({String? token = ''}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getAllVehicles',
      apiUrl: '${ApiConfig.apiBase}/admins/api/admins/vehicles',
      callType: ApiCallType.GET,
      headers: {'Authorization': 'Bearer $token'},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

// ============ 6. KYC & Documents ============
class KycPendingCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    int? page,
    int? limit,
  }) async {
    final params = <String, dynamic>{};
    if (page != null) params['page'] = page;
    if (limit != null) params['limit'] = limit;
    return ApiManager.instance.makeApiCall(
      callName: 'kycPending',
      apiUrl: '${ApiConfig.apiBase}/admins/kyc-pending',
      callType: ApiCallType.GET,
      headers: {'Authorization': 'Bearer $token'},
      params: params,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class VerifyDriverLicenseCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required int driverId,
    String? licenseNumber = '',
    String? verificationStatus = 'approved',
    String? adminNotes = '',
  }) async {
    final body = '''
{
  "driver_id": $driverId,
  "license_number": "${escapeStringForJson(licenseNumber)}",
  "verification_status": "${escapeStringForJson(verificationStatus)}",
  "admin_notes": "${escapeStringForJson(adminNotes)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'verifyDriverLicense',
      apiUrl: '${ApiConfig.apiBase}/admins/verify-driver-license',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      params: {},
      body: body,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

// ============ 7. Cities & Zones ============
class GetCitiesCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    bool? isActive,
  }) async {
    final params = <String, dynamic>{};
    if (isActive != null) params['is_active'] = isActive;
    return ApiManager.instance.makeApiCall(
      callName: 'getCities',
      apiUrl: '${ApiConfig.apiBase}/admins/cities',
      callType: ApiCallType.GET,
      headers: {'Authorization': 'Bearer $token'},
      params: params,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetZonesCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    int? cityId,
  }) async {
    final params = <String, dynamic>{};
    if (cityId != null) params['city_id'] = cityId;
    return ApiManager.instance.makeApiCall(
      callName: 'getZones',
      apiUrl: '${ApiConfig.apiBase}/admins/zones',
      callType: ApiCallType.GET,
      headers: {'Authorization': 'Bearer $token'},
      params: params,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class AddCityCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required String name,
    String? country,
    bool? isActive = true,
  }) async {
    final body = json.encode({
      'name': name,
      if (country != null) 'country': country,
      if (isActive != null) 'is_active': isActive,
    });
    return ApiManager.instance.makeApiCall(
      callName: 'addCity',
      apiUrl: '${ApiConfig.apiBase}/admins/cities',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      params: {},
      body: body,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class AddZoneCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required String name,
    required int cityId,
    String? coordinates,
    bool? isActive = true,
  }) async {
    final body = json.encode({
      'name': name,
      'city_id': cityId,
      if (coordinates != null) 'coordinates': coordinates,
      if (isActive != null) 'is_active': isActive,
    });
    return ApiManager.instance.makeApiCall(
      callName: 'addZone',
      apiUrl: '${ApiConfig.apiBase}/admins/zones',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      params: {},
      body: body,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

// ============ 8. Promo Codes ============
class GetPromoCodesCall {
  static Future<ApiCallResponse> call({String? token = ''}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getPromoCodes',
      apiUrl: '${ApiConfig.apiBase}/admins/promo-codes',
      callType: ApiCallType.GET,
      headers: {'Authorization': 'Bearer $token'},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class AddPromoCodeCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    String? codeName = '',
    String? discountType = 'percentage',
    double? discountValue = 0,
    double? maxDiscountAmount = 0,
    String? expiryDate = '',
    int? usageLimit = 1000,
    int? createdByAdminId = 1,
  }) async {
    final body = '''
{
  "code_name": "${escapeStringForJson(codeName)}",
  "discount_type": "${escapeStringForJson(discountType)}",
  "discount_value": $discountValue,
  "max_discount_amount": $maxDiscountAmount,
  "expiry_date": "${escapeStringForJson(expiryDate)}",
  "usage_limit": $usageLimit,
  "created_by_admin_id": $createdByAdminId
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'addPromoCode',
      apiUrl: '${ApiConfig.apiBase}/admins/promo-codes',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      params: {},
      body: body,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class DeactivatePromoCodeCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required int promoId,
  }) async {
    final body = '{"promo_id": $promoId}';
    return ApiManager.instance.makeApiCall(
      callName: 'deactivatePromoCode',
      apiUrl: '${ApiConfig.apiBase}/admins/promo-codes/deactivate',
      callType: ApiCallType.PATCH,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      params: {},
      body: body,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

// ============ 9. Support & Complaints ============
class GetSupportTicketsCall {
  static Future<ApiCallResponse> call({String? token = ''}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getSupportTickets',
      apiUrl: '${ApiConfig.apiBase}/admins/support-tickets',
      callType: ApiCallType.GET,
      headers: {'Authorization': 'Bearer $token'},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetComplaintsCall {
  static Future<ApiCallResponse> call({String? token = ''}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getComplaints',
      apiUrl: '${ApiConfig.apiBase}/admins/complaints',
      callType: ApiCallType.GET,
      headers: {'Authorization': 'Bearer $token'},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

// ============ 10. Revenue & Driver Performance ============
class RevenueAnalyticsCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    String? period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final params = <String, dynamic>{};
    if (period != null) params['period'] = period;
    if (startDate != null) params['start_date'] = startDate.toIso8601String();
    if (endDate != null) params['end_date'] = endDate.toIso8601String();
    return ApiManager.instance.makeApiCall(
      callName: 'revenueAnalytics',
      apiUrl: '${ApiConfig.apiBase}/admins/revenue-analytics',
      callType: ApiCallType.GET,
      headers: {'Authorization': 'Bearer $token'},
      params: params,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class DriverPerformanceCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    int? driverId,
    String? period,
  }) async {
    final params = <String, dynamic>{};
    if (driverId != null) params['driver_id'] = driverId;
    if (period != null) params['period'] = period;
    return ApiManager.instance.makeApiCall(
      callName: 'driverPerformance',
      apiUrl: '${ApiConfig.apiBase}/admins/driver-performance',
      callType: ApiCallType.GET,
      headers: {'Authorization': 'Bearer $token'},
      params: params,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

// ============ 10b. Update Profile & Settings ============
class UpdateProfileCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    String? name,
    String? email,
    String? phone,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;
    if (phone != null) body['phone'] = phone;
    return ApiManager.instance.makeApiCall(
      callName: 'updateProfile',
      apiUrl: '${ApiConfig.apiBase}/admins/update-profile',
      callType: ApiCallType.PATCH,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      params: {},
      body: json.encode(body),
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class UpdateAdminSettingsCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    Map<String, dynamic>? settings,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'updateAdminSettings',
      apiUrl: '${ApiConfig.apiBase}/admins/settings',
      callType: ApiCallType.PATCH,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      params: {},
      body: json.encode(settings ?? {}),
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

// ============ 10c. Support Ticket Response ============
class RespondSupportTicketCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required int ticketId,
    String? response = '',
  }) async {
    final body = json.encode({
      'ticket_id': ticketId,
      'response': response ?? '',
    });
    return ApiManager.instance.makeApiCall(
      callName: 'respondSupportTicket',
      apiUrl: '${ApiConfig.apiBase}/admins/support-tickets/respond',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      params: {},
      body: body,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

// ============ 10d. Complaints Update ============
class UpdateComplaintCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required int complaintId,
    String? status,
    String? adminResponse,
  }) async {
    final body = <String, dynamic>{'complaint_id': complaintId};
    if (status != null) body['status'] = status;
    if (adminResponse != null) body['admin_response'] = adminResponse;
    return ApiManager.instance.makeApiCall(
      callName: 'updateComplaint',
      apiUrl: '${ApiConfig.apiBase}/admins/complaints/update',
      callType: ApiCallType.PATCH,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      params: {},
      body: json.encode(body),
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

// ============ 10e. Vehicle Types (GET & PUT) ============
class GetVehicleTypesCall {
  static Future<ApiCallResponse> call({String? token = ''}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getVehicleTypes',
      apiUrl: '${ApiConfig.apiBase}/vehicle-types/getall-vehicle',
      callType: ApiCallType.GET,
      headers: {'Authorization': 'Bearer $token'},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class UpdateVehicleTypeCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required int vehicleTypeId,
    String? name,
    FFUploadedFile? image,
  }) async {
    final params = <String, dynamic>{'name': name ?? ''};
    if (image != null && (image.bytes?.isNotEmpty ?? false)) params['image'] = image;
    return ApiManager.instance.makeApiCall(
      callName: 'updateVehicleType',
      apiUrl: '${ApiConfig.apiBase}/vehicle-types/update-vehicle-type/$vehicleTypeId',
      callType: ApiCallType.PUT,
      headers: {'Authorization': 'Bearer $token'},
      params: params,
      bodyType: BodyType.MULTIPART,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

// ============ 10f. Admin Vehicles PUT ============
class UpdateAdminVehicleCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required int vehicleId,
    String? vehicleName,
    String? kmPerPrice,
    String? vehicleType,
    int? seatingCapacity,
    int? luggageCapacity,
    FFUploadedFile? vehicleImage,
  }) async {
    final params = <String, dynamic>{
      'vehicle_name': vehicleName ?? '',
      'kilometer_per_price': kmPerPrice ?? '',
      'vehicle_type': vehicleType ?? '',
      'seating_capacity': seatingCapacity ?? 0,
      'luggage_capacity': luggageCapacity ?? 0,
    };
    if (vehicleImage != null && (vehicleImage.bytes?.isNotEmpty ?? false)) {
      params['vehicle_image'] = vehicleImage;
    }
    return ApiManager.instance.makeApiCall(
      callName: 'updateAdminVehicle',
      apiUrl: '${ApiConfig.apiBase}/admins/adminvehicles/$vehicleId',
      callType: ApiCallType.PUT,
      headers: {'Authorization': 'Bearer $token'},
      params: params,
      bodyType: BodyType.MULTIPART,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

// ============ 10g. Notifications (GET) ============
class GetNotificationsCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    int? page,
    int? pageSize,
  }) async {
    final params = <String, dynamic>{};
    if (page != null) params['page'] = page;
    if (pageSize != null) params['pageSize'] = pageSize;
    return ApiManager.instance.makeApiCall(
      callName: 'getNotifications',
      apiUrl: '${ApiConfig.apiBase}/admins/notifications',
      callType: ApiCallType.GET,
      headers: {'Authorization': 'Bearer $token'},
      params: params,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

// ============ 10h. Ratings ============
class GetRatingsCall {
  static Future<ApiCallResponse> call({String? token = ''}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getRatings',
      apiUrl: '${ApiConfig.apiBase}/ratings/getall',
      callType: ApiCallType.GET,
      headers: {'Authorization': 'Bearer $token'},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

// ============ 10i. System & Financial Reports ============
class GetSystemReportsCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    String? reportType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final params = <String, dynamic>{};
    if (reportType != null) params['report_type'] = reportType;
    if (startDate != null) params['start_date'] = startDate.toIso8601String();
    if (endDate != null) params['end_date'] = endDate.toIso8601String();
    return ApiManager.instance.makeApiCall(
      callName: 'getSystemReports',
      apiUrl: '${ApiConfig.apiBase}/admins/system-reports',
      callType: ApiCallType.GET,
      headers: {'Authorization': 'Bearer $token'},
      params: params,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetFinancialReportsCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    String? period,
  }) async {
    final params = <String, dynamic>{};
    if (period != null) params['period'] = period;
    return ApiManager.instance.makeApiCall(
      callName: 'getFinancialReports',
      apiUrl: '${ApiConfig.apiBase}/admins/financial-reports',
      callType: ApiCallType.GET,
      headers: {'Authorization': 'Bearer $token'},
      params: params,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

// ============ 10j. Referrals ============
class GetReferralDashboardCall {
  static Future<ApiCallResponse> call({String? token = ''}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getReferralDashboard',
      apiUrl: '${ApiConfig.apiBase}/admins/referral-dashboard',
      callType: ApiCallType.GET,
      headers: {'Authorization': 'Bearer $token'},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class OverrideReferralLimitCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required int userId,
    int? newLimit,
  }) async {
    final body = json.encode({
      'user_id': userId,
      if (newLimit != null) 'new_limit': newLimit,
    });
    return ApiManager.instance.makeApiCall(
      callName: 'overrideReferralLimit',
      apiUrl: '${ApiConfig.apiBase}/admins/override-referral-limit',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      params: {},
      body: body,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

// ============ 11. Notifications ============
/// POST /api/admins/notifications/send - Firebase/FCM broadcast
/// body: title, message, target (all_users | all_drivers), priority (high | normal)
class SendNotificationCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    String? title = '',
    String? message = '',
    String? target = 'all_users',
    String? priority = 'high',
  }) async {
    final bodyJson = '''
{
  "title": "${escapeStringForJson(title)}",
  "message": "${escapeStringForJson(message)}",
  "target": "${escapeStringForJson(target)}",
  "priority": "${escapeStringForJson(priority)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'sendNotification',
      apiUrl: '${ApiConfig.apiBase}/admins/notifications/send',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      params: {},
      body: bodyJson,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class SendBroadcastNotificationCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    String? title = '',
    String? body = '',
  }) async {
    final bodyJson = '''
{
  "title": "${escapeStringForJson(title)}",
  "body": "${escapeStringForJson(body)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'sendBroadcastNotification',
      apiUrl: '${ApiConfig.apiBase}/admins/notifications/send',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      params: {},
      body: bodyJson,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

// ============ 3. Dashboard & Analytics (extended) ============
class RidesAnalyticsCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    String period = 'daily',
    String rideType = 'all',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'ridesAnalytics',
      apiUrl: '${ApiConfig.apiBase}/admins/rides-analytics',
      callType: ApiCallType.GET,
      headers: {'Authorization': 'Bearer $token'},
      params: {'period': period, 'ride_type': rideType},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class EarningsAnalyticsCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    String period = 'monthly',
    String vehicleType = 'all',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'earningsAnalytics',
      apiUrl: '${ApiConfig.apiBase}/admins/earnings-analytics',
      callType: ApiCallType.GET,
      headers: {'Authorization': 'Bearer $token'},
      params: {'period': period, 'vehicle_type': vehicleType},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

// ============ Rides ============
class GetRidesCall {
  static Future<ApiCallResponse> call({String? token = ''}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getRides',
      apiUrl: '${ApiConfig.apiBase}/rides/getall',
      callType: ApiCallType.GET,
      headers: {'Authorization': 'Bearer $token'},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List? data(dynamic response) =>
      getJsonField(response, r'''$.data''', true) as List?;
}

class GetRideByIdCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required int rideId,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getRideById',
      apiUrl: '${ApiConfig.apiBase}/rides/$rideId',
      callType: ApiCallType.GET,
      headers: {'Authorization': 'Bearer $token'},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static dynamic data(dynamic response) =>
      getJsonField(response, r'''$.data''');
}

// ============ Payments ============
class GetPaymentsCall {
  static Future<ApiCallResponse> call({String? token = ''}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getPayments',
      apiUrl: '${ApiConfig.apiBase}/payments/getall',
      callType: ApiCallType.GET,
      headers: {'Authorization': 'Bearer $token'},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List? data(dynamic response) =>
      getJsonField(response, r'''$.data''', true) as List?;
}

// ============ Wallets ============
class GetWalletsCall {
  static Future<ApiCallResponse> call({String? token = ''}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getWallets',
      apiUrl: '${ApiConfig.apiBase}/wallets/getall',
      callType: ApiCallType.GET,
      headers: {'Authorization': 'Bearer $token'},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List? data(dynamic response) =>
      getJsonField(response, r'''$.data''', true) as List?;
}

// ============ Admin Finance ============
class CompanyWalletCall {
  static Future<ApiCallResponse> call({String? token = ''}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'companyWallet',
      apiUrl: '${ApiConfig.apiBase}/admin-finance/company-wallet',
      callType: ApiCallType.GET,
      headers: {'Authorization': 'Bearer $token'},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetCommissionsCall {
  static Future<ApiCallResponse> call({String? token = ''}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getCommissions',
      apiUrl: '${ApiConfig.apiBase}/admin-finance/commissions',
      callType: ApiCallType.GET,
      headers: {'Authorization': 'Bearer $token'},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetFinanceSettingsCall {
  static Future<ApiCallResponse> call({String? token = ''}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getFinanceSettings',
      apiUrl: '${ApiConfig.apiBase}/admin-finance/get/finance-settings',
      callType: ApiCallType.GET,
      headers: {'Authorization': 'Bearer $token'},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class UpdateFinanceSettingsCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    double? adminCommissionPercent,
    double? referralCommissionPercent,
    int? settlementHour,
    int? settlementMinute,
  }) async {
    final body = '''
{
  "admin_commission_percent": ${adminCommissionPercent ?? 0},
  "referral_commission_percent": ${referralCommissionPercent ?? 0},
  "settlement_hour": ${settlementHour ?? 0},
  "settlement_minute": ${settlementMinute ?? 0}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'updateFinanceSettings',
      apiUrl: '${ApiConfig.apiBase}/admin-finance/finance-settings',
      callType: ApiCallType.PUT,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      params: {},
      body: body,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}


String _toEncodable(dynamic item) {
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}
