# Notification Contract

| Field | Value |
|---|---|
| Version | `v0.2` |
| Status | `active` |
| Last Updated | `2026-04-03` |
| Generated | `manually curated` |
| ADR | `none` |
| Module | `call_flow` |
| Source | `lib/contracts/call_flow/notification_contract.dart` |

## Purpose

Store and cancel scheduled follow-up notifications for later platform delivery.
This abstraction does not reconstruct call state on its own; the flow service is
re-entered through `onNotificationTapped(...)` and `handleMissedStage(...)`.

## Contract Interface

```dart
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
```

## Rules

- `presence` never schedules follow-up notifications
- `socialPull` schedules Stage 2 and Stage 3
- `exitPressure` schedules Stage 2 and Stage 3
- delay starts when the prior stage resolves
- `cancelAll(sessionId)` clears pending follow-ups for that flow only
- native tap and missed events are delivered back to Dart through `eventStream`
- `initialize()` should bind native callbacks and report whether notifications are currently enabled without forcing a prompt
- `requestPermission()` should trigger the platform permission flow when the OS still allows prompting, then report the resulting enabled state
- `openSystemSettings()` should deep-link to the app notification settings page when the OS supports it
- notification title and body are resolved in Dart so locale-specific copy stays consistent across Android and iOS

## Implementation

- Dart bridge: `lib/platform/notification_service.dart`
- Android channel bridge: `android/app/src/main/kotlin/com/makinglifeeasie/withyou/NotificationPlatformBridge.kt`
- iOS channel bridge: `ios/Runner/AppDelegate.swift`

## Tests

- `test/unit/platform/notification_service_test.dart`
