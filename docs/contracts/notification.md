# Notification Contract

## Purpose
Schedules and displays local notifications for Stage 2 and Stage 3 follow-up calls. Notifications must look like incoming calls. This is the contract doc for `lib/contracts/notification_contract.dart`.

## Contract Interface
```dart
abstract class NotificationContract {
  Future<void> scheduleFollowUp({
    required String sessionId,
    required int stage,
    required Duration baseDelay,
    required String callerName,
  });
  Future<void> cancelAll(String sessionId);
}
```

## Notification Appearance
| Field | Value |
|-------|-------|
| Title | "{callerName} 来电" (e.g. "小陈 来电" or "阿杰 来电") |
| Body | "点击接听" |
| Sound | Default ringtone or custom ringtone asset |
| Priority | High / Max (must interrupt) |
| Channel (Android) | "incoming_call" with high importance |

## Timing
| Stage | Base Delay | Randomness |
|-------|------------|------------|
| 2 | 4–6 minutes | ± 30% |
| 3 | 6–10 minutes | ± 30% |

Randomness formula: `actualDelay = baseDelay * (1 + random(-0.3, 0.3))`

## Tap Behavior
1. User sees notification
2. User taps notification
3. If device locked → user unlocks (Face ID / passcode / PIN)
4. App opens directly into fake call UI (ringing state)

## Platform Differences
| Platform | Behavior |
|----------|----------|
| Android | Full-screen intent for call-like interruption. Shows over lock screen. |
| iOS | Standard notification. User must tap → unlock → app opens → call UI shown. Cannot auto-launch call screen. |

## Cancel Behavior
- `cancelAll(sessionId)` removes all pending notifications for that session
- Called when: user declines, flow cancelled, new flow started

## Implementation File
`lib/platform/notification_service.dart`

## Test File
`test/integration/notification_integration_test.dart`
