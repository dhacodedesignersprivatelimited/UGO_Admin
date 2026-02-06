// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class DashboardStruct extends BaseStruct {
  DashboardStruct({
    String? totalRides,
  }) : _totalRides = totalRides;

  // "totalRides" field.
  String? _totalRides;
  String get totalRides => _totalRides ?? '';
  set totalRides(String? val) => _totalRides = val;

  bool hasTotalRides() => _totalRides != null;

  static DashboardStruct fromMap(Map<String, dynamic> data) => DashboardStruct(
        totalRides: data['totalRides'] as String?,
      );

  static DashboardStruct? maybeFromMap(dynamic data) => data is Map
      ? DashboardStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'totalRides': _totalRides,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'totalRides': serializeParam(
          _totalRides,
          ParamType.String,
        ),
      }.withoutNulls;

  static DashboardStruct fromSerializableMap(Map<String, dynamic> data) =>
      DashboardStruct(
        totalRides: deserializeParam(
          data['totalRides'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'DashboardStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is DashboardStruct && totalRides == other.totalRides;
  }

  @override
  int get hashCode => const ListEquality().hash([totalRides]);
}

DashboardStruct createDashboardStruct({
  String? totalRides,
}) =>
    DashboardStruct(
      totalRides: totalRides,
    );
