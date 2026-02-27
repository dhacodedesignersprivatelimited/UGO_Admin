import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _accesstoken = prefs.getString('ff_accesstoken') ?? _accesstoken;
    });
    _safeInit(() {
      _refreshToken = prefs.getString('ff_refreshToken') ?? _refreshToken;
    });
    _safeInit(() {
      _totalrides = prefs.getString('ff_totalrides') ?? _totalrides;
    });
    _safeInit(() {
      _activeDrivers = prefs.getString('ff_activeDrivers') ?? _activeDrivers;
    });
    _safeInit(() {
      _totalUsers = prefs.getString('ff_totalUsers') ?? _totalUsers;
    });
    _safeInit(() {
      _totalEarnings = prefs.getString('ff_totalEarnings') ?? _totalEarnings;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  String _accesstoken = '';
  String get accesstoken => _accesstoken;
  set accesstoken(String value) {
    _accesstoken = value;
    prefs.setString('ff_accesstoken', value);
  }

  String _refreshToken = '';
  String get refreshToken => _refreshToken;
  set refreshToken(String value) {
    _refreshToken = value;
    prefs.setString('ff_refreshToken', value);
  }

  String _totalrides = '';
  String get totalrides => _totalrides;
  set totalrides(String value) {
    _totalrides = value;
    prefs.setString('ff_totalrides', value);
  }

  String _activeDrivers = '';
  String get activeDrivers => _activeDrivers;
  set activeDrivers(String value) {
    _activeDrivers = value;
    prefs.setString('ff_activeDrivers', value);
  }

  String _totalUsers = '';
  String get totalUsers => _totalUsers;
  set totalUsers(String value) {
    _totalUsers = value;
    prefs.setString('ff_totalUsers', value);
  }

  String _totalEarnings = '';
  String get totalEarnings => _totalEarnings;
  set totalEarnings(String value) {
    _totalEarnings = value;
    prefs.setString('ff_totalEarnings', value);
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

