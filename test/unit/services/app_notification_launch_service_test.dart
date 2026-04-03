import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/contracts/app_contracts.dart';
import 'package:with_you/contracts/call_flow_contracts.dart';
import 'package:with_you/services/app_notification_launch_service.dart';

class _TestNotificationContract implements NotificationContract {
  final _controller = StreamController<NotificationEvent>.broadcast();

  @override
  Stream<NotificationEvent> get eventStream => _controller.stream;

  @override
  Future<void> cancelAll(String sessionId) async {}

  @override
  Future<bool> initialize() async => true;

  @override
  Future<void> openSystemSettings() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> scheduleFollowUp({
    required String sessionId,
    required Scenario scenario,
    required int stage,
    required Duration delay,
    required String title,
    required String body,
  }) async {}

  void emit(NotificationEvent event) {
    _controller.add(event);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}

class _TestCallFlowCoordinatorContract implements CallFlowCoordinatorContract {
  int resumeCount = 0;
  ({String sessionId, Scenario scenario, int stage})? lastResume;

  @override
  CallFlowSnapshot get currentSnapshot => CallFlowSnapshot.idle();

  @override
  Stream<CallFlowSnapshot> get snapshotStream =>
      const Stream<CallFlowSnapshot>.empty();

  @override
  Future<void> acceptCurrentStage() async {}

  @override
  Future<void> declineCurrentStage() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> endCurrentStage() async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> resumeFromNotification({
    required String sessionId,
    required Scenario scenario,
    required int stage,
  }) async {
    resumeCount++;
    lastResume = (sessionId: sessionId, scenario: scenario, stage: stage);
  }

  @override
  Future<void> startFlow(Scenario scenario) async {}

  @override
  Future<void> triggerFollowUpStage() async {}
}

class _TestAppRouterContract implements AppRouterContract {
  int intentCount = 0;
  AppLaunchIntent? lastIntent;

  @override
  AppRouteState get currentRoute => const AppRouteState.home();

  @override
  Future<void> goHome() async {}

  @override
  Future<void> handleExternalIntent(AppLaunchIntent intent) async {
    intentCount++;
    lastIntent = intent;
  }

  @override
  Future<void> openSettings() async {}

  @override
  Future<bool> openPaywall({Scenario? scenario, AppLaunchIntent? intent}) async {
    return false;
  }

  @override
  RouterConfig<Object> get routerConfig => throw UnimplementedError();

  @override
  Future<void> syncCallRoute({
    required bool visible,
    Scenario? scenario,
    int? stage,
    String? sessionId,
    AppLaunchIntent? intent,
  }) async {}
}

void main() {
  test('tapped notification resumes coordinator and routes to call', () async {
    final notifications = _TestNotificationContract();
    final coordinator = _TestCallFlowCoordinatorContract();
    final router = _TestAppRouterContract();
    final service = AppNotificationLaunchService(
      notificationContract: notifications,
      callFlowCoordinatorContract: coordinator,
      appRouterContract: router,
    );

    service.start();
    notifications.emit(
      const NotificationEvent(
        sessionId: 'session-42',
        scenario: Scenario.exitPressure,
        stage: 2,
        action: NotificationAction.tapped,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(coordinator.resumeCount, 1);
    expect(coordinator.lastResume?.sessionId, 'session-42');
    expect(coordinator.lastResume?.scenario, Scenario.exitPressure);
    expect(coordinator.lastResume?.stage, 2);
    expect(router.intentCount, 1);
    expect(router.lastIntent?.source, AppLaunchSource.notification);
    expect(router.lastIntent?.destination, AppRouteDestination.call);
    expect(router.lastIntent?.scenario, Scenario.exitPressure);
    expect(router.lastIntent?.stage, 2);
    expect(router.lastIntent?.sessionId, 'session-42');

    await service.dispose();
    await notifications.dispose();
  });

  test('missed notification does not route or resume', () async {
    final notifications = _TestNotificationContract();
    final coordinator = _TestCallFlowCoordinatorContract();
    final router = _TestAppRouterContract();
    final service = AppNotificationLaunchService(
      notificationContract: notifications,
      callFlowCoordinatorContract: coordinator,
      appRouterContract: router,
    );

    service.start();
    notifications.emit(
      const NotificationEvent(
        sessionId: 'session-43',
        scenario: Scenario.socialPull,
        stage: 2,
        action: NotificationAction.missed,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(coordinator.resumeCount, 0);
    expect(router.intentCount, 0);

    await service.dispose();
    await notifications.dispose();
  });
}
