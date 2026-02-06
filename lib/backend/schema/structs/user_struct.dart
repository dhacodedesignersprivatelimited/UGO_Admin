// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UserStruct extends BaseStruct {
  UserStruct({
    String? accessToken,
    String? refreshtoken,
    String? totalRides,
  })  : _accessToken = accessToken,
        _refreshtoken = refreshtoken,
        _totalRides = totalRides;

  // "accessToken" field.
  String? _accessToken;
  String get accessToken => _accessToken ?? '';
  set accessToken(String? val) => _accessToken = val;

  bool hasAccessToken() => _accessToken != null;

  // "refreshtoken" field.
  String? _refreshtoken;
  String get refreshtoken => _refreshtoken ?? '';
  set refreshtoken(String? val) => _refreshtoken = val;

  bool hasRefreshtoken() => _refreshtoken != null;

  // "totalRides" field.
  String? _totalRides;
  String get totalRides => _totalRides ?? '';
  set totalRides(String? val) => _totalRides = val;

  bool hasTotalRides() => _totalRides != null;

  static UserStruct fromMap(Map<String, dynamic> data) => UserStruct(
        accessToken: data['accessToken'] as String?,
        refreshtoken: data['refreshtoken'] as String?,
        totalRides: data['totalRides'] as String?,
      );

  static UserStruct? maybeFromMap(dynamic data) =>
      data is Map ? UserStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'accessToken': _accessToken,
        'refreshtoken': _refreshtoken,
        'totalRides': _totalRides,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'accessToken': serializeParam(
          _accessToken,
          ParamType.String,
        ),
        'refreshtoken': serializeParam(
          _refreshtoken,
          ParamType.String,
        ),
        'totalRides': serializeParam(
          _totalRides,
          ParamType.String,
        ),
      }.withoutNulls;

  static UserStruct fromSerializableMap(Map<String, dynamic> data) =>
      UserStruct(
        accessToken: deserializeParam(
          data['accessToken'],
          ParamType.String,
          false,
        ),
        refreshtoken: deserializeParam(
          data['refreshtoken'],
          ParamType.String,
          false,
        ),
        totalRides: deserializeParam(
          data['totalRides'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'UserStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is UserStruct &&
        accessToken == other.accessToken &&
        refreshtoken == other.refreshtoken &&
        totalRides == other.totalRides;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([accessToken, refreshtoken, totalRides]);
}

UserStruct createUserStruct({
  String? accessToken,
  String? refreshtoken,
  String? totalRides,
}) =>
    UserStruct(
      accessToken: accessToken,
      refreshtoken: refreshtoken,
      totalRides: totalRides,
    );
