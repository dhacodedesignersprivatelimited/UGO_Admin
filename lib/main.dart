import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import '/core/auth/auth_util.dart';
import '/core/auth/custom_auth_user_provider.dart';
import '/core/firebase/firebase_config.dart';
import '/config/theme/flutter_flow_theme.dart';
import '/config/theme/flutter_flow_util.dart';
import '/config/routes/nav.dart';
import '/config/routes/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  await initFirebase();

  await FlutterFlowTheme.initialize();

  await authManager.initialize();

  final appState = FFAppState();
  await appState.initializePersistedState();

  runApp(
    // ProviderScope is the Riverpod equivalent of MultiBlocProvider.
    // All StateNotifierProvider / Provider instances are resolved lazily
    // within this scope — no manual registration needed.
    ProviderScope(
      child: provider.ChangeNotifierProvider(
        create: (context) => appState,
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();
  late Stream<UgoAdminAuthUser> userStream;

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    userStream = ugoAdminAuthUserStream()
      ..listen((user) {
        _appStateNotifier.update(user);
        // Stop splash as soon as we have user state
        _appStateNotifier.stopShowingSplashImage();
      });

    // Fallback: stop splash after 500ms if stream hasn't fired
    Future.delayed(
      const Duration(milliseconds: 500),
      () => _appStateNotifier.stopShowingSplashImage(),
    );
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'ugoAdmin',
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', '')],
        theme: ThemeData(
          brightness: Brightness.light,
          useMaterial3: false,
          primaryColor: const Color(0xFFFF6B35),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF6B35),
            brightness: Brightness.light,
            primary: const Color(0xFFFF6B35),
            secondary: const Color(0xFFFF8F65),
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: false,
          primaryColor: const Color(0xFFFF6B35),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF6B35),
            brightness: Brightness.dark,
            primary: const Color(0xFFFF6B35),
            secondary: const Color(0xFFFF8F65),
          ),
        ),
        themeMode: _themeMode,
        routerConfig: _router,
      ),
    );
  }
}
