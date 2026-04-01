# Content Resolver Contract

## Purpose

Resolves all caller presentation and stage audio from a scenario. Never hardcode caller names, avatars, or asset paths. Contract doc for `lib/contracts/content_resolver_contract.dart`.

## Contract Interface

```dart
abstract class ContentResolverContract {
  String resolveCallerName(Scenario scenario);

  String resolveScenarioAudioPath({
    required Scenario scenario,
    required int stage,
  });
}
```

## Scenario Enum

```dart
enum Scenario {
  presence,
  socialPull,
  exitPressure,
}
```

## Resolution Table

| Scenario | Caller Name | Avatar | Valid Stages | Audio Path Pattern |
|----------|-------------|--------|--------------|--------------------|
| `presence` | `Xiao Chen` | `assets/avatars/default_contact.png` | 1 | `assets/audio/zh/presence/stage_1.m4a` |
| `socialPull` | `Xiao Li` | `assets/avatars/default_contact.png` | 1, 2, 3 | `assets/audio/zh/social_pull/stage_{n}.m4a` |
| `exitPressure` | `Xiao Zhang` | `assets/avatars/default_contact.png` | 1, 2, 3 | `assets/audio/zh/exit_pressure/stage_{n}.m4a` |

## Caller Name Rules

- Must use neutral, common names
- Must not use relationship-specific labels
- Must not use generic placeholders like "Contact"
- Caller names are part of the simulation, not the app UI

## Rules

- This contract is a pure function with no I/O and no async work
- `resolveScenarioAudioPath()` must reject invalid stage numbers for the selected scenario
- `presence` only resolves Stage 1
- `socialPull` and `exitPressure` resolve Stages 1 to 3

## Implementation File

`lib/services/content_resolver_service.dart`

## Test File

`test/unit/services/content_resolver_service_test.dart`
