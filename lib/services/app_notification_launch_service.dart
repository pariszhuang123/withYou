import 'dart:async';

import '../contracts/app_contracts.dart';
import '../contracts/call_flow_contracts.dart';

class AppNotificationLaunchService {
  AppNotificationLaunchService({
    required NotificationContract notificationContract,
    required CallFlowCoordinatorContract callFlowCoordinatorContract,
    required AppRouterContract appRouterContract,
  }) : _notificationContract = notificationContract,
       _callFlowCoordinatorContract = callFlowCoordinatorContract,
       _appRouterContract = appRouterContract;

  final NotificationContract _notificationContract;
  final CallFlowCoordinatorContract _callFlowCoordinatorContract;
  final AppRouterContract _appRouterContract;

  StreamSubscription<NotificationEvent>? _subscription;

  void start() {
    _subscription ??= _notificationContract.eventStream.listen(_handleEvent);
  }

  Future<void> _handleEvent(NotificationEvent event) async {
    if (event.action != NotificationAction.tapped) {
      return;
    }

    await _callFlowCoordinatorContract.resumeFromNotification(
      sessionId: event.sessionId,
      scenario: event.scenario,
      stage: event.stage,
    );
    await _appRouterContract.handleExternalIntent(
      AppLaunchIntent(
        source: AppLaunchSource.notification,
        destination: AppRouteDestination.call,
        scenario: event.scenario,
        stage: event.stage,
        sessionId: event.sessionId,
      ),
    );
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
