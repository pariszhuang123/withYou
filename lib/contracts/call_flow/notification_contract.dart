import 'fake_call_timing_contract.dart';

enum NotificationAction { tapped, missed }

class NotificationEvent {
  const NotificationEvent({
    required this.sessionId,
    required this.scenario,
    required this.stage,
    required this.action,
  });

  final String sessionId;
  final Scenario scenario;
  final int stage;
  final NotificationAction action;
}

abstract class NotificationContract {
  Future<bool> initialize();

  Future<bool> requestPermission();

  Future<void> openSystemSettings();

  Future<void> scheduleFollowUp({
    required String sessionId,
    required Scenario scenario,
    required int stage,
    required Duration delay,
    required String title,
    required String body,
  });

  Future<void> cancelAll(String sessionId);

  Stream<NotificationEvent> get eventStream;
}
