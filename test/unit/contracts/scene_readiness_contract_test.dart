import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/contracts/call_flow_contracts.dart';
import 'package:with_you/contracts/readiness_contracts.dart';

void main() {
  test('scene readiness snapshot carries fallback defaults', () {
    const snapshot = SceneReadinessSnapshot(
      scenario: Scenario.socialPull,
      state: SceneReadinessState.needsNotification,
    );

    expect(snapshot.scenario, Scenario.socialPull);
    expect(snapshot.state, SceneReadinessState.needsNotification);
    expect(snapshot.fallsBackToPresence, isTrue);
  });
}
