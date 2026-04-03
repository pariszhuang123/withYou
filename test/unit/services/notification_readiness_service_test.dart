import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/contracts/call_flow_contracts.dart';
import 'package:with_you/contracts/readiness_contracts.dart';
import 'package:with_you/services/notification_readiness_service.dart';

class _TestNotificationContract implements NotificationContract {
  _TestNotificationContract({
    required this.initialized,
    required this.permissionRequested,
  });

  bool initialized;
  bool permissionRequested;

  @override
  Stream<NotificationEvent> get eventStream =>
      const Stream<NotificationEvent>.empty();

  @override
  Future<void> cancelAll(String sessionId) async {}

  @override
  Future<bool> initialize() async => initialized;

  @override
  Future<bool> requestPermission() async => permissionRequested;

  @override
  Future<void> openSystemSettings() async {}

  @override
  Future<void> scheduleFollowUp({
    required String sessionId,
    required Scenario scenario,
    required int stage,
    required Duration delay,
    required String title,
    required String body,
  }) async {}
}

void main() {
  test('maps initialized notification bridge to ready state', () async {
    final service = NotificationReadinessService(
      notificationContract: _TestNotificationContract(
        initialized: true,
        permissionRequested: true,
      ),
    );

    expect(
      await service.getReadiness(),
      NotificationReadinessState.ready,
    );
  });

  test('maps disabled notification bridge to needsPermission state', () async {
    final service = NotificationReadinessService(
      notificationContract: _TestNotificationContract(
        initialized: false,
        permissionRequested: false,
      ),
    );

    expect(
      await service.requestPermission(),
      NotificationReadinessState.needsPermission,
    );
  });

  test('maps granted permission request to ready state', () async {
    final service = NotificationReadinessService(
      notificationContract: _TestNotificationContract(
        initialized: false,
        permissionRequested: true,
      ),
    );

    expect(
      await service.requestPermission(),
      NotificationReadinessState.ready,
    );
  });
}
