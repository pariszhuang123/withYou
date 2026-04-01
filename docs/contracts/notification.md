# Notification Contract

## Purpose

Schedules follow-up call notifications for scenarios that define more than one stage. Handles notification callbacks when tapped or missed. Contract doc for `lib/contracts/notification_contract.dart`.

## Contract Interface

```dart
abstract class NotificationContract {
  Future<bool> initialize();

  Future<void> scheduleFollowUp({
    required Scenario scenario,
    required int stage,
    required Duration delay,
    required String callerName,
  });

  Future<void> cancelAll();

  Stream<NotificationEvent> get eventStream;
}

class NotificationEvent {
  final Scenario scenario;
  final int stage;
  final NotificationAction action;
}

enum NotificationAction {
  tapped,
  missed,
}
```

## Scheduling Rules

- `presence` never schedules follow-up notifications
- `socialPull` schedules Stage 2 and Stage 3
- `exitPressure` schedules Stage 2 and Stage 3
- follow-up delay begins when the prior stage resolves
- "resolves" means accepted audio finished, decline tapped, or missed timeout expired

## Timing Windows

| Scenario | Stage | Delay Window |
|----------|-------|--------------|
| `socialPull` | 2 | 2 to 4 minutes after Stage 1 resolves |
| `socialPull` | 3 | 4 to 8 minutes after Stage 2 resolves |
| `exitPressure` | 2 | 45 to 90 seconds after Stage 1 resolves |
| `exitPressure` | 3 | 90 to 180 seconds after Stage 2 resolves |

The selected delay must be randomized once within the allowed window.

## Notification Payload

Payload must carry enough state to reconstruct the ringing screen after cold start:

```dart
{
  'scenario': 'socialPull',
  'stage': 2,
}
```

## Missed Detection

- If a notification is not tapped within 2 minutes, emit `missed`
- A missed stage behaves the same as a declined stage
- If another stage exists for the scenario, its timer starts from the missed timeout

## Cancel Behavior

- `cancelAll()` removes pending follow-up notifications
- Called when the final stage resolves
- Not called on non-final declines or misses

## Implementation

`lib/platform/notification_service.dart`

## Tests

`test/integration/notification_integration_test.dart`
