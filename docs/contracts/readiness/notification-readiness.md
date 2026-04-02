# Notification Readiness Contract

| Field | Value |
|---|---|
| Version | `v0.1` |
| Status | `active` |
| Last Updated | `2026-04-02` |
| Generated | `manually curated` |
| ADR | `none` |
| Module | `readiness` |
| Source | `lib/contracts/readiness/notification_readiness_contract.dart` |

## Purpose

Define whether the app can currently schedule follow-up notifications and how
permission requests are surfaced before a flow starts.

## Contract Interface

```dart
enum NotificationReadinessState { ready, needsPermission, unavailable }

abstract class NotificationReadinessContract {
  Future<NotificationReadinessState> getReadiness();

  Future<NotificationReadinessState> requestPermission();
}
```

## Rules

- Permission checks happen before the app relies on notification follow-ups.
- `unavailable` is reserved for platform-level capability failures.
- The contract does not schedule notifications; it only reports readiness.
