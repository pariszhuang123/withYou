import 'dart:async';

import '../contracts/audio_contracts.dart';
import '../contracts/call_flow_contracts.dart';
import '../models/playable_audio_source.dart';

class AudioPlaybackService implements AudioPlaybackContract {
  AudioPlaybackService({
    Duration Function(Scenario scenario, int stage)? durationForStage,
  }) : _durationForStage = durationForStage ?? _defaultDurationForStage;

  final Duration Function(Scenario scenario, int stage) _durationForStage;

  Timer? _playbackTimer;
  Completer<void>? _playbackCompleter;

  @override
  Future<void> playScenarioClip({
    required Scenario scenario,
    required int stage,
    required PlayableAudioSource source,
  }) async {
    await stop();

    final completer = Completer<void>();
    _playbackCompleter = completer;
    _playbackTimer = Timer(_durationForStage(scenario, stage), () {
      if (!completer.isCompleted) {
        completer.complete();
      }
      _playbackTimer = null;
      _playbackCompleter = null;
    });

    await completer.future;
  }

  @override
  Future<void> stop() async {
    _playbackTimer?.cancel();
    _playbackTimer = null;

    final completer = _playbackCompleter;
    _playbackCompleter = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  }

  static Duration _defaultDurationForStage(Scenario scenario, int stage) {
    switch (scenario) {
      case Scenario.presence:
        return const Duration(seconds: 8);
      case Scenario.socialPull:
        return Duration(seconds: 8 + stage);
      case Scenario.exitPressure:
        return Duration(seconds: 6 + stage);
    }
  }
}
