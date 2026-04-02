# Audio Playback Contract

| Field | Value |
|---|---|
| Version | `v0.1` |
| Status | `active` |
| Last Updated | `2026-04-02` |
| Generated | `manually curated` |
| ADR | `none` |
| Module | `audio` |
| Source | `lib/contracts/audio/audio_playback_contract.dart` |

## Purpose

Play a local audio source through the device speaker after the user accepts a stage. Playback must not depend on live network access.

## Contract Interface

```dart
abstract class AudioPlaybackContract {
  Future<void> playScenarioClip({
    required Scenario scenario,
    required int stage,
    required PlayableAudioSource source,
  });

  Future<void> stop();
}
```

## Source Types

- `BundledAudioSource` for app-bundled files such as `zh` and `en`
- `FileAudioSource` for previously downloaded language-pack files stored locally

## Rules

- Only local sources may be passed to playback.
- Active call flow must not trigger a remote download.
- If the selected locale is unavailable offline, the audio language pack manager resolves fallback before playback starts.
- Playback remains accept-first; no automatic audio start without user interaction.

## Failure Handling

- Playback errors must be logged through the logger contract.
- Call flow must resolve gracefully if playback fails.
