import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/contracts/call_flow_contracts.dart';
import 'package:with_you/contracts/readiness_contracts.dart';

void main() {
  test('widget availability defaults to manual picker behavior', () {
    const availability = WidgetAvailability(
      state: WidgetAvailabilityState.available,
    );

    expect(availability.state, WidgetAvailabilityState.available);
    expect(availability.supportsDirectPickerLaunch, isFalse);
  });

  test('widget launch plan can express fallback behavior', () {
    const plan = WidgetLaunchPlan(
      outcome: WidgetLaunchOutcome.fallbackToPresence,
      requestedScenario: Scenario.exitPressure,
      resolvedScenario: Scenario.presence,
      showFallbackMessage: true,
    );

    expect(plan.outcome, WidgetLaunchOutcome.fallbackToPresence);
    expect(plan.requestedScenario, Scenario.exitPressure);
    expect(plan.resolvedScenario, Scenario.presence);
    expect(plan.showFallbackMessage, isTrue);
  });
}
