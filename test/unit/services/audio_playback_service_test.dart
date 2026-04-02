import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/contracts/call_flow_contracts.dart';
import 'package:with_you/models/playable_audio_source.dart';
import 'package:with_you/services/audio_playback_service.dart';

void main() {
  test(
    'playScenarioClip completes after the configured placeholder duration',
    () async {
      final service = AudioPlaybackService(
        durationForStage: (_, stage) => const Duration(milliseconds: 20),
      );

      final startedAt = DateTime.now();
      await service.playScenarioClip(
        scenario: Scenario.presence,
        stage: 1,
        source: const BundledAudioSource(
          assetPath: 'assets/audio/zh/presence/stage_1.m4a',
        ),
      );

      expect(
        DateTime.now().difference(startedAt).inMilliseconds,
        greaterThanOrEqualTo(15),
      );
    },
  );

  test('stop completes active placeholder playback early', () async {
    final service = AudioPlaybackService(
      durationForStage: (_, stage) => const Duration(seconds: 5),
    );

    final playbackFuture = service.playScenarioClip(
      scenario: Scenario.socialPull,
      stage: 2,
      source: const BundledAudioSource(
        assetPath: 'assets/audio/zh/social_pull/stage_2.m4a',
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 20));
    await service.stop();
    await playbackFuture.timeout(const Duration(milliseconds: 100));
  });
}
