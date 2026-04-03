import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/contracts/app_contracts.dart';
import 'package:with_you/contracts/call_flow_contracts.dart';
import 'package:with_you/contracts/platform_contracts.dart';
import 'package:with_you/contracts/readiness_contracts.dart';
import 'package:with_you/services/app_widget_launch_service.dart';

class _TestWidgetLaunchEventContract implements WidgetLaunchEventContract {
  _TestWidgetLaunchEventContract() {
    _controller = StreamController<WidgetLaunchEvent>.broadcast();
  }

  late final StreamController<WidgetLaunchEvent> _controller;

  @override
  Stream<WidgetLaunchEvent> get eventStream => _controller.stream;

  void emit(WidgetLaunchEvent event) {
    _controller.add(event);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}

class _TestWidgetLaunchContract implements WidgetLaunchContract {
  _TestWidgetLaunchContract(this.plan);

  final WidgetLaunchPlan plan;

  LaunchSurface? lastSurface;
  Scenario? lastScenario;

  @override
  Future<WidgetLaunchPlan> planLaunch({
    required LaunchSurface surface,
    required Scenario selectedScenario,
  }) async {
    lastSurface = surface;
    lastScenario = selectedScenario;
    return plan;
  }
}

class _TestAppStateContract implements AppStateContract {
  _TestAppStateContract({this.selectedScenario});

  Scenario? selectedScenario;

  @override
  Future<String?> getSelectedAudioLocaleTag() async => null;

  @override
  Future<Scenario?> getSelectedScenario() async => selectedScenario;

  @override
  Future<bool> hasPremiumAccess() async => false;

  @override
  Future<void> setPremiumAccess(bool hasPremiumAccess) async {}

  @override
  Future<void> setSelectedAudioLocaleTag(String localeTag) async {}

  @override
  Future<void> setSelectedScenario(Scenario scenario) async {
    selectedScenario = scenario;
  }
}

class _TestCallFlowCoordinatorContract implements CallFlowCoordinatorContract {
  Scenario? lastStartedScenario;

  @override
  CallFlowSnapshot get currentSnapshot => CallFlowSnapshot.idle();

  @override
  Stream<CallFlowSnapshot> get snapshotStream =>
      const Stream<CallFlowSnapshot>.empty();

  @override
  Future<void> acceptCurrentStage() async {}

  @override
  Future<void> declineCurrentStage() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> endCurrentStage() async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> resumeFromNotification({
    required String sessionId,
    required Scenario scenario,
    required int stage,
  }) async {}

  @override
  Future<void> startFlow(Scenario scenario) async {
    lastStartedScenario = scenario;
  }

  @override
  Future<void> triggerFollowUpStage() async {}
}

class _TestAppRouterContract implements AppRouterContract {
  AppLaunchIntent? lastIntent;
  Scenario? paywallScenario;

  @override
  AppRouteState get currentRoute => const AppRouteState.home();

  @override
  Future<void> goHome() async {}

  @override
  Future<void> handleExternalIntent(AppLaunchIntent intent) async {
    lastIntent = intent;
  }

  @override
  Future<void> openSettings() async {}

  @override
  Future<bool> openPaywall({
    Scenario? scenario,
    AppLaunchIntent? intent,
  }) async {
    paywallScenario = scenario;
    lastIntent = intent;
    return false;
  }

  @override
  RouterConfig<Object> get routerConfig => throw UnimplementedError();

