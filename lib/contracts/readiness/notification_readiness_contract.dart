enum NotificationReadinessState { ready, needsPermission, unavailable }

abstract class NotificationReadinessContract {
  Future<NotificationReadinessState> getReadiness();

  Future<NotificationReadinessState> requestPermission();
}
