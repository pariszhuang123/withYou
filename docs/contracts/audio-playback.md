# Audio Playback Contract

## Purpose

Plays pre-recorded voice audio through the device speaker. Speaker output is critical — bystanders must hear the call to make the scenario believable. Contract doc for `lib/contracts/audio_playback_contract.dart`.

## Why Speaker-First

The core use case: a woman in an uncomfortable situation triggers a fake call. Audio plays through the speaker so people nearby overhear a convincing voice creating urgency ("I'm downstairs, where are you?"). This gives her a natural reason to leave.

## Contract Interface

```dart
abstract class AudioPlaybackContract {
  /// Plays audio through speaker. Auto-completes when audio finishes.
  Future<void> play({
    required String assetPath,
    required bool forceSpeaker,
  });

  /// Stops playback immediately.
  Future<void> stop();

  /// Stream of playback state.
  Stream<AudioPlaybackState> get stateStream;
}

enum AudioPlaybackState {
  idle,       // Nothing playing
  loading,    // Asset loading
  playing,    // Audio active on speaker
  completed,  // Playback finished naturally — call flow auto-ends the call
  error,      // Playback failed
}
```

## Speaker Routing

### Priority

1. Force speaker output
2. If speaker override fails, play through available output (still useful)
3. **Never block playback because speaker routing failed**

### Platform Behavior

| Platform | Method | Fallback |
|----------|--------|----------|
| Android | `AudioManager.setSpeakerphoneOn(true)` via platform channel | Play through default output |
| iOS | `AVAudioSession` category `.playback` with `.defaultToSpeaker` | Play through default output |

### Edge Cases

| Situation | Behavior |
|-----------|----------|
| Bluetooth headphones connected | Attempt speaker override. If fails, play through Bluetooth. |
| Wired headphones connected | Attempt speaker override. If fails, play through headphones. |
| Car Bluetooth | Play through car speakers (fine for the use case). |
| Phone in silent mode | Audio still plays — `.playback` category ignores silent switch (iOS). Android uses STREAM_MUSIC. |
| Volume at zero | Cannot override — user must have volume up. |
| DND / Focus mode | Audio plays if app is in foreground. |
| Real phone call interrupts | Emit `error` state. Call flow handles gracefully (treats stage as resolved). |

## Audio Format

| Property | Value |
|----------|-------|
| Codec | AAC (M4A container) |
| Bitrate | 96–128 kbps |
| Channels | Mono |
| Sample rate | 44.1 kHz |
| Duration | 8–15 seconds per stage |
| File size | ≤ 300KB per file, ≤ 900KB per scenario |
| Total v1 budget | ≤ 5MB all audio |

## Playback Timing

| Parameter | Value |
|-----------|-------|
| Pre-answer delay | 0.5–1.0s after Accept tap (randomized for realism) |
| Inter-line pauses | Built into audio files (not app-controlled) |
| Auto-end | Playback finishes → emit `completed` → call flow dismisses call screen |

## Error Handling

- Asset not found → emit `error`, log. Call flow treats stage as resolved, schedules next.
- Speaker routing fails → log warning, continue playback on available output.
- Interrupted by system → emit `error`. Call flow handles gracefully.
- **Never leave user stuck on call screen if audio fails.**

## Implementation

`lib/platform/audio_playback_service.dart`

## Tests

- `test/unit/platform/audio_playback_service_test.dart` (mocked)
- `test/integration/audio_playback_integration_test.dart` (real playback)
