import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/contracts/call_flow_contracts.dart';
import 'package:with_you/contracts/readiness_contracts.dart';
import 'package:with_you/services/notification_readiness_service.dart';

class _TestNotificationContract implements NotificationContract {
  _TestNotificationContract(this.initialized);

  bool initialized;

  @override
  Stream<NotificationEvent> get eventStream =>
      const Stream<NotificationEvent>.empty();

  @override
  Future<void> cancelAll(String sessionId) async {}

  @override
  Future<bool> initialize() async => initialized;

  @override
  Future<void> scheduleFollowUp({
    required String sessionId,
    required Scenario scenario,
    required int stage,
    required Duration delay,
    required String callerName,
  }) async {}
}

void main() {
  test('maps initialized notification bridge to ready state', () async {
    final service = NotificationReadinessService(
      notificationContract: _TestNotificationContract(true),
    );

    expect(
      await service.getReadiness(),
      NotificationReadinessState.ready,
    );
  });

  test('maps disabled notification bridge to needsPermission state', () async {
    final service = NotificationReadinessService(
      notificationContract: _TestNotificationContract(false),
    );

    expect(
      await service.requestPermission(),
      NotificationReadinessState.needsPermission,
    );
  });
}
