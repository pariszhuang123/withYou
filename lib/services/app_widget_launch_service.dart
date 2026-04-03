import 'dart:async';

import '../contracts/app_contracts.dart';
import '../contracts/call_flow_contracts.dart';
import '../contracts/platform_contracts.dart';
import '../contracts/readiness_contracts.dart';

class AppWidgetLaunchService {
  AppWidgetLaunchService({
    required WidgetLaunchEventContract widgetLaunchEventContract,
    required WidgetLaunchContract widgetLaunchContract,
    required AppStateContract appStateContract,
    required CallFlowCoordinatorContract callFlowCoordinatorContract,
    required AppRouterContract appRouterContract,
  }) : _widgetLaunchEventContract = widgetLaunchEventContract,
       _widgetLaunchContract = widgetLaunchContract,
       _appStateContract = appStateContract,
       _callFlowCoordinatorContract = callFlowCoordinatorContract,
       _appRouterContract = appRouterContract;

  final WidgetLaunchEventContract _widgetLaunchEventContract;
  final WidgetLaunchContract _widgetLaunchContract;
  final AppStateContract _appStateContract;
  final CallFlowCoordinatorContract _callFlowCoordinatorContract;
  final AppRouterContract _appRouterContract;

  StreamSubscription<WidgetLaunchEvent>? _subscription;

  void start() {
    _subscription ??= _widgetLaunchEventContract.eventStream.listen(
      _handleEvent,
    );
  }

  Future<void> _handleEvent(WidgetLaunchEvent event) async {
    final requestedScenario =
        event.scenario ??
        await _appStateContract.getSelectedScenario() ??
        Scenario.presence;
    final plan = await _widgetLaunchContract.planLaunch(
      surface: LaunchSurface.homeScreenWidget,
      selectedScenario: requestedScenario,
    );

    switch (plan.outcome) {
      case WidgetLaunchOutcome.launchSelectedScene:
      case WidgetLaunchOutcome.fallbackToPresence:
        await _callFlowCoordinatorContract.startFlow(plan.resolvedScenario);
        await _appRouterContract.handleExternalIntent(
          AppLaunchIntent(
            source: AppLaunchSource.homeScreenWidget,
            destination: AppRouteDestination.call,
            scenario: plan.resolvedScenario,
          ),
        );
      case WidgetLaunchOutcome.openPremiumScreen:
        await _appRouterContract.openPaywall(
          scenario: plan.requestedScenario,
          intent: AppLaunchIntent(
            source: AppLaunchSource.homeScreenWidget,
            destination: AppRouteDestination.paywall,
            scenario: plan.requestedScenario,
          ),
        );
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
