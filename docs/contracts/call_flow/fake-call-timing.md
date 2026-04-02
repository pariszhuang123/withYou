# Fake Call Timing Contract

| Field | Value |
|---|---|
| Version | `v0.1` |
| Status | `active` |
| Last Updated | `2026-04-02` |
| Generated | `manually curated` |
| ADR | `none` |
| Module | `call_flow` |
| Source | `lib/contracts/call_flow/fake_call_timing_contract.dart` |

## Purpose

Provide the low-level in-memory stage machine for fake call progression.

This is the timing engine beneath the coordinator. It owns immediate flow state
transitions, audio start/end boundaries, and notification re-entry hooks.

## Contract Interface

```dart
abstract class FakeCallTimingContract {
  Stream<FakeCallState> get stateStream;

  FakeCallState get currentState;
  Scenario? get currentScenario;
  int get currentStage;
  int? get pendingFollowUpStage;
  DateTime? get nextStageReadyAt;

  Future<void> startFlow({
    required String sessionId,
    required Scenario scenario,
    FakeCallTrack track = FakeCallTrack.active,
  });

  Future<void> acceptCurrentStage();
  Future<void> declineCurrentStage();
  Future<void> endCurrentStage();
  Future<void> onNotificationTapped({
    required String sessionId,
    required Scenario scenario,
    required int stage,
  });
  Future<void> handleMissedStage({
    required String sessionId,
    required Scenario scenario,
    required int stage,
  });
  Future<void> dispose();
}
```

## Rules

- state is in-memory only
- timing behavior must follow the call-flow contract
- this contract is not the UI boundary

## Implementation

- `lib/services/fake_call_timing_service.dart`

## Tests

- `test/unit/services/fake_call_timing_service_test.dart`
