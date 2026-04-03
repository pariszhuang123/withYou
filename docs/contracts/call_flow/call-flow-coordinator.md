# Call Flow Coordinator Contract

| Field | Value |
|---|---|
| Version | `v0.2` |
| Status | `active` |
| Last Updated | `2026-04-03` |
| Generated | `manually curated` |
| ADR | `none` |
| Module | `call_flow` |
| Source | `lib/contracts/call_flow/call_flow_coordinator_contract.dart` |

## Purpose

Provide the UI-facing orchestration boundary for the fake call system.

This contract hides:

- session ID creation
- pending follow-up reconciliation
- notification-driven stage resume
- lower-level timing service entry points

## Contract Interface

```dart
abstract class CallFlowCoordinatorContract {
  Stream<CallFlowSnapshot> get snapshotStream;
  CallFlowSnapshot get currentSnapshot;

  Future<void> initialize();
  Future<void> startFlow(Scenario scenario);
  Future<void> resumeFromNotification({
    required String sessionId,
    required Scenario scenario,
    required int stage,
  });
  Future<void> acceptCurrentStage();
  Future<void> declineCurrentStage();
  Future<void> endCurrentStage();
  Future<void> triggerFollowUpStage();
  Future<void> dispose();
}
```

## Rules

- blocs and screens should depend on this contract instead of `FakeCallTimingContract`
- coordinator owns pending follow-up persistence and reconciliation
- coordinator exposes explicit resume entry for notification taps
- notification payload identity is always:
  - `sessionId`
  - `scenario`
  - `stage`

## Implementation

- `lib/services/call_flow_coordinator_service.dart`

## Tests

- `test/unit/services/call_flow_coordinator_service_test.dart`
