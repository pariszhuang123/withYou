import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/contracts/call_flow_contracts.dart';
import 'package:with_you/contracts/platform_contracts.dart';
import 'package:with_you/models/playable_audio_source.dart';
import 'package:with_you/services/audio_playback_service.dart';

class _TestLogger implements KinlyLoggerContract {
  final List<String> errors = [];

  @override
  void debug(String message, {String category = 'app', Object? error}) {}

  @override
  void error(
    String message, {
    String category = 'app',
    Object? error,
    StackTrace? stackTrace,
  }) {
    errors.add(message);
  }

  @override
  void info(String message, {String category = 'app'}) {}

  @override
  void warn(String message, {String category = 'app', Object? error}) {}
}

class _TestPlaybackHandle implements PlaybackHandle {
  final List<String> assets = [];
  final List<String> filePaths = [];
  final List<PlaybackLoopMode> loopModes = [];
  int playCount = 0;
  int stopCount = 0;
  bool completePlay = true;
  Object? playError;
  Object? setAssetError;
  Future<void>? pendingPlay;

  @override
  Future<void> play() {
    playCount++;
    if (playError != null) {
      throw playError!;
    }
    if (completePlay) {
      return Future<void>.value();
    }

    pendingPlay ??= Future<void>.delayed(const Duration(seconds: 5));
    return pendingPlay!;
  }

  @override
  Future<void> setAsset(String assetPath) async {
    if (setAssetError != null) {
      throw setAssetError!;
    }
    assets.add(assetPath);
  }

  @override
  Future<void> setFilePath(String filePath) async {
    filePaths.add(filePath);
  }

  @override
  Future<void> setLoopMode(PlaybackLoopMode mode) async {
    loopModes.add(mode);
  }

  @override
  Future<void> stop() async {
    stopCount++;
    pendingPlay = null;
  }
}

void main() {
  test('playRingtoneLoop loads bundled ringtone and loops it', () async {
    final ringtone = _TestPlaybackHandle();
    final clip = _TestPlaybackHandle();
    final logger = _TestLogger();
    final service = AudioPlaybackService(
      logger: logger,
      ringtoneHandle: ringtone,
      clipHandle: clip,
      assetAvailabilityChecker: (_) async => true,
    );

    await service.playRingtoneLoop(
      source: const BundledAudioSource(
        assetPath: 'assets/audio/system/ringtone_loop.m4a',
      ),
    );

    expect(ringtone.assets.single, 'assets/audio/system/ringtone_loop.m4a');
    expect(ringtone.loopModes.single, PlaybackLoopMode.one);
    expect(ringtone.playCount, 1);
    expect(clip.stopCount, 1);
    expect(logger.errors, isEmpty);
  });

  test('playScenarioClip loads bundled clip and waits for playback', () async {
    final ringtone = _TestPlaybackHandle();
    final clip = _TestPlaybackHandle();
    final logger = _TestLogger();
    final service = AudioPlaybackService(
      logger: logger,
      ringtoneHandle: ringtone,
      clipHandle: clip,
      assetAvailabilityChecker: (_) async => true,
    );

    await service.playScenarioClip(
      scenario: Scenario.presence,
      stage: 1,
      source: const BundledAudioSource(
        assetPath: 'assets/audio/zh/presence/stage_1.m4a',
      ),
    );

    expect(clip.assets.single, 'assets/audio/zh/presence/stage_1.m4a');
    expect(clip.loopModes.single, PlaybackLoopMode.off);
    expect(clip.playCount, 1);
    expect(ringtone.stopCount, 1);
    expect(logger.errors, isEmpty);
  });

  test('playScenarioClip supports downloaded file sources', () async {
    final ringtone = _TestPlaybackHandle();
    final clip = _TestPlaybackHandle();
    final logger = _TestLogger();
    final service = AudioPlaybackService(
      logger: logger,
      ringtoneHandle: ringtone,
      clipHandle: clip,
      assetAvailabilityChecker: (_) async => true,
    );

    await service.playScenarioClip(
      scenario: Scenario.socialPull,
      stage: 2,
      source: const FileAudioSource(
        filePath: 'C:/audio/social_pull/stage_2.m4a',
      ),
    );

    expect(clip.filePaths.single, 'C:/audio/social_pull/stage_2.m4a');
    expect(logger.errors, isEmpty);
  });

  test('stop stops ringtone and clip playback', () async {
    final ringtone = _TestPlaybackHandle();
    final clip = _TestPlaybackHandle();
    final logger = _TestLogger();
    final service = AudioPlaybackService(
      logger: logger,
      ringtoneHandle: ringtone,
      clipHandle: clip,
      assetAvailabilityChecker: (_) async => true,
    );

    await service.stop();

    expect(ringtone.stopCount, 1);
    expect(clip.stopCount, 1);
    expect(logger.errors, isEmpty);
  });

  test(
    'playScenarioClip logs missing bundled asset instead of throwing',
    () async {
      final ringtone = _TestPlaybackHandle();
      final clip = _TestPlaybackHandle();
      final logger = _TestLogger();
      final service = AudioPlaybackService(
        logger: logger,
        ringtoneHandle: ringtone,
        clipHandle: clip,
        assetAvailabilityChecker: (_) async => false,
      );

      await service.playScenarioClip(
        scenario: Scenario.socialPull,
        stage: 1,
        source: const BundledAudioSource(
          assetPath: 'assets/audio/zh/social_pull/stage_1.m4a',
        ),
      );

      expect(clip.assets, isEmpty);
      expect(logger.errors.single, contains('Failed to play scenario clip'));
    },
  );

  test('playRingtoneLoop logs playback failure instead of throwing', () async {
    final ringtone = _TestPlaybackHandle()..playError = StateError('boom');
    final clip = _TestPlaybackHandle();
    final logger = _TestLogger();
    final service = AudioPlaybackService(
      logger: logger,
      ringtoneHandle: ringtone,
      clipHandle: clip,
      assetAvailabilityChecker: (_) async => true,
    );

    await service.playRingtoneLoop(
      source: const BundledAudioSource(
        assetPath: 'assets/audio/system/ringtone_loop.mp3',
      ),
    );

    expect(logger.errors.single, contains('Failed to start ringtone playback'));
  });
}
