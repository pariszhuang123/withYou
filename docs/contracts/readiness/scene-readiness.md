# Scene Readiness Contract

| Field | Value |
|---|---|
| Version | `v0.1` |
| Status | `active` |
| Last Updated | `2026-04-02` |
| Generated | `manually curated` |
| ADR | `none` |
| Module | `readiness` |
| Source | `lib/contracts/readiness/scene_readiness_contract.dart` |

## Purpose

Define which scenarios are currently launchable based on notification
capability and premium access.

## Contract Interface

```dart
enum SceneReadinessState { ready, needsNotification, lockedPremium }

class SceneReadinessSnapshot {
  const SceneReadinessSnapshot({
    required this.scenario,
    required this.state,
    this.fallsBackToPresence = true,
  });

  final Scenario scenario;
  final SceneReadinessState state;
  final bool fallsBackToPresence;
}

abstract class SceneReadinessContract {
  Future<SceneReadinessSnapshot> getReadiness(Scenario scenario);

  Future<List<SceneReadinessSnapshot>> getAllReadiness();
}
```

## Rules

- Readiness is derived, not user-entered state.
- `fallsBackToPresence` documents a safe degraded launch path.
- The contract does not start flows directly.
