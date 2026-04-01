# Call Session Repository Contract

## Purpose
Persists call session data and events locally via Drift/SQLite. This is the single source of truth for session state. Contract doc for `lib/contracts/call_session_repository.dart`.

## Contract Interface
```dart
abstract class CallSessionRepository {
  Future<CallSession> createSession({
    required Scenario scenario,
  });
  Future<void> updateSessionStage(String sessionId, int stage, SessionStatus status);
  Future<void> logEvent(String sessionId, int stage, CallEventType eventType);
  Future<CallSession?> getActiveSession();
  Future<int> getCompletedCallCount();
}
```

## CallSession Model
```dart
class CallSession {
  final String id;           // UUID
  final Scenario scenario;
  final int currentStage;    // 1, 2, or 3
  final SessionStatus status; // active, completed, cancelled
  final DateTime startedAt;
}
```

## CallEventType Enum
```dart
enum CallEventType {
  triggered,   // Stage notification fired or button pressed
  accepted,    // User tapped Accept
  declined,    // User tapped Decline
  completed,   // Audio finished playing
  cancelled,   // Flow cancelled (new flow started, or system)
}
```

## SessionStatus Enum
```dart
enum SessionStatus {
  active,
  completed,
  cancelled,
}
```

## Database Tables
See `docs/data-model.md` for full schema.

## Rules
- Only ONE session can be `active` at a time. If `createSession` is called while one is active, the old one must be set to `cancelled` first.
- `getCompletedCallCount()` returns the number of sessions with status `completed`. Used by PaywallContract.
- Every state transition must be logged via `logEvent`.
- `getActiveSession()` returns null if no session has status `active`.

## Implementation File
`lib/repositories/drift_call_session_repository.dart`

## Test File
`test/unit/repositories/call_session_repository_test.dart`
