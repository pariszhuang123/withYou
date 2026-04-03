import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/contracts/call_flow_contracts.dart';
import 'package:with_you/contracts/commerce_contracts.dart';
import 'package:with_you/contracts/readiness_contracts.dart';
import 'package:with_you/services/widget_support_service.dart';

class _TestSceneReadinessContract implements SceneReadinessContract {
  _TestSceneReadinessContract(this._snapshots);

  final Map<Scenario, SceneReadinessSnapshot> _snapshots;

  @override
  Future<List<SceneReadinessSnapshot>> getAllReadiness() async {
    return _snapshots.values.toList(growable: false);
  }

  @override
  Future<SceneReadinessSnapshot> getReadiness(Scenario scenario) async {
    return _snapshots[scenario]!;
  }
}

class _TestPaywallContract implements PaywallContract {
  _TestPaywallContract(this.decision);

  final PaywallDecision decision;

  @override
  Future<PaywallDecision> evaluate({required PaywallSurface surface}) async {
    return decision;
  }

  @override
  Future<void> recordDismissed({required PaywallSurface surface}) async {}
}

void main() {
  WidgetSupportService buildService({
    required Map<Scenario, SceneReadinessSnapshot> snapshots,
    PaywallDecision paywallDecision = PaywallDecision.hidden,
  }) {
    return WidgetSupportService(
      sceneReadinessContract: _TestSceneReadinessContract(snapshots),
      paywallContract: _TestPaywallContract(paywallDecision),
    );
  }

  test(
    'getAvailability reports premium requirement when widget setup is gated',
    () async {
      final service = buildService(
        snapshots: {
          Scenario.presence: const SceneReadinessSnapshot(
            scenario: Scenario.presence,
            state: SceneReadinessState.ready,
          ),
        },
        paywallDecision: PaywallDecision.showFeatureGate,
      );

      final availability = await service.getAvailability();

      expect(availability.state, WidgetAvailabilityState.requiresPremium);
      expect(availability.supportsDirectPickerLaunch, isFalse);
    },
  );

  test(
    'planLaunch launches the selected scene when readiness is ready',
    () async {
      final service = buildService(
        snapshots: {
          Scenario.socialPull: const SceneReadinessSnapshot(
            scenario: Scenario.socialPull,
            state: SceneReadinessState.ready,
          ),
        },
      );

      final plan = await service.planLaunch(
        surface: LaunchSurface.homeScreenWidget,
        selectedScenario: Scenario.socialPull,
      );

      expect(plan.outcome, WidgetLaunchOutcome.launchSelectedScene);
      expect(plan.resolvedScenario, Scenario.socialPull);
      expect(plan.showFallbackMessage, isFalse);
    },
  );

  test(
    'planLaunch falls back to presence when selected widget scenario is not ready',
    () async {
      final service = buildService(
        snapshots: {
          Scenario.exitPressure: const SceneReadinessSnapshot(
            scenario: Scenario.exitPressure,
            state: SceneReadinessState.lockedPremium,
          ),
        },
      );

      final plan = await service.planLaunch(
        surface: LaunchSurface.homeScreenWidget,
        selectedScenario: Scenario.exitPressure,
      );

      expect(plan.outcome, WidgetLaunchOutcome.fallbackToPresence);
      expect(plan.requestedScenario, Scenario.exitPressure);
      expect(plan.resolvedScenario, Scenario.presence);
      expect(plan.showFallbackMessage, isTrue);
    },
  );
}
