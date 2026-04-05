import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../contracts/app_contracts.dart';
import '../contracts/call_flow_contracts.dart';
import '../contracts/commerce_contracts.dart';
import '../contracts/readiness_contracts.dart';
import '../screens/call_flow_screen.dart';
import '../screens/home_screen.dart';
import '../screens/paywall_screen.dart';
import '../screens/settings_screen.dart';

class AppRouterService implements AppRouterContract {
  AppRouterService({
    required String appName,
    required AppStateContract appStateContract,
    required CallTemplateContract callTemplateContract,
    required NotificationReadinessContract notificationReadinessContract,
    required PremiumAccessContract premiumAccessContract,
    required PaywallContract paywallContract,
  }) : _appStateContract = appStateContract,
       _callTemplateContract = callTemplateContract,
       _notificationReadinessContract = notificationReadinessContract,
       _premiumAccessContract = premiumAccessContract,
       _paywallContract = paywallContract {
    _router = GoRouter(
      initialLocation: _homePath,
      routes: <RouteBase>[
        GoRoute(
          path: _homePath,
          builder: (context, state) => HomeScreen(
            notificationReadinessContract: _notificationReadinessContract,
            paywallContract: _paywallContract,
            onOpenSettings: () {
              openSettings();
            },
            onOpenPaywall: (scenario) => openPaywall(scenario: scenario),
          ),
        ),
        GoRoute(
          path: _settingsPath,
          builder: (context, state) => SettingsScreen(
            notificationReadinessContract: _notificationReadinessContract,
            premiumAccessContract: _premiumAccessContract,
            paywallContract: _paywallContract,
            onOpenPaywall: (scenario) => openPaywall(scenario: scenario),
          ),
        ),
        GoRoute(
          path: _paywallPath,
          builder: (context, state) => PaywallScreen(
            premiumAccessContract: _premiumAccessContract,
            focusedScenario: _scenarioFromName(
              state.uri.queryParameters[_scenarioQuery],
            ),
          ),
        ),
        GoRoute(
          path: _callPath,
          builder: (context, state) => CallFlowScreen(
            appName: appName,
            callTemplateContract: _callTemplateContract,
          ),
        ),
      ],
    );
    _currentRoute = const AppRouteState.home();
    _router.routerDelegate.addListener(_handleRouterDelegateChanged);
  }

  static const String _homePath = '/';
  static const String _settingsPath = '/settings';
  static const String _paywallPath = '/paywall';
  static const String _callPath = '/call';
  static const String _scenarioQuery = 'scenario';
  static const String _stageQuery = 'stage';
  static const String _sessionIdQuery = 'sessionId';
  static const String _sourceQuery = 'source';

  final AppStateContract _appStateContract;
  final CallTemplateContract _callTemplateContract;
  final NotificationReadinessContract _notificationReadinessContract;
  final PremiumAccessContract _premiumAccessContract;
  final PaywallContract _paywallContract;
  late final GoRouter _router;

  late AppRouteState _currentRoute;
  AppRouteState _lastNonCallRoute = const AppRouteState.home();
  bool _routerAttached = false;
  bool _applyingPendingExternalIntent = false;
  AppLaunchIntent? _pendingExternalIntent;

  @override
  RouterConfig<Object> get routerConfig => _router;

  @override
  AppRouteState get currentRoute => _currentRoute;

  @override
  Future<void> goHome() async {
    _lastNonCallRoute = const AppRouteState.home();
    _currentRoute = const AppRouteState.home();
    _router.go(_homePath);
  }

  @override
  Future<void> openSettings() async {
    const route = AppRouteState(destination: AppRouteDestination.settings);
    _lastNonCallRoute = route;
    _currentRoute = route;
    await _router.push(_settingsPath);
  }

  @override
  Future<bool> openPaywall({
    Scenario? scenario,
    AppLaunchIntent? intent,
  }) async {
    if (intent case final AppLaunchIntent resolvedIntent) {
      await _persistIntentScenario(resolvedIntent);
    }

    final route = AppRouteState(
      destination: AppRouteDestination.paywall,
      scenario: scenario ?? intent?.scenario,
      stage: intent?.stage,
      sessionId: intent?.sessionId,
    );
    _lastNonCallRoute = route;
    _currentRoute = route;
    final result = await _router.push<bool>(_paywallLocation(route));
    _syncCurrentRouteFromRouter();
    return result ?? false;
  }

