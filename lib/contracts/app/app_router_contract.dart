import 'package:flutter/widgets.dart';

import '../call_flow/fake_call_timing_contract.dart';

enum AppRouteDestination { home, settings, paywall, call }

enum AppLaunchSource { inApp, notification, homeScreenWidget, appleWatch }

class AppLaunchIntent {
  const AppLaunchIntent({
    required this.source,
    required this.destination,
    this.scenario,
    this.stage,
    this.sessionId,
  });

  final AppLaunchSource source;
  final AppRouteDestination destination;
  final Scenario? scenario;
  final int? stage;
  final String? sessionId;
}

class AppRouteState {
  const AppRouteState({
    required this.destination,
    this.scenario,
    this.stage,
    this.sessionId,
  });

  const AppRouteState.home()
    : destination = AppRouteDestination.home,
      scenario = null,
      stage = null,
      sessionId = null;

  final AppRouteDestination destination;
  final Scenario? scenario;
  final int? stage;
  final String? sessionId;
}

abstract class AppRouterContract {
  RouterConfig<Object> get routerConfig;

  AppRouteState get currentRoute;

  Future<void> goHome();

  Future<void> openSettings();

  Future<bool> openPaywall({Scenario? scenario, AppLaunchIntent? intent});

  Future<void> syncCallRoute({
    required bool visible,
    Scenario? scenario,
    int? stage,
    String? sessionId,
    AppLaunchIntent? intent,
  });

  Future<void> handleExternalIntent(AppLaunchIntent intent);
}
