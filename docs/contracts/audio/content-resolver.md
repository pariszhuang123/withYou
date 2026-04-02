# Content Resolver Contract

| Field | Value |
|---|---|
| Version | `v0.1` |
| Status | `active` |
| Last Updated | `2026-04-02` |
| Generated | `manually curated` |
| ADR | `none` |
| Module | `audio` |
| Source | `lib/contracts/audio/content_resolver_contract.dart` |

## Purpose

Resolves fixed scenario content metadata without performing I/O. This contract owns:

- caller name mapping per scenario
- the list of required scenario/stage audio entries
- bundled asset path construction for bundled locales

Remote download, cache lookup, and locale fallback belong to the audio language pack manager, not this contract.

## Contract Interface

```dart
abstract class ContentResolverContract {
  String resolveCallerName(Scenario scenario);

  AudioContentDescriptor resolveAudioContent({
    required Scenario scenario,
    required int stage,
  });

  List<AudioContentDescriptor> listRequiredAudio();

  String resolveBundledAudioAssetPath({
    required String localeTag,
    required Scenario scenario,
    required int stage,
  });
}
```

## Rules

- Pure function only. No filesystem, network, or cache access.
- `presence` exposes Stage 1 only.
- `socialPull` and `exitPressure` expose Stages 1 to 3.
- Bundled asset paths must be constructed through this contract, never hardcoded in widgets or call flow.

## Tests

- Caller names are fixed per scenario.
- Required audio list is complete.
- Bundled asset path generation respects locale/scenario/stage.
- Invalid stage requests throw.
