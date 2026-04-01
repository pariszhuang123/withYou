# Content Resolver Contract

## Purpose
Resolves all display and playback content from the scenario. Never hardcode asset paths — always go through this contract. Contract doc for `lib/contracts/content_resolver_contract.dart`.

## Contract Interface
```dart
abstract class ContentResolverContract {
  CallContent resolve({
    required Scenario scenario,
  });
}
```

## CallContent Model
```dart
class CallContent {
  final String callerName;          // Neutral name, e.g. "小陈"
  final String avatarAssetPath;     // Generic contact avatar
  final List<String> stageAudioPaths; // 3 paths, one per stage
}
```

## Resolution Rules

### Caller Names
Each scenario has a fixed, neutral caller name. Names MUST NOT be relationship-specific (no 老公, 爸爸, etc.).

| Scenario | Caller Name |
|----------|-------------|
| pickupExpectation | 小陈 |
| safetyCheck | 阿杰 |
| casualExit | 联系人 |
| urgentPullaway | 小陈 |

### Avatar Path Pattern
Generic contact image, same across all scenarios:

`assets/avatars/default_contact.png`

### Audio Path Pattern
`assets/audio/zh/{scenario}/stage_{n}.m4a`

Example: `assets/audio/zh/pickup_expectation/stage_1.m4a`

## Enums
```dart
enum Scenario { pickupExpectation, safetyCheck, casualExit, urgentPullaway }
```

## Rules
- This is a **pure function** — no side effects, no I/O, no async.
- Must return valid paths for every scenario.
- If an asset doesn't exist at the resolved path, the caller handles the error (not this contract).

## Implementation File
`lib/services/content_resolver_service.dart`

## Test File
`test/unit/services/content_resolver_service_test.dart` — must test EVERY scenario.