  @override
  Future<void> syncCallRoute({
    required bool visible,
    Scenario? scenario,
    int? stage,
    String? sessionId,
    AppLaunchIntent? intent,
  }) async {}
}

void main() {
  test(
    'widget tap starts a new flow and routes to call using the launch plan',
    () async {
      final platform = _TestWidgetLaunchEventContract();
      final launchContract = _TestWidgetLaunchContract(
        const WidgetLaunchPlan(
          outcome: WidgetLaunchOutcome.launchSelectedScene,
          requestedScenario: Scenario.socialPull,
          resolvedScenario: Scenario.socialPull,
        ),
      );
      final coordinator = _TestCallFlowCoordinatorContract();
      final router = _TestAppRouterContract();
      final service = AppWidgetLaunchService(
        widgetLaunchEventContract: platform,
        widgetLaunchContract: launchContract,
        appStateContract: _TestAppStateContract(
          selectedScenario: Scenario.presence,
        ),
        callFlowCoordinatorContract: coordinator,
        appRouterContract: router,
      );

      service.start();
      platform.emit(const WidgetLaunchEvent(scenario: Scenario.socialPull));
      await Future<void>.delayed(Duration.zero);

      expect(launchContract.lastSurface, LaunchSurface.homeScreenWidget);
      expect(launchContract.lastScenario, Scenario.socialPull);
      expect(coordinator.lastStartedScenario, Scenario.socialPull);
      expect(router.lastIntent?.source, AppLaunchSource.homeScreenWidget);
      expect(router.lastIntent?.destination, AppRouteDestination.call);
      expect(router.lastIntent?.scenario, Scenario.socialPull);

      await service.dispose();
      await platform.dispose();
    },
  );

  test(
    'widget tap falls back to stored selection when widget does not send a scenario',
    () async {
      final platform = _TestWidgetLaunchEventContract();
      final launchContract = _TestWidgetLaunchContract(
        const WidgetLaunchPlan(
          outcome: WidgetLaunchOutcome.fallbackToPresence,
          requestedScenario: Scenario.exitPressure,
          resolvedScenario: Scenario.presence,
        ),
      );
      final coordinator = _TestCallFlowCoordinatorContract();
      final router = _TestAppRouterContract();
      final service = AppWidgetLaunchService(
        widgetLaunchEventContract: platform,
        widgetLaunchContract: launchContract,
        appStateContract: _TestAppStateContract(
          selectedScenario: Scenario.exitPressure,
        ),
        callFlowCoordinatorContract: coordinator,
        appRouterContract: router,
      );

      service.start();
      platform.emit(const WidgetLaunchEvent(scenario: null));
      await Future<void>.delayed(Duration.zero);

      expect(launchContract.lastScenario, Scenario.exitPressure);
      expect(coordinator.lastStartedScenario, Scenario.presence);
      expect(router.lastIntent?.scenario, Scenario.presence);

      await service.dispose();
      await platform.dispose();
    },
  );

  test(
    'widget tap opens paywall when launch planning requires premium',
    () async {
      final platform = _TestWidgetLaunchEventContract();
      final launchContract = _TestWidgetLaunchContract(
        const WidgetLaunchPlan(
          outcome: WidgetLaunchOutcome.openPremiumScreen,
          requestedScenario: Scenario.socialPull,
          resolvedScenario: Scenario.socialPull,
        ),
      );
      final coordinator = _TestCallFlowCoordinatorContract();
      final router = _TestAppRouterContract();
      final service = AppWidgetLaunchService(
        widgetLaunchEventContract: platform,
        widgetLaunchContract: launchContract,
        appStateContract: _TestAppStateContract(
          selectedScenario: Scenario.presence,
        ),
        callFlowCoordinatorContract: coordinator,
        appRouterContract: router,
      );

      service.start();
      platform.emit(const WidgetLaunchEvent(scenario: Scenario.socialPull));
      await Future<void>.delayed(Duration.zero);

      expect(coordinator.lastStartedScenario, isNull);
      expect(router.paywallScenario, Scenario.socialPull);
      expect(router.lastIntent?.source, AppLaunchSource.homeScreenWidget);
      expect(router.lastIntent?.destination, AppRouteDestination.paywall);
      expect(router.lastIntent?.scenario, Scenario.socialPull);

      await service.dispose();
      await platform.dispose();
    },
  );
}
