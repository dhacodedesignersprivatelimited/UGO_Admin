import 'package:rxdart/rxdart.dart';

import '/shared/models/structs/index.dart';
import 'custom_auth_manager.dart';

class UgoAdminAuthUser {
  UgoAdminAuthUser({
    required this.loggedIn,
    this.uid,
    this.userData,
  });

  bool loggedIn;
  String? uid;
  UserStruct? userData;
}

/// Generates a stream of the authenticated user.
BehaviorSubject<UgoAdminAuthUser> ugoAdminAuthUserSubject =
    BehaviorSubject.seeded(UgoAdminAuthUser(loggedIn: false));
Stream<UgoAdminAuthUser> ugoAdminAuthUserStream() => ugoAdminAuthUserSubject
    .asBroadcastStream()
    .map((user) => currentUser = user);
