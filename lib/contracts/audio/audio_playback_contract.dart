import '../call_flow/fake_call_timing_contract.dart';
import '../../models/playable_audio_source.dart';

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
