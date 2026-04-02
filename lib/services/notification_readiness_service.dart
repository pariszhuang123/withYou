import '../contracts/call_flow_contracts.dart';
import '../contracts/readiness_contracts.dart';

class NotificationReadinessService implements NotificationReadinessContract {
  const NotificationReadinessService({
    required NotificationContract notificationContract,
  }) : _notificationContract = notificationContract;

  final NotificationContract _notificationContract;

  @override
  Future<NotificationReadinessState> getReadiness() async {
    final notificationsEnabled = await _notificationContract.initialize();
    return notificationsEnabled
        ? NotificationReadinessState.ready
        : NotificationReadinessState.needsPermission;
  }

  @override
  Future<NotificationReadinessState> requestPermission() {
    return getReadiness();
  }
}
