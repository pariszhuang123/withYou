# Audio Playback Contract

| Field | Value |
|---|---|
| Version | `v0.2` |
| Status | `active` |
| Last Updated | `2026-04-03` |
| Generated | `manually curated` |
| ADR | `none` |
| Module | `audio` |
| Source | `lib/contracts/audio/audio_playback_contract.dart` |

## Purpose

Play local call audio through the device speaker. This includes a looping ringtone while a stage is ringing and scenario speech after the user accepts. Playback must not depend on live network access.

## Contract Interface

```dart
abstract class AudioPlaybackContract {
  Future<void> playRingtoneLoop({
    required PlayableAudioSource source,
  });

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
- Ringtone starts automatically when a stage enters `ringing`.
- Ringtone must continue until the stage resolves by accept, decline, miss, or coordinator-driven cleanup.
- Ringtone must stop before accepted speech playback starts.
- Active call flow must not trigger a remote download.
- If the selected locale is unavailable offline, the audio language pack manager resolves fallback before playback starts.
- Playback remains accept-first; no automatic audio start without user interaction.

## Failure Handling

- Playback errors must be logged through the logger contract.
- Call flow must resolve gracefully if playback fails.
