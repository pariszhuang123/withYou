import '../call_flow/fake_call_timing_contract.dart';

enum SceneReadinessState { ready, needsNotification, lockedPremium }

class SceneReadinessSnapshot {
  const SceneReadinessSnapshot({
    required this.scenario,
    required this.state,
    this.fallsBackToPresence = true,
  });

  final Scenario scenario;
  final SceneReadinessState state;
  final bool fallsBackToPresence;
}

abstract class SceneReadinessContract {
  Future<SceneReadinessSnapshot> getReadiness(Scenario scenario);

  Future<List<SceneReadinessSnapshot>> getAllReadiness();
}
