import '../contracts/call_flow_contracts.dart';
import '../contracts/commerce_contracts.dart';
import '../contracts/readiness_contracts.dart';

class SceneReadinessService implements SceneReadinessContract {
  const SceneReadinessService({
    required NotificationReadinessContract notificationReadinessContract,
    required PremiumAccessContract premiumAccessContract,
  }) : _notificationReadinessContract = notificationReadinessContract,
       _premiumAccessContract = premiumAccessContract;

  final NotificationReadinessContract _notificationReadinessContract;
  final PremiumAccessContract _premiumAccessContract;

  @override
  Future<List<SceneReadinessSnapshot>> getAllReadiness() async {
    final notificationReadiness = await _notificationReadinessContract
        .getReadiness();
    final premiumAccessState = await _premiumAccessContract.getAccessState();

    return Scenario.values
        .map(
          (scenario) => _resolveReadiness(
            scenario: scenario,
            notificationReadiness: notificationReadiness,
            premiumAccessState: premiumAccessState,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<SceneReadinessSnapshot> getReadiness(Scenario scenario) async {
    final notificationReadiness = await _notificationReadinessContract
        .getReadiness();
    final premiumAccessState = await _premiumAccessContract.getAccessState();
    return _resolveReadiness(
      scenario: scenario,
      notificationReadiness: notificationReadiness,
      premiumAccessState: premiumAccessState,
    );
  }

  SceneReadinessSnapshot _resolveReadiness({
    required Scenario scenario,
    required NotificationReadinessState notificationReadiness,
    required PremiumAccessState premiumAccessState,
  }) {
    if (scenario == Scenario.presence) {
      return const SceneReadinessSnapshot(
        scenario: Scenario.presence,
        state: SceneReadinessState.ready,
      );
    }

    if (notificationReadiness != NotificationReadinessState.ready) {
      return SceneReadinessSnapshot(
        scenario: scenario,
        state: SceneReadinessState.needsNotification,
      );
    }

    if (premiumAccessState != PremiumAccessState.active) {
      return SceneReadinessSnapshot(
        scenario: scenario,
        state: SceneReadinessState.lockedPremium,
      );
    }

    return SceneReadinessSnapshot(
      scenario: scenario,
      state: SceneReadinessState.ready,
    );
  }
}
