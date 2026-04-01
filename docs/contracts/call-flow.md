# Call Flow Contract

## Purpose
Orchestrates the 3-stage companion call flow. This is the critical path — must be rock-solid. People depend on this in uncomfortable situations.

## Scenario Enum
```dart
enum Scenario {
  pickupExpectation,  // "Someone is coming to pick me up"
  safetyCheck,        // "Checking in on my safety"
  casualExit,         // "Casual excuse to leave"
  urgentPullaway,     // "Urgent reason to leave now"
}
```

Each scenario has a fixed caller identity and all audio is in Chinese. No persona or language selection is needed.

## Contract Interface
```dart
abstract class CallFlowContract {
  Future<CallSession> startFlow({
    required Scenario scenario,
  });
  Future<void> acceptCurrentStage(String sessionId);
  Future<void> declineCurrentStage(String sessionId);
  Future<CallSession?> getActiveSession();
  Stream<CallFlowState> get flowStateStream;
}
```

## States
- `idle` — no active flow
- `ringing` — call UI shown, waiting for accept/decline
- `inCall` — audio playing on speaker
- `callEnded` — current stage audio finished
- `awaitingNextStage` — waiting for notification trigger
- `completed` — Stage 3 finished
- `cancelled` — user declined or missed

## Stage Timing
| Stage | Trigger | Base Delay | Randomness |
|-------|---------|------------|------------|
| 1 | Button press | Immediate | None |
| 2 | Local notification | 4–6 min | ± 30% |
| 3 | Local notification | 6–10 min | ± 30% |

## Flow Rules

### Accept
- Audio plays via `AudioPlaybackContract` (speaker mode)
- After audio completes, next stage is scheduled via `NotificationContract`
- Session updated via `CallSessionRepository`
- Event logged: `accepted`

### Decline
- Audio does NOT play
- Flow ends immediately
- All pending notifications cancelled
- No further stages scheduled
- Session status → cancelled
- Event logged: `declined`

### Missed (notification not tapped)
- Treated as decline
- Flow ends
- Event logged: `missed`

### Edge Cases
- **Start while another flow active**: Previous flow cancelled (cancel notifications, set status cancelled), new flow starts
- **App killed after Stage 1**: Stage 2 notification still fires (system-level notification). When user taps, app reopens and resumes from persisted session.
- **Audio playback error**: Log error, treat stage as completed, schedule next stage anyway. Never leave user stuck.

## State Machine
```
idle → ringing (startFlow called)
ringing → inCall (acceptCurrentStage)
ringing → cancelled (declineCurrentStage)
inCall → callEnded (audio completes)
callEnded → awaitingNextStage (stage < 3, next scheduled)
callEnded → completed (stage == 3)
awaitingNextStage → ringing (notification triggers next stage)
```

## Dependencies
- `AudioPlaybackContract` — plays stage audio
- `NotificationContract` — schedules follow-up calls
- `CallSessionRepository` — persists session state and events
- `ContentResolverContract` — resolves audio paths by scenario only (caller identity and language are fixed per scenario)

## Implementation File
`lib/services/call_flow_service.dart`

## Test File
`test/unit/services/call_flow_service_test.dart`
