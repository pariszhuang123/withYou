# Call Flow Contract

> **This is the MOST CRITICAL contract.** Source of truth for scenario-driven fake call behavior, stage timing, and follow-up scheduling.

## Purpose

Defines the three supported intervention modes:

- `presence` for cover, companionship, or looking occupied
- `socialPull` for soft movement and believable expectation
- `exitPressure` for urgent but controlled extraction

The timing is part of the story. Scheduling must match the psychological intent of the selected scenario.

## Scenario Enum

```dart
enum Scenario {
  presence,
  socialPull,
  exitPressure,
}
```

## Core Rule

Each scenario has a fixed stage plan:

| Scenario | Stages | Goal | Tempo |
|----------|--------|------|-------|
| `presence` | 1 | Anchor, companionship, passive cover | Low |
| `socialPull` | 3 | Soft movement, expectation, re-orientation | Moderate |
| `exitPressure` | 3 | Leave now, create directional pressure | Fast |

This app does **not** implement one universal 3-stage flow. It implements three different intervention strengths.

## Contract Interface

```dart
abstract class CallFlowContract {
  /// Starts the first stage immediately for the selected scenario.
  Future<void> startFlow({required Scenario scenario});

  /// Accepts the current ringing stage. Plays audio on speaker.
  /// Audio ends automatically - no manual end needed.
  /// If another stage exists for this scenario, schedule it after audio completes.
  Future<void> acceptCurrentStage();

  /// Declines the current ringing stage.
  /// If another stage exists for this scenario, it STILL fires.
  /// If this is the final stage for the scenario, the flow completes.
  Future<void> declineCurrentStage();

  /// Stream of flow state changes for UI binding.
  Stream<CallFlowState> get flowStateStream;
}
```

## Scenario Stage Plans

### Presence

Use when:

- user wants companionship
- user wants to look occupied
- no need to move yet
- taxi or ride coordination is the clearest example

Behavior:

- one inbound call only
- no escalation arc
- no auto follow-up by default

Stage plan:

| Stage | Trigger | Delay |
|-------|---------|-------|
| 1 | `startFlow()` | immediate |

Why:

- establishes that someone is connected right now
- repeated calls would stop feeling like presence and start feeling like pressure

### Social Pull

Use when:

- there is a reason to shift attention
- there is some issue, but it is not urgent
- user may need a soft excuse to move, wrap up, or re-orient

Behavior arc:

- Stage 1: establish expectation
- Stage 2: follow-up and mild pull
- Stage 3: firmer but still non-urgent direction

Stage plan:

| Stage | Trigger | Delay Window |
|-------|---------|--------------|
| 1 | `startFlow()` | immediate |
| 2 | after Stage 1 resolves | 2 to 4 minutes |
| 3 | after Stage 2 resolves | 4 to 8 minutes |

Why:

- gives the first call time to sit
- keeps follow-ups believable
- avoids fake urgency

### Exit Pressure

Use when:

- user needs to leave
- movement should happen now
- there is urgency, but it must still feel believable and controlled

Behavior arc:

- Stage 1: interrupt current situation
- Stage 2: directional pressure
- Stage 3: clear exit instruction

Stage plan:

| Stage | Trigger | Delay Window |
|-------|---------|--------------|
| 1 | `startFlow()` | immediate |
| 2 | after Stage 1 resolves | 45 to 90 seconds |
| 3 | after Stage 2 resolves | 90 to 180 seconds |

Why:

- creates pressure quickly enough to matter
- avoids robotic back-to-back calls
- gives the user multiple believable chances to disengage

## Timing Semantics

For any scenario with a follow-up stage:

- the next-stage timer starts when the current stage resolves
- "resolves" means accepted audio finished, decline tapped, or missed timeout expired
- the selected delay must be randomized once within the stage's allowed delay window
- timing windows are scenario rules, not implementation suggestions

Examples:

- `socialPull` Stage 2 may be scheduled at any point from 120 to 240 seconds after Stage 1 resolves
- `exitPressure` Stage 3 may be scheduled at any point from 90 to 180 seconds after Stage 2 resolves

## CRITICAL BEHAVIOR - Decline Does NOT Cancel

| Action | What happens | Next stage? |
|--------|-------------|-------------|
| Accept | Audio plays and ends automatically | Yes, if the scenario defines another stage |
| Decline | Stage skipped, no audio | Yes, if the scenario defines another stage |
| Missed | Notification not tapped within timeout | Yes, if the scenario defines another stage |

`presence` has no follow-up stage, so any resolution of Stage 1 completes the flow.

## Missed Stage Rule

- Follow-up notifications are treated as missed if not tapped within 2 minutes
- A missed stage behaves the same as a declined stage
- The next-stage timer starts from the missed timeout, not from the original notification fire time

## State Model

- `idle` - no active flow
- `ringing` - call UI shown, waiting for accept or decline
- `inCall` - audio playing on speaker, call screen shows timer
- `callEnded` - audio finished, call screen auto-dismisses
- `awaitingNextStage` - waiting for the next scheduled stage for this scenario
- `completed` - final stage resolved, flow done

## State Machine

```text
idle -> ringing                  (startFlow or notification tapped)
ringing -> inCall                (accept)
ringing -> awaitingNextStage     (decline, non-final stage)
ringing -> completed             (decline, final stage)
inCall -> callEnded              (audio finishes)
callEnded -> awaitingNextStage   (non-final stage)
callEnded -> completed           (final stage)
awaitingNextStage -> ringing     (next notification tapped)
```

"Final stage" means:

- Stage 1 for `presence`
- Stage 3 for `socialPull`
- Stage 3 for `exitPressure`

## Notification Payload

Each follow-up notification payload must contain:

- `scenario`
- `stage`

This is sufficient to reconstruct the correct ringing state after cold start.

## App Killed Mid-Flow

- notifications are OS-level and must still fire if the app is killed
- when the user taps a notification, the app may cold-start directly into the ringing state
- notification payload carries scenario and stage
- no session history persistence is required for completed or prior stages

## Scenario Timing Reference

```json
{
  "presence": {
    "calls": [
      { "order": 1, "delay_range_sec": [0, 0] }
    ]
  },
  "social_pull": {
    "calls": [
      { "order": 1, "delay_range_sec": [0, 0] },
      { "order": 2, "delay_range_sec": [120, 240] },
      { "order": 3, "delay_range_sec": [240, 480] }
    ]
  },
  "exit_pressure": {
    "calls": [
      { "order": 1, "delay_range_sec": [0, 0] },
      { "order": 2, "delay_range_sec": [45, 90] },
      { "order": 3, "delay_range_sec": [90, 180] }
    ]
  }
}
```

## Dependencies

- `AudioPlaybackContract` - plays stage audio after user accepts
- `NotificationContract` - schedules follow-up stages
- `ContentResolverContract` - resolves scenario content for each stage
- `AppStateContract` - stores selected scenario and purchase state

## Implementation File

`lib/services/call_flow_service.dart`

## Test File

`test/unit/services/call_flow_service_test.dart`
