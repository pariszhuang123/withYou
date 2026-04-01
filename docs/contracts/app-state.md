# App State Contract

## Purpose

Persists minimal app state: selected scenario and purchase state. This is the only persisted product state. No session history and no call logs.

## Contract Interface

```dart
abstract class AppStateContract {
  Future<Scenario> getSelectedScenario();
  Future<void> setSelectedScenario(Scenario scenario);

  Future<bool> hasPurchased();
  Future<void> recordPurchase();

  Future<int> getCompletedFlowCount();
  Future<void> incrementCompletedFlowCount();

  Future<bool> isEmergencyBypassAvailable();
  Future<void> useEmergencyBypass();
}
```

## What Is Stored

| Data | Type | Default | Purpose |
|------|------|---------|---------|
| `selected_scenario` | `String` | `"socialPull"` | Last selected scenario |
| `has_purchased` | `bool` | `false` | One-time purchase flag |
| `completed_flow_count` | `int` | `0` | Completed flows for paywall logic |
| `emergency_bypass_last_used` | `DateTime?` | `null` | Last emergency use timestamp |

## What Is Not Stored

- No session IDs
- No call event logs
- No timestamps of when calls happened
- No scenario usage history
- No user-identifiable data

Active flow state remains in memory only. If the app is killed, notification payload carries the scenario and stage needed to resume.

## Implementation File

`lib/repositories/app_state_repository.dart`

## Test File

`test/unit/repositories/app_state_repository_test.dart`
