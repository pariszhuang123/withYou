# Call Flow Contract

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

Coordinate the in-memory fake call state machine for the selected scenario.
This contract owns:

- stage progression
- accept / decline / end behavior
- randomized follow-up timing
- notification re-entry via explicit callbacks

Completed and prior stages are not persisted.

UI-facing orchestration is exposed separately through
`CallFlowCoordinatorContract`, so widgets and blocs do not manage session IDs or
notification re-entry details directly.

Pending follow-up metadata may be persisted for reconciliation after restart.
This does not persist full active call state or historical session logs.

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

## Scenario Rules

- `presence` has Stage 1 only
- `socialPull` has Stages 1 to 3
- `exitPressure` has Stages 1 to 3
- explicit decline cancels remaining stages and completes the flow
- missed advances using the same follow-up timing as an accepted or ended stage
- end stops active playback and resolves the current stage immediately

## Timing Rules

- Stage 1 is immediate
- `socialPull` Stage 2 delay is 120 to 240 seconds
- `socialPull` Stage 3 delay is 240 to 480 seconds
- `exitPressure` Stage 2 delay is 45 to 90 seconds
- `exitPressure` Stage 3 delay is 90 to 180 seconds
- `nextStageReadyAt` captures the single randomized follow-up time for the next stage

## State Model

- `idle`
- `ringing`
- `inCall`
- `callEnded`
- `awaitingNextStage`
- `completed`

## Dependencies

- `AudioPlaybackContract`
- `AudioLanguagePackManagerContract`
- `ContentResolverContract`
- `NotificationContract`
- `PendingFollowUpRepositoryContract`

## UI Boundary

```dart
abstract class CallFlowCoordinatorContract {
  Stream<CallFlowSnapshot> get snapshotStream;
  CallFlowSnapshot get currentSnapshot;

  Future<void> startFlow(Scenario scenario);
  Future<void> acceptCurrentStage();
  Future<void> declineCurrentStage();
  Future<void> endCurrentStage();
  Future<void> triggerFollowUpStage();
  Future<void> dispose();
}
```

This coordinator is the preferred dependency for blocs and screens.

## Implementation

- `lib/contracts/call_flow/fake_call_timing_contract.dart`
- `lib/contracts/call_flow/call_flow_coordinator_contract.dart`
- `lib/contracts/call_flow/pending_follow_up_repository_contract.dart`
- `lib/services/call_flow_coordinator_service.dart`
- `lib/repositories/pending_follow_up_repository.dart`
- `lib/services/fake_call_timing_service.dart`

## Tests

- `test/unit/services/fake_call_timing_service_test.dart`
- `test/unit/services/call_flow_coordinator_service_test.dart`
