import '../contracts/call_flow_contracts.dart';
import '../contracts/commerce_contracts.dart';
import '../contracts/readiness_contracts.dart';

class WidgetSupportService
    implements WidgetAvailabilityContract, WidgetLaunchContract {
  const WidgetSupportService({
    required SceneReadinessContract sceneReadinessContract,
    required PaywallContract paywallContract,
  }) : _sceneReadinessContract = sceneReadinessContract,
       _paywallContract = paywallContract;

  final SceneReadinessContract _sceneReadinessContract;
  final PaywallContract _paywallContract;

  @override
  Future<WidgetAvailability> getAvailability() async {
    final paywallDecision = await _paywallContract.evaluate(
      surface: PaywallSurface.widgetSetup,
    );

    if (paywallDecision == PaywallDecision.hidden) {
      return const WidgetAvailability(state: WidgetAvailabilityState.available);
    }

    return const WidgetAvailability(
      state: WidgetAvailabilityState.requiresPremium,
    );
  }

  @override
  Future<WidgetLaunchPlan> planLaunch({
    required LaunchSurface surface,
    required Scenario selectedScenario,
  }) async {
    final readiness = await _sceneReadinessContract.getReadiness(
      selectedScenario,
    );

    if (readiness.state == SceneReadinessState.ready) {
      return WidgetLaunchPlan(
        outcome: WidgetLaunchOutcome.launchSelectedScene,
        requestedScenario: selectedScenario,
        resolvedScenario: selectedScenario,
      );
    }

    if (surface == LaunchSurface.appButton &&
        readiness.state == SceneReadinessState.lockedPremium) {
      final paywallDecision = await _paywallContract.evaluate(
        surface: PaywallSurface.widgetSetup,
      );
      if (paywallDecision != PaywallDecision.hidden &&
          !readiness.fallsBackToPresence) {
        return WidgetLaunchPlan(
          outcome: WidgetLaunchOutcome.openPremiumScreen,
          requestedScenario: selectedScenario,
          resolvedScenario: selectedScenario,
        );
      }
    }

    return WidgetLaunchPlan(
      outcome: WidgetLaunchOutcome.fallbackToPresence,
      requestedScenario: selectedScenario,
      resolvedScenario: Scenario.presence,
      showFallbackMessage: selectedScenario != Scenario.presence,
    );
  }
}
