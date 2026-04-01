# Audio Playback Contract

## Purpose
Plays pre-recorded voice audio through the device speaker. Speaker output is critical — bystanders must hear the call to make the scenario believable. This is the contract doc for `lib/contracts/audio_playback_contract.dart`.

## Why Speaker-First
The core use case: a woman in an uncomfortable situation triggers a fake call. The audio plays through the speaker so people nearby overhear a convincing voice creating urgency ("I'm downstairs, where are you?"). This gives her a natural reason to leave.

## Contract Interface
```dart
abstract class AudioPlaybackContract {
  Future<void> playStageAudio({
    required String assetPath,
    required bool forceSpeaker,
  });
  Future<void> stop();
  Stream<AudioPlaybackState> get playbackStateStream;
}
```

## States
- `idle` — nothing playing
- `loading` — audio asset loading
- `playing` — audio actively playing through speaker
- `completed` — playback finished naturally
- `error` — playback failed

## Speaker Routing Rules
| Platform | Behavior |
|----------|----------|
| Android | Enforce speaker via `AudioManager.setSpeakerphoneOn(true)`. Use platform channel. |
| iOS | Set `AVAudioSession` category to `.playback` with `.defaultToSpeaker` option. Best effort. |

## Playback Timing
| Parameter | Value |
|-----------|-------|
| Pre-answer delay | 0.5–1.0s after Accept tap (randomized) |
| Inter-line pauses | Built into audio files (0.6–1.5s natural variation) |
| Volume | Medium (not max — must sound natural, not alarming) |

## Audio Format Requirements
- Codec: AAC (M4A container)
- Bitrate: 96–128 kbps
- Channels: Mono
- Sample rate: 44.1 kHz
- Duration: 8–15 seconds per stage
- File size: ≤ 300KB per file (≤ 900KB per scenario total)
- Total bundled audio budget: ≤ 5MB for v1

## Asset Path Convention
Chinese-only for v1. Example path:
```
assets/audio/zh/scenario_1/stage_1.m4a
```

## Error Handling
- If asset not found: emit `error` state, log error. Caller (CallFlowService) decides what to do.
- If speaker routing fails (iOS): continue playback on default output. Do not block the flow.
- If playback interrupted by system (real phone call): emit `error`, let CallFlowService handle.

## Platform Implementation
`lib/platform/audio_playback_service.dart` — uses `audioplayers` package + platform channels for speaker routing.

## Test File
`test/unit/platform/audio_playback_service_test.dart` (unit with mocks)
`test/integration/audio_playback_integration_test.dart` (real playback on emulator)
