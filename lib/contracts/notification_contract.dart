import 'fake_call_timing_contract.dart';

abstract class NotificationContract {
  Future<void> scheduleFollowUp({
    required String sessionId,
    required Scenario scenario,
    required int stage,
    required Duration delay,
    required String callerName,
  });

  Future<void> cancelAll(String sessionId);
}
