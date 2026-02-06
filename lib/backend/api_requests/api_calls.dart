import 'dart:convert';
import 'dart:typed_data';
import '../schema/structs/index.dart';

import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

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
      apiUrl: 'https://ugotaxi.icacorp.org/api/admins/login',
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

  static dynamic? admin(dynamic response) => getJsonField(
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

class AddVehicleCall {
  static Future<ApiCallResponse> call({
    FFUploadedFile? vehicleImage,
    String? vehicleName = '',
    String? kmperPrice = '',
    String? vehicleType = '',
    String? seatingCapacity = '',
    String? luggageCapacity = '',
    String? token = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'addVehicle',
      apiUrl: 'http://www.ugotaxi.com/api/admins/vehicles',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
      },
      params: {
        'vehicle_image': vehicleImage,
        'vehicle_name': vehicleName,
        'kilometer_per_price': kmperPrice,
        'vehicle_type': vehicleType,
        'seating_capacity': seatingCapacity,
        'luggage_capacity': luggageCapacity,
      },
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
      apiUrl: 'http://www.ugotaxi.com/api/admins/rides-analytics',
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

  static dynamic? data(dynamic response) => getJsonField(
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
          'http://www.ugotaxi.com/api/admins/earnings-analytics?period=weekly',
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

  static dynamic? data(dynamic response) => getJsonField(
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
      apiUrl: 'http://www.ugotaxi.com/api/admins/active-drivers',
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

  static dynamic? data(dynamic response) => getJsonField(
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
      apiUrl: 'http://www.ugotaxi.com/api/admins/all-users',
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

  static dynamic? data(dynamic response) => getJsonField(
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

class GetDriversCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    int? userid,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'get drivers',
      apiUrl: 'http://www.ugotaxi.com/api/drivers/getall',
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
  static Future<ApiCallResponse> call({
    int? driverId,
    String? verificarionSrarus = '',
    String? token = '',
  }) async {
    final ffApiRequestBody = '''
{
  "driver_id": ${driverId},
  "verification_status": "${escapeStringForJson(verificarionSrarus)}",
  "notes": "All documents verified"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'verifyDocs',
      apiUrl: 'http://www.ugotaxi.com/api/admins/verify-driver-documents',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
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
}

class DashBoardCall {
  static Future<ApiCallResponse> call({
    String? token = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'dashBoard',
      apiUrl: 'http://www.ugotaxi.com/api/admins/dashboard',
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
  static dynamic? data(dynamic response) => getJsonField(
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
      apiUrl: 'https://ugotaxi.icacorp.org/api/drivers/${id}',
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

  static dynamic? data(dynamic response) => getJsonField(
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
