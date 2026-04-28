import 'dart:convert';

import '/config/theme/flutter_flow_util.dart';
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

class SetPricingCall {
  /// POST /api/pricing/set
  /// Body: { vehicle_id, base_km_start, base_km_end, base_fare, price_per_km }
  static Future<ApiCallResponse> call({
    required int vehicleId,
    required int baseKmStart,
    required int baseKmEnd,
    required num baseFare,
    required num pricePerKm,
    String? token = '',
  }) async {
    final body = json.encode({
      'vehicle_id': vehicleId,
      'base_km_start': baseKmStart,
      'base_km_end': baseKmEnd,
      'base_fare': baseFare,
      'price_per_km': pricePerKm,
    });
    return ApiManager.instance.makeApiCall(
      callName: 'setPricing',
      apiUrl: '${ApiConfig.apiBase}/pricing/set',
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

  static dynamic pricing(dynamic response) => getJsonField(
        response,
        r'''$.pricing''',
      );
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
      apiUrl: '${ApiConfig.apiBase}/admins/earnings-analytics?period=weekly',
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
    int page = 1,
    int limit = 20,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'ActiveDrivers',
      apiUrl: '${ApiConfig.apiBase}/admins/active-drivers',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
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
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (status != null && status.isNotEmpty) {
      params['status'] = status;
    }
    return ApiManager.instance.makeApiCall(
      callName: 'AllUsers',
      apiUrl: '${ApiConfig.apiBase}/admins/all-users',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: params,
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
  static int? currentPage(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.page''',
      ));
  static int? pageLimit(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.limit''',
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
      apiUrl: 'https://ugo-api.icacorp.org/api/drivers/getall',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer $token',
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

class UpdateDriverCall {
  /// PUT /api/drivers/:id
  /// Body: { is_online, is_active, first_name, last_name, email, mobile_number, preferred_city_id, account_status }
  static Future<ApiCallResponse> call({
    required int id,
    bool? isOnline,
    bool? isActive,
    String? firstName,
    String? lastName,
    String? email,
    String? mobileNumber,
    int? preferredCityId,
    String? accountStatus,
    String? token = '',
  }) async {
    final bodyMap = <String, dynamic>{};
    if (isOnline != null) bodyMap['is_online'] = isOnline;
    if (isActive != null) bodyMap['is_active'] = isActive;
    if (firstName != null && firstName.isNotEmpty) {
      bodyMap['first_name'] = firstName;
    }
    if (lastName != null && lastName.isNotEmpty) {
      bodyMap['last_name'] = lastName;
    }
    if (email != null && email.isNotEmpty) bodyMap['email'] = email;
    if (mobileNumber != null && mobileNumber.isNotEmpty) {
      bodyMap['mobile_number'] = mobileNumber;
    }
    if (preferredCityId != null) {
      bodyMap['preferred_city_id'] = preferredCityId;
    }
    if (accountStatus != null && accountStatus.isNotEmpty) {
      bodyMap['account_status'] = accountStatus;
    }

    return ApiManager.instance.makeApiCall(
      callName: 'UpdateDriver',
      apiUrl: '${ApiConfig.apiBase}/drivers/$id',
      callType: ApiCallType.PUT,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      params: {},
      body: json.encode(bodyMap),
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

class UpdateDriverStatusCall {
  /// PATCH /api/drivers/:id/status
  /// Body: { active_driver: true/false }
  static Future<ApiCallResponse> call({
    required int id,
    required bool activeDriver,
    String? token = '',
  }) async {
    final body = json.encode({'active_driver': activeDriver});
    return ApiManager.instance.makeApiCall(
      callName: 'UpdateDriverStatus',
      apiUrl: '${ApiConfig.apiBase}/drivers/$id/status',
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

  static List? data(dynamic response) =>
      getJsonField(response, r'''$.data''', true) as List?;
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

  static List? data(dynamic response) =>
      getJsonField(response, r'''$.data''', true) as List?;
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

  static Map<String, dynamic>? data(dynamic response) =>
      getJsonField(response, r'''$.data''') as Map<String, dynamic>?;
}

class AddZoneCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required String name,
    required int cityId,
    String type = 'radius',
    double? centerLat,
    double? centerLng,
    double? radiusKm,
    String? polygonJson,
    bool? isActive = true,
  }) async {
    final body = json.encode({
      'city_id': cityId,
      'name': name,
      'type': type,
      if (centerLat != null) 'center_lat': centerLat,
      if (centerLng != null) 'center_lng': centerLng,
      if (radiusKm != null) 'radius_km': radiusKm,
      if (polygonJson != null) 'polygon_json': polygonJson,
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

  static Map<String, dynamic>? data(dynamic response) =>
      getJsonField(response, r'''$.data''') as Map<String, dynamic>?;
}

class UpdateCityCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required int cityId,
    String? name,
    bool? isActive,
  }) async {
    final body = json.encode({
      if (name != null) 'name': name,
      if (isActive != null) 'is_active': isActive,
    });
    return ApiManager.instance.makeApiCall(
      callName: 'updateCity',
      apiUrl: '${ApiConfig.apiBase}/admins/cities/$cityId',
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

class DeleteCityCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required int cityId,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'deleteCity',
      apiUrl: '${ApiConfig.apiBase}/admins/cities/$cityId',
      callType: ApiCallType.DELETE,
      headers: {
        'Authorization': 'Bearer $token',
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
}

class UpdateZoneCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required int zoneId,
    int? cityId,
    String? name,
    String? type,
    double? centerLat,
    double? centerLng,
    double? radiusKm,
    dynamic polygonJson,
    bool? isActive,
  }) async {
    final body = json.encode({
      if (cityId != null) 'city_id': cityId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (centerLat != null) 'center_lat': centerLat,
      if (centerLng != null) 'center_lng': centerLng,
      if (radiusKm != null) 'radius_km': radiusKm,
      if (polygonJson != null) 'polygon_json': polygonJson,
      if (isActive != null) 'is_active': isActive,
    });
    return ApiManager.instance.makeApiCall(
      callName: 'updateZone',
      apiUrl: '${ApiConfig.apiBase}/admins/zones/$zoneId',
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

class DeleteZoneCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required int zoneId,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'deleteZone',
      apiUrl: '${ApiConfig.apiBase}/admins/zones/$zoneId',
      callType: ApiCallType.DELETE,
      headers: {
        'Authorization': 'Bearer $token',
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
    if (image != null && (image.bytes?.isNotEmpty ?? false))
      params['image'] = image;
    return ApiManager.instance.makeApiCall(
      callName: 'updateVehicleType',
      apiUrl:
          '${ApiConfig.apiBase}/vehicle-types/update-vehicle-type/$vehicleTypeId',
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
  /// [vehicleId] — admin sub-vehicle id from `GET .../admins/vehicles` (`data[].id`).
  /// When null, analytics are not scoped to a single vehicle (`vehicle_type: all`).
  static Future<ApiCallResponse> call({
    String? token = '',
    String period = 'monthly',
    int? vehicleId,
  }) async {
    final params = <String, dynamic>{
      'period': period,
      'vehicle_type': 'all',
    };
    if (vehicleId != null) {
      params['vehicle_id'] = vehicleId.toString();
    }
    return ApiManager.instance.makeApiCall(
      callName: 'earningsAnalytics',
      apiUrl: '${ApiConfig.apiBase}/admins/earnings-analytics',
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

/// GET /api/rides/ride-status/stats — aggregate counts by ride status.
class GetRideStatusStatsCall {
  static Future<ApiCallResponse> call({String? token = ''}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getRideStatusStats',
      apiUrl: '${ApiConfig.apiBase}/rides/ride-status/stats',
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

  static int? total(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.total''',
      ));

  static Map<String, dynamic>? rideStatus(dynamic response) {
    final v = getJsonField(response, r'''$.data.ride_status''');
    if (v is Map) return Map<String, dynamic>.from(v);
    return null;
  }

  static int? statusCount(Map<String, dynamic>? rideStatus, String key) {
    if (rideStatus == null) return null;
    final seg = rideStatus[key];
    if (seg is! Map) return null;
    return castToType<int>(seg['count']);
  }

  static double? statusPercentage(
      Map<String, dynamic>? rideStatus, String key) {
    if (rideStatus == null) return null;
    final seg = rideStatus[key];
    if (seg is! Map) return null;
    return castToType<double>(seg['percentage']);
  }
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

/// Full ride payload for admin/support: `GET /admins/rides/:id/details`
/// (nested `user`, `driver`, `vehicle`, `adminVehicle`, all ride columns).
class GetAdminRideDetailsCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required int rideId,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getAdminRideDetails',
      apiUrl: '${ApiConfig.apiBase}/admins/rides/$rideId/details',
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
/// GET /api/payments/admin/payouts/pending — recent payout rows for admin dashboard.
class GetAdminPendingPayoutsCall {
  /// When [includeStatusParam] is false, the `status` query is omitted (backend may return all).
  /// When true, [status] defaults to `pending_manual_transfer` if null.
  static Future<ApiCallResponse> call({
    String? token = '',
    int page = 1,
    int limit = 10,
    String? status,
    bool includeStatusParam = true,
  }) async {
    final params = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (includeStatusParam) {
      params['status'] = status ?? 'pending_manual_transfer';
    }
    return ApiManager.instance.makeApiCall(
      callName: 'getAdminPendingPayouts',
      apiUrl: '${ApiConfig.apiBase}/payments/admin/payouts/pending',
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

  static List? payouts(dynamic response) =>
      getJsonField(response, r'''$.data.payouts''', true) as List?;

  /// Normalized list: `data.payouts`, or `data` as list, or top-level `payouts`.
  static List<dynamic> payoutsList(dynamic response) {
    final fromNested = payouts(response);
    if (fromNested != null && fromNested.isNotEmpty) {
      return List<dynamic>.from(fromNested);
    }
    final data = getJsonField(response, r'''$.data''');
    if (data is List && data.isNotEmpty) {
      return List<dynamic>.from(data);
    }
    final top = getJsonField(response, r'''$.payouts''');
    if (top is List) {
      return List<dynamic>.from(top);
    }
    return [];
  }
}

/// GET `/api/admin/withdraw/requests` — admin manual withdraw request queue.
class GetAdminWithdrawRequestsCall {
  static Future<ApiCallResponse> call({
    String? token = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getAdminWithdrawRequests',
      apiUrl: '${ApiConfig.apiBase}/admin/withdraw/requests',
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

  static int pendingCount(dynamic response) =>
      castToType<int>(getJsonField(response, r'''$.data.pending_count''')) ?? 0;

  static List<dynamic> requestsList(dynamic response) {
    final nested = getJsonField(response, r'''$.data.requests''');
    if (nested is List) {
      return List<dynamic>.from(nested);
    }
    final direct = getJsonField(response, r'''$.requests''');
    if (direct is List) {
      return List<dynamic>.from(direct);
    }
    return [];
  }
}

/// POST `/api/payments/payout/mark-paid` — admin confirms bank transfer completed.
class MarkPayoutPaidCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required int payoutId,
    String? paymentReference,
  }) async {
    final ref = escapeStringForJson(paymentReference ?? 'Admin app');
    final body = '{"payout_id": $payoutId, "payment_reference": "$ref"}';
    return ApiManager.instance.makeApiCall(
      callName: 'markPayoutPaid',
      apiUrl: '${ApiConfig.apiBase}/payments/payout/mark-paid',
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

  /// Normalized list: `data` as list, or nested `data.payments`, or top-level `payments`.
  static List<dynamic> paymentsList(dynamic response) {
    final direct = getJsonField(response, r'''$.data''');
    if (direct is List && direct.isNotEmpty) {
      return List<dynamic>.from(direct);
    }
    final nested =
        getJsonField(response, r'''$.data.payments''', true) as List?;
    if (nested != null && nested.isNotEmpty) {
      return List<dynamic>.from(nested);
    }
    final top = getJsonField(response, r'''$.payments''');
    if (top is List) {
      return List<dynamic>.from(top);
    }
    return [];
  }
}

// ============ Wallets ============
/// GET `https://ugo-api.icacorp.org/api/wallets/getall` (via [ApiConfig.apiBase]).
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

  /// Normalized list: `data` as list, or `data.wallets`, or top-level `wallets`.
  static List<dynamic> walletsList(dynamic response) {
    final direct = getJsonField(response, r'''$.data''');
    if (direct is List && direct.isNotEmpty) {
      return List<dynamic>.from(direct);
    }
    final nested = getJsonField(response, r'''$.data.wallets''', true) as List?;
    if (nested != null && nested.isNotEmpty) {
      return List<dynamic>.from(nested);
    }
    final top = getJsonField(response, r'''$.wallets''');
    if (top is List) {
      return List<dynamic>.from(top);
    }
    return [];
  }
}

/// GET `/api/admin/wallet/summary` — admin wallet dashboard summary cards.
class GetAdminWalletSummaryCall {
  static Future<ApiCallResponse> call({String? token = ''}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getAdminWalletSummary',
      apiUrl: '${ApiConfig.apiBase}/admin/wallet/summary',
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

  static Map<String, dynamic>? data(dynamic response) {
    final d = getJsonField(response, r'''$.data''');
    if (d is Map<String, dynamic>) return d;
    if (d is Map) return d.map((k, v) => MapEntry(k.toString(), v));
    return null;
  }
}

/// GET `/api/drivers/wallet/:id/transactions` — single driver wallet ledger.
class GetDriverWalletTransactionsCall {
  static Future<ApiCallResponse> call({
    required int driverId,
    String? token = '',
    int page = 1,
    int pageSize = 20,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getDriverWalletTransactions',
      apiUrl: '${ApiConfig.apiBase}/drivers/wallet/$driverId/transactions',
      callType: ApiCallType.GET,
      headers: {'Authorization': 'Bearer $token'},
      params: {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<dynamic> transactionsList(dynamic response) {
    final list =
        getJsonField(response, r'''$.data.transactions''', true) as List?;
    if (list != null && list.isNotEmpty) {
      return List<dynamic>.from(list);
    }
    final data = getJsonField(response, r'''$.data''');
    if (data is List && data.isNotEmpty) {
      return List<dynamic>.from(data);
    }
    return [];
  }
}

/// GET `/api/wallets/admin/transactions` — paginated wallet ledger (admin).
class GetAdminWalletTransactionsCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    int page = 1,
    int limit = 10,
    String? q,
    String? flow,
    int? driverId,
    String? from,
    String? to,
  }) async {
    final params = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    final query = q?.trim();
    if (query != null && query.isNotEmpty) {
      params['q'] = query;
    }
    final f = flow?.trim().toLowerCase();
    if (f == 'credit' || f == 'debit') {
      params['flow'] = f;
    }
    if (driverId != null && driverId > 0) {
      params['driver_id'] = driverId.toString();
    }
    final fromText = from?.trim();
    if (fromText != null && fromText.isNotEmpty) {
      params['from'] = fromText;
    }
    final toText = to?.trim();
    if (toText != null && toText.isNotEmpty) {
      params['to'] = toText;
    }
    return ApiManager.instance.makeApiCall(
      callName: 'getAdminWalletTransactions',
      apiUrl: '${ApiConfig.apiBase}/admins/wallet/transactions',
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

  static int total(dynamic response) {
    final v = getJsonField(response, r'''$.data.total''');
    if (v is int) return v;
    if (v is double) return v.round();
    if (v == null) {
      final list = transactionsList(response);
      return list.length;
    }
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static int totalPages(dynamic response) {
    final v = getJsonField(response, r'''$.data.totalPages''');
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse(v?.toString() ?? '') ?? 1;
  }

  static List<dynamic> transactionsList(dynamic response) {
    final list =
        getJsonField(response, r'''$.data.transactions''', true) as List?;
    if (list != null && list.isNotEmpty) {
      return List<dynamic>.from(list);
    }
    final data = getJsonField(response, r'''$.data''');
    if (data is List) {
      return List<dynamic>.from(data);
    }
    return [];
  }
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

/// GET `/api/admins/finance/summary` — ledger-aware finance headline metrics.
class GetAdminFinanceSummaryCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    String? from,
    String? to,
  }) async {
    final params = <String, dynamic>{};
    if (from != null && from.trim().isNotEmpty) params['from'] = from.trim();
    if (to != null && to.trim().isNotEmpty) params['to'] = to.trim();
    return ApiManager.instance.makeApiCall(
      callName: 'getAdminFinanceSummary',
      apiUrl: '${ApiConfig.apiBase}/admins/finance/summary',
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

  static Map<String, dynamic>? data(dynamic response) =>
      getJsonField(response, r'''$.data''') as Map<String, dynamic>?;
}

/// GET `/api/admins/ledger` — paginated `wallet_entries` explorer.
class GetAdminLedgerCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    int page = 1,
    int limit = 25,
    int? rideId,
    int? userId,
    int? driverId,
    String? txnType,
    String? from,
    String? to,
    String? amountMin,
    String? amountMax,
  }) async {
    final params = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (rideId != null && rideId > 0) params['ride_id'] = rideId.toString();
    if (userId != null && userId > 0) params['user_id'] = userId.toString();
    if (driverId != null && driverId > 0)
      params['driver_id'] = driverId.toString();
    if (txnType != null && txnType.trim().isNotEmpty)
      params['txn_type'] = txnType.trim();
    if (from != null && from.trim().isNotEmpty) params['from'] = from.trim();
    if (to != null && to.trim().isNotEmpty) params['to'] = to.trim();
    if (amountMin != null && amountMin.trim().isNotEmpty)
      params['amount_min'] = amountMin.trim();
    if (amountMax != null && amountMax.trim().isNotEmpty)
      params['amount_max'] = amountMax.trim();
    return ApiManager.instance.makeApiCall(
      callName: 'getAdminLedger',
      apiUrl: '${ApiConfig.apiBase}/admins/ledger',
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

  static List<dynamic> entriesList(dynamic response) {
    final list = getJsonField(response, r'''$.data.entries''', true) as List?;
    if (list != null && list.isNotEmpty) return List<dynamic>.from(list);
    return const [];
  }

  static int total(dynamic response) {
    final v = getJsonField(response, r'''$.data.total''');
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static int totalPages(dynamic response) {
    final v = getJsonField(response, r'''$.data.totalPages''');
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse(v?.toString() ?? '') ?? 1;
  }
}

/// POST `/api/admins/wallet/adjust` — admin ledger + legacy wallet_txn adjustment.
class PostAdminWalletAdjustCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    int? userId,
    int? driverId,
    required double amount,
    required String reason,
    required String idempotencyKey,
  }) async {
    final body = json.encode({
      if (userId != null) 'user_id': userId,
      if (driverId != null) 'driver_id': driverId,
      'amount': amount,
      'reason': reason,
      'idempotency_key': idempotencyKey,
    });
    return ApiManager.instance.makeApiCall(
      callName: 'postAdminWalletAdjust',
      apiUrl: '${ApiConfig.apiBase}/admins/wallet/adjust',
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

/// POST `/api/payments/admin/payout/reject` — reject before execute.
class PostAdminPayoutRejectCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required int payoutId,
    required String reason,
  }) async {
    final body = json.encode({
      'payout_id': payoutId,
      'reason': reason,
    });
    return ApiManager.instance.makeApiCall(
      callName: 'postAdminPayoutReject',
      apiUrl: '${ApiConfig.apiBase}/payments/admin/payout/reject',
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

/// GET `/api/admins/finance/reports/:kind` — kind = revenue | payouts | referrals
class GetAdminFinanceReportCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required String kind,
    String? from,
    String? to,

    /// revenue only: `daily` | `weekly` | `monthly`
    String? group,
  }) async {
    final k = kind.trim().toLowerCase();
    final params = <String, dynamic>{};
    if (from != null && from.trim().isNotEmpty) params['from'] = from.trim();
    if (to != null && to.trim().isNotEmpty) params['to'] = to.trim();
    if (group != null && group.trim().isNotEmpty)
      params['group'] = group.trim();
    return ApiManager.instance.makeApiCall(
      callName: 'getAdminFinanceReport',
      apiUrl: '${ApiConfig.apiBase}/admins/finance/reports/$k',
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

/// GET `/api/admins/finance/metrics` — outbox + payout counters.
class GetAdminFinanceMetricsCall {
  static Future<ApiCallResponse> call({String? token = ''}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getAdminFinanceMetrics',
      apiUrl: '${ApiConfig.apiBase}/admins/finance/metrics',
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

/// GET `/api/admins/finance/flags` — open finance_account_flags.
class GetAdminFinanceFlagsCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    int limit = 50,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getAdminFinanceFlags',
      apiUrl: '${ApiConfig.apiBase}/admins/finance/flags',
      callType: ApiCallType.GET,
      headers: {'Authorization': 'Bearer $token'},
      params: {'limit': limit.toString()},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<dynamic> flagsList(dynamic response) {
    final list = getJsonField(response, r'''$.data.flags''', true) as List?;
    if (list != null && list.isNotEmpty) return List<dynamic>.from(list);
    return const [];
  }
}

/// GET `/api/admins/finance/risk-profiles`
class GetAdminFinanceRiskProfilesCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    int limit = 50,
    double? minScore,
  }) async {
    final params = <String, dynamic>{'limit': limit.toString()};
    if (minScore != null) params['min_score'] = minScore.toString();
    return ApiManager.instance.makeApiCall(
      callName: 'getAdminFinanceRiskProfiles',
      apiUrl: '${ApiConfig.apiBase}/admins/finance/risk-profiles',
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

  static List<dynamic> profilesList(dynamic response) {
    final list = getJsonField(response, r'''$.data.profiles''', true) as List?;
    if (list != null && list.isNotEmpty) return List<dynamic>.from(list);
    return const [];
  }
}

/// POST `/api/admins/finance/flag`
class PostAdminFinanceFlagCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    int? userId,
    int? driverId,
    required String flagType,
    String severity = 'medium',
    String? reason,
    int? payoutId,
    bool applyPayoutHold = false,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'postAdminFinanceFlag',
      apiUrl: '${ApiConfig.apiBase}/admins/finance/flag',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      params: {},
      body: _financeFlagBody(
        userId: userId,
        driverId: driverId,
        flagType: flagType,
        severity: severity,
        reason: reason,
        payoutId: payoutId,
        applyPayoutHold: applyPayoutHold,
      ),
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String _financeFlagBody({
    int? userId,
    int? driverId,
    required String flagType,
    String severity = 'medium',
    String? reason,
    int? payoutId,
    bool applyPayoutHold = false,
  }) {
    final parts = <String>[];
    if (userId != null) parts.add('"user_id": $userId');
    if (driverId != null) parts.add('"driver_id": $driverId');
    parts.add('"flag_type": "${escapeStringForJson(flagType)}"');
    parts.add('"severity": "${escapeStringForJson(severity)}"');
    parts.add('"reason": "${escapeStringForJson(reason ?? '')}"');
    if (payoutId != null) parts.add('"payout_id": $payoutId');
    if (applyPayoutHold) parts.add('"apply_payout_hold": true');
    return '{${parts.join(',')}}';
  }
}

/// POST `/api/admins/finance/unflag`
class PostAdminFinanceResolveFlagCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    int? flagId,
    int? userId,
    int? driverId,
  }) async {
    final parts = <String>[];
    if (flagId != null) parts.add('"flag_id": $flagId');
    if (userId != null) parts.add('"user_id": $userId');
    if (driverId != null) parts.add('"driver_id": $driverId');
    final body = '{${parts.join(',')}}';
    return ApiManager.instance.makeApiCall(
      callName: 'postAdminFinanceResolveFlag',
      apiUrl: '${ApiConfig.apiBase}/admins/finance/unflag',
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

/// GET `/api/admins/finance/outbox`
class GetAdminFinanceOutboxCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    int limit = 40,
    String? status,
  }) async {
    final params = <String, dynamic>{'limit': limit.toString()};
    if (status != null && status.trim().isNotEmpty) {
      params['status'] = status.trim();
    }
    return ApiManager.instance.makeApiCall(
      callName: 'getAdminFinanceOutbox',
      apiUrl: '${ApiConfig.apiBase}/admins/finance/outbox',
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

  static List<dynamic> itemsList(dynamic response) {
    final list = getJsonField(response, r'''$.data.items''', true) as List?;
    if (list != null && list.isNotEmpty) return List<dynamic>.from(list);
    return const [];
  }
}

/// GET `/api/admins/payments/reconciliation`
class GetAdminPaymentsReconciliationCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    int sampleLimit = 25,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getAdminPaymentsReconciliation',
      apiUrl: '${ApiConfig.apiBase}/admins/payments/reconciliation',
      callType: ApiCallType.GET,
      headers: {'Authorization': 'Bearer $token'},
      params: {'sample_limit': sampleLimit.toString()},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

/// GET `/api/admins/finance/alerts`
class GetAdminFinanceAlertsCall {
  static Future<ApiCallResponse> call({String? token = ''}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getAdminFinanceAlerts',
      apiUrl: '${ApiConfig.apiBase}/admins/finance/alerts',
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

  static List<dynamic> alertsList(dynamic response) {
    final list = getJsonField(response, r'''$.data.alerts''', true) as List?;
    if (list != null && list.isNotEmpty) return List<dynamic>.from(list);
    return const [];
  }
}

/// GET `/api/admins/finance/insights`
class GetAdminFinanceInsightsCall {
  static Future<ApiCallResponse> call({String? token = ''}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getAdminFinanceInsights',
      apiUrl: '${ApiConfig.apiBase}/admins/finance/insights',
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

/// GET `/api/admins/finance/audit-timeline`
class GetAdminFinanceAuditTimelineCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    int? userId,
    int? driverId,
    int limit = 100,
  }) async {
    final params = <String, dynamic>{'limit': limit.toString()};
    if (userId != null && userId > 0) params['user_id'] = userId.toString();
    if (driverId != null && driverId > 0)
      params['driver_id'] = driverId.toString();
    return ApiManager.instance.makeApiCall(
      callName: 'getAdminFinanceAuditTimeline',
      apiUrl: '${ApiConfig.apiBase}/admins/finance/audit-timeline',
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

  static List<dynamic> itemsList(dynamic response) {
    final list = getJsonField(response, r'''$.data.items''', true) as List?;
    if (list != null && list.isNotEmpty) return List<dynamic>.from(list);
    return const [];
  }
}

/// GET `/api/admins/finance/workflows`
class GetAdminFinanceWorkflowsCall {
  static Future<ApiCallResponse> call({String? token = ''}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getAdminFinanceWorkflows',
      apiUrl: '${ApiConfig.apiBase}/admins/finance/workflows',
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

/// POST `/api/admins/finance/workflows/payout-hold`
class PostAdminFinanceWorkflowPayoutHoldCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required int payoutId,
    String? reason,
  }) async {
    final body = json.encode({
      'payout_id': payoutId,
      'reason': reason ?? 'manual_hold',
    });
    return ApiManager.instance.makeApiCall(
      callName: 'postAdminFinanceWorkflowPayoutHold',
      apiUrl: '${ApiConfig.apiBase}/admins/finance/workflows/payout-hold',
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

/// GET `/api/admins/finance/policies`
class GetAdminFinancePoliciesCall {
  static Future<ApiCallResponse> call({String? token = ''}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getAdminFinancePolicies',
      apiUrl: '${ApiConfig.apiBase}/admins/finance/policies',
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

  static List<dynamic> policiesList(dynamic response) {
    final list = getJsonField(response, r'''$.data.policies''', true) as List?;
    if (list != null) return List<dynamic>.from(list);
    return const [];
  }
}

/// PATCH `/api/admins/finance/policies/:id`
class PatchAdminFinancePolicyCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required int id,
    bool? enabled,
    int? priority,
  }) async {
    final bodyMap = <String, dynamic>{};
    if (enabled != null) bodyMap['enabled'] = enabled;
    if (priority != null) bodyMap['priority'] = priority;
    return ApiManager.instance.makeApiCall(
      callName: 'patchAdminFinancePolicy',
      apiUrl: '${ApiConfig.apiBase}/admins/finance/policies/$id',
      callType: ApiCallType.PATCH,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      params: {},
      body: json.encode(bodyMap),
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

/// GET `/api/admins/finance/cases`
class GetAdminFinanceCasesCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    String? status,
    int limit = 40,
  }) async {
    final params = <String, dynamic>{'limit': limit.toString()};
    if (status != null && status.isNotEmpty) params['status'] = status;
    return ApiManager.instance.makeApiCall(
      callName: 'getAdminFinanceCases',
      apiUrl: '${ApiConfig.apiBase}/admins/finance/cases',
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

  static List<dynamic> casesList(dynamic response) {
    final list = getJsonField(response, r'''$.data.cases''', true) as List?;
    if (list != null) return List<dynamic>.from(list);
    return const [];
  }
}

/// POST `/api/admins/finance/cases`
class PostAdminFinanceCaseCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required String entityType,
    required int entityId,
    String status = 'open',
    String? notes,
    String? sourceAlertCode,
    int? assignedAdminId,
    String? priority,
    String? riskBucket,
    num? driverRiskScore,
    num? anomalyScore,
    String? slaDueAtIso,
    bool skipSla = false,
  }) async {
    final body = json.encode({
      'entity_type': entityType,
      'entity_id': entityId,
      'status': status,
      if (notes != null) 'notes': notes,
      if (sourceAlertCode != null) 'source_alert_code': sourceAlertCode,
      if (assignedAdminId != null) 'assigned_admin_id': assignedAdminId,
      if (priority != null && priority.isNotEmpty) 'priority': priority,
      if (riskBucket != null && riskBucket.isNotEmpty)
        'risk_bucket': riskBucket,
      if (driverRiskScore != null) 'driver_risk_score': driverRiskScore,
      if (anomalyScore != null) 'anomaly_score': anomalyScore,
      if (slaDueAtIso != null) 'sla_due_at': slaDueAtIso,
      if (skipSla) 'skip_sla': true,
    });
    return ApiManager.instance.makeApiCall(
      callName: 'postAdminFinanceCase',
      apiUrl: '${ApiConfig.apiBase}/admins/finance/cases',
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

/// GET `/api/admins/finance/cases/:id`
class GetAdminFinanceCaseDetailCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required int caseId,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getAdminFinanceCaseDetail',
      apiUrl: '${ApiConfig.apiBase}/admins/finance/cases/$caseId',
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

  static Map<String, dynamic>? caseMap(dynamic response) {
    final m = getJsonField(response, r'''$.data.case''', true);
    if (m is Map<String, dynamic>) return m;
    if (m is Map) return Map<String, dynamic>.from(m);
    return null;
  }

  static List<dynamic> commentsList(dynamic response) {
    final list = getJsonField(response, r'''$.data.comments''', true) as List?;
    if (list != null) return List<dynamic>.from(list);
    return const [];
  }

  static List<dynamic> pauseSegmentsList(dynamic response) {
    final list =
        getJsonField(response, r'''$.data.pause_segments''', true) as List?;
    if (list != null) return List<dynamic>.from(list);
    return const [];
  }
}

/// POST `/api/admins/finance/cases/:id/comments`
class PostAdminFinanceCaseCommentCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required int caseId,
    required String body,
    String action = 'note',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'postAdminFinanceCaseComment',
      apiUrl: '${ApiConfig.apiBase}/admins/finance/cases/$caseId/comments',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      params: {},
      body: json.encode({'body': body, 'action': action}),
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

/// PATCH `/api/admins/finance/cases/:id`
class PatchAdminFinanceCaseCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required int caseId,
    String? status,
    String? notes,
    int? assignedAdminId,
    String? timelineNote,
    String? priority,
    String? slaDueAtIso,
    bool? clearSlaDueAt,
  }) async {
    final bodyMap = <String, dynamic>{};
    if (status != null) bodyMap['status'] = status;
    if (notes != null) bodyMap['notes'] = notes;
    if (assignedAdminId != null) bodyMap['assigned_admin_id'] = assignedAdminId;
    if (timelineNote != null && timelineNote.isNotEmpty)
      bodyMap['timeline_note'] = timelineNote;
    if (priority != null && priority.isNotEmpty) bodyMap['priority'] = priority;
    if (clearSlaDueAt == true) {
      bodyMap['sla_due_at'] = null;
    } else if (slaDueAtIso != null) {
      bodyMap['sla_due_at'] = slaDueAtIso;
    }
    return ApiManager.instance.makeApiCall(
      callName: 'patchAdminFinanceCase',
      apiUrl: '${ApiConfig.apiBase}/admins/finance/cases/$caseId',
      callType: ApiCallType.PATCH,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      params: {},
      body: json.encode(bodyMap),
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

/// GET `/api/admins/finance/case-metrics`
class GetAdminFinanceCaseMetricsCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    String? fromIso,
    String? toIso,
  }) async {
    final params = <String, dynamic>{};
    if (fromIso != null && fromIso.isNotEmpty) params['from'] = fromIso;
    if (toIso != null && toIso.isNotEmpty) params['to'] = toIso;
    return ApiManager.instance.makeApiCall(
      callName: 'getAdminFinanceCaseMetrics',
      apiUrl: '${ApiConfig.apiBase}/admins/finance/case-metrics',
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

  static Map<String, dynamic>? dataMap(dynamic response) {
    final m = getJsonField(response, r'''$.data''', true);
    if (m is Map<String, dynamic>) return m;
    if (m is Map) return Map<String, dynamic>.from(m);
    return null;
  }
}

/// GET `/api/admins/finance/sla-calendar`
class GetAdminFinanceSlaCalendarCall {
  static Future<ApiCallResponse> call({String? token = ''}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getAdminFinanceSlaCalendar',
      apiUrl: '${ApiConfig.apiBase}/admins/finance/sla-calendar',
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

  static Map<String, dynamic>? calendarMap(dynamic response) {
    final m = getJsonField(response, r'''$.data.calendar''', true);
    if (m is Map<String, dynamic>) return m;
    if (m is Map) return Map<String, dynamic>.from(m);
    return null;
  }
}

/// PATCH `/api/admins/finance/sla-calendar`
class PatchAdminFinanceSlaCalendarCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    String? timezone,
    String? businessStart,
    String? businessEnd,
    List<dynamic>? holidays,
    List<dynamic>? businessWeekdays,
    bool? enabled,
    bool? deferEscalationOutsideBh,
  }) async {
    final body = <String, dynamic>{};
    if (timezone != null) body['timezone'] = timezone;
    if (businessStart != null) body['business_start'] = businessStart;
    if (businessEnd != null) body['business_end'] = businessEnd;
    if (holidays != null) body['holidays'] = holidays;
    if (businessWeekdays != null) body['business_weekdays'] = businessWeekdays;
    if (enabled != null) body['enabled'] = enabled;
    if (deferEscalationOutsideBh != null) {
      body['defer_escalation_outside_bh'] = deferEscalationOutsideBh;
    }
    return ApiManager.instance.makeApiCall(
      callName: 'patchAdminFinanceSlaCalendar',
      apiUrl: '${ApiConfig.apiBase}/admins/finance/sla-calendar',
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

/// GET `/api/admins/finance/events/recent`
class GetAdminFinanceEventsRecentCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    int sinceId = 0,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getAdminFinanceEventsRecent',
      apiUrl: '${ApiConfig.apiBase}/admins/finance/events/recent',
      callType: ApiCallType.GET,
      headers: {'Authorization': 'Bearer $token'},
      params: {'since_id': sinceId.toString()},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<dynamic> eventsList(dynamic response) {
    final list = getJsonField(response, r'''$.data.events''', true) as List?;
    if (list != null) return List<dynamic>.from(list);
    return const [];
  }
}

/// GET `/api/admins/finance/intelligence/driver/:driverId`
class GetAdminFinanceDriverIntelCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    required int driverId,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getAdminFinanceDriverIntel',
      apiUrl:
          '${ApiConfig.apiBase}/admins/finance/intelligence/driver/$driverId',
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

  static Map<String, dynamic>? snapshotMap(dynamic response) {
    final m = getJsonField(response, r'''$.data.snapshot''', true);
    if (m is Map<String, dynamic>) return m;
    if (m is Map) return Map<String, dynamic>.from(m);
    return null;
  }
}

/// GET `/api/admins/finance/audit-view`
class GetAdminFinanceAuditViewCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    int page = 1,
    int limit = 40,
    String? action,
  }) async {
    final params = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (action != null && action.trim().isNotEmpty)
      params['action'] = action.trim();
    return ApiManager.instance.makeApiCall(
      callName: 'getAdminFinanceAuditView',
      apiUrl: '${ApiConfig.apiBase}/admins/finance/audit-view',
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

  static List<dynamic> entriesList(dynamic response) {
    final list = getJsonField(response, r'''$.data.entries''', true) as List?;
    if (list != null) return List<dynamic>.from(list);
    return const [];
  }
}

/// GET `/api/admins/payouts` — unified payout queue (same `payouts` table).
class GetAdminUnifiedPayoutsCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    int page = 1,
    int limit = 50,
    String? status,
  }) async {
    final params = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null && status.trim().isNotEmpty && status != 'all') {
      params['status'] = status.trim();
    }
    return ApiManager.instance.makeApiCall(
      callName: 'getAdminUnifiedPayouts',
      apiUrl: '${ApiConfig.apiBase}/admins/payouts',
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

  static List<dynamic> payoutsList(dynamic response) {
    final list = getJsonField(response, r'''$.data.payouts''', true) as List?;
    if (list != null && list.isNotEmpty) return List<dynamic>.from(list);
    return const [];
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
