import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/contracts/commerce_contracts.dart';
import 'package:with_you/contracts/readiness_contracts.dart';
import 'package:with_you/contracts/call_flow_contracts.dart';
import 'package:with_you/services/scene_readiness_service.dart';

class _TestNotificationReadinessContract
    implements NotificationReadinessContract {
  _TestNotificationReadinessContract(this.state);

  final NotificationReadinessState state;

  @override
  Future<NotificationReadinessState> getReadiness() async => state;

  @override
  Future<NotificationReadinessState> requestPermission() async => state;

  @override
  Future<void> openSystemSettings() async {}
}

class _TestPremiumAccessContract implements PremiumAccessContract {
  _TestPremiumAccessContract(this.state);

  final PremiumAccessState state;

  @override
  Future<PremiumAccessState> getAccessState() async => state;

  @override
  Future<void> recordPurchase() async {}

  @override
  Future<void> refresh() async {}

  @override
  Future<void> restorePurchases() async {}
}

void main() {
  test('presence is always ready', () async {
    final service = SceneReadinessService(
      notificationReadinessContract: _TestNotificationReadinessContract(
        NotificationReadinessState.needsPermission,
      ),
      premiumAccessContract: _TestPremiumAccessContract(
        PremiumAccessState.inactive,
      ),
    );

    final snapshot = await service.getReadiness(Scenario.presence);
    expect(snapshot.state, SceneReadinessState.ready);
  });

  test('premium scenes need notifications before premium unlock', () async {
    final service = SceneReadinessService(
      notificationReadinessContract: _TestNotificationReadinessContract(
        NotificationReadinessState.needsPermission,
      ),
      premiumAccessContract: _TestPremiumAccessContract(
        PremiumAccessState.active,
      ),
    );

    final snapshot = await service.getReadiness(Scenario.socialPull);
    expect(snapshot.state, SceneReadinessState.needsNotification);
  });

  test('premium scenes lock when notifications are ready but premium is inactive', () async {
    final service = SceneReadinessService(
      notificationReadinessContract: _TestNotificationReadinessContract(
        NotificationReadinessState.ready,
      ),
      premiumAccessContract: _TestPremiumAccessContract(
        PremiumAccessState.inactive,
      ),
    );

    final snapshot = await service.getReadiness(Scenario.exitPressure);
    expect(snapshot.state, SceneReadinessState.lockedPremium);
  });
}