  @override
  Future<void> syncCallRoute({
    required bool visible,
    Scenario? scenario,
    int? stage,
    String? sessionId,
    AppLaunchIntent? intent,
  }) async {
    if (intent case final AppLaunchIntent resolvedIntent) {
      await _persistIntentScenario(resolvedIntent);
    }

    if (visible) {
      final route = AppRouteState(
        destination: AppRouteDestination.call,
        scenario: scenario ?? intent?.scenario,
        stage: stage ?? intent?.stage,
        sessionId: sessionId ?? intent?.sessionId,
      );
      final location = _callLocation(route, intent);
      final currentLocation = _router.routeInformationProvider.value.uri
          .toString();
      if (currentLocation == location) {
        _currentRoute = route;
        return;
      }

      _currentRoute = route;
      final isExternal =
          intent?.source == AppLaunchSource.notification ||
          intent?.source == AppLaunchSource.homeScreenWidget;
      if (isExternal) {
        _router.go(location);
        _syncCurrentRouteFromRouter();
        return;
      }
      await _router.push(location);
      _syncCurrentRouteFromRouter();
      return;
    }

    if (_currentRoute.destination != AppRouteDestination.call) {
      return;
    }

    if (_router.canPop()) {
      _router.pop();
    } else {
      _router.go(_homePath);
    }
    _currentRoute = _lastNonCallRoute;
  }

  @override
  Future<void> handleExternalIntent(AppLaunchIntent intent) async {
    if (!_routerAttached) {
      _pendingExternalIntent = intent;
      await _persistIntentScenario(intent);
      _currentRoute = AppRouteState(
        destination: intent.destination,
        scenario: intent.scenario,
        stage: intent.stage,
        sessionId: intent.sessionId,
      );
      return;
    }

    await _dispatchExternalIntent(intent);
  }

  void _handleRouterDelegateChanged() {
    _routerAttached = true;
    _syncCurrentRouteFromRouter();

    final pendingIntent = _pendingExternalIntent;
    if (pendingIntent == null || _applyingPendingExternalIntent) {
      return;
    }

    _pendingExternalIntent = null;
    _applyingPendingExternalIntent = true;
    Future<void>(() async {
      try {
        await _dispatchExternalIntent(pendingIntent);
      } finally {
        _applyingPendingExternalIntent = false;
      }
    });
  }

  Future<void> _dispatchExternalIntent(AppLaunchIntent intent) async {
    await _persistIntentScenario(intent);

    switch (intent.destination) {
      case AppRouteDestination.home:
        await goHome();
      case AppRouteDestination.settings:
        await openSettings();
      case AppRouteDestination.paywall:
        await openPaywall(scenario: intent.scenario, intent: intent);
      case AppRouteDestination.call:
        await syncCallRoute(
          visible: true,
          scenario: intent.scenario,
          stage: intent.stage,
          sessionId: intent.sessionId,
          intent: intent,
        );
    }
  }

  void _syncCurrentRouteFromRouter() {
    final location = _router.routeInformationProvider.value.uri;
    final scenario = _scenarioFromName(
      location.queryParameters[_scenarioQuery],
    );
    final stage = int.tryParse(location.queryParameters[_stageQuery] ?? '');
    final sessionId = location.queryParameters[_sessionIdQuery];

    _currentRoute = switch (location.path) {
      _settingsPath => const AppRouteState(
        destination: AppRouteDestination.settings,
      ),
      _paywallPath => AppRouteState(
        destination: AppRouteDestination.paywall,
        scenario: scenario,
        stage: stage,
        sessionId: sessionId,
      ),
      _callPath => AppRouteState(
        destination: AppRouteDestination.call,
        scenario: scenario,
        stage: stage,
        sessionId: sessionId,
      ),
      _ => const AppRouteState.home(),
    };

    if (_currentRoute.destination != AppRouteDestination.call) {
      _lastNonCallRoute = _currentRoute;
    }
  }

  String _paywallLocation(AppRouteState route) {
    final queryParameters = <String, String>{};
    if (route.scenario != null) {
      queryParameters[_scenarioQuery] = route.scenario!.name;
    }

    return Uri(path: _paywallPath, queryParameters: queryParameters).toString();
  }

  String _callLocation(AppRouteState route, AppLaunchIntent? intent) {
    final queryParameters = <String, String>{};
    if (route.scenario != null) {
      queryParameters[_scenarioQuery] = route.scenario!.name;
    }
    if (route.stage != null) {
      queryParameters[_stageQuery] = route.stage!.toString();
    }
    if (route.sessionId != null) {
      queryParameters[_sessionIdQuery] = route.sessionId!;
    }
    if (intent != null) {
      queryParameters[_sourceQuery] = intent.source.name;
    }

    return Uri(path: _callPath, queryParameters: queryParameters).toString();
  }

  Future<void> _persistIntentScenario(AppLaunchIntent intent) async {
    final scenario = intent.scenario;
    if (scenario == null) {
      return;
    }
    await _appStateContract.setSelectedScenario(scenario);
  }

  static Scenario? _scenarioFromName(String? rawScenario) {
    if (rawScenario == null || rawScenario.isEmpty) {
      return null;
    }
    for (final scenario in Scenario.values) {
      if (scenario.name == rawScenario) {
        return scenario;
      }
    }
    return null;
  }
}
