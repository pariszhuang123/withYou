import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/contracts/audio_contracts.dart';
import 'package:with_you/contracts/call_flow_contracts.dart';
import 'package:with_you/models/audio_language.dart';
import 'package:with_you/models/playable_audio_source.dart';
import 'package:with_you/services/fake_call_timing_service.dart';

class _TestNotificationContract implements NotificationContract {
  final List<_NotificationRequest> requests = [];
  bool cancelled = false;
  final _events = StreamController<NotificationEvent>.broadcast();

  @override
  Stream<NotificationEvent> get eventStream => _events.stream;

  @override
  Future<bool> initialize() async => true;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> openSystemSettings() async {}

  @override
  Future<void> cancelAll(String sessionId) async {
    cancelled = true;
  }

  @override
  Future<void> scheduleFollowUp({
    required String sessionId,
    required Scenario scenario,
    required int stage,
    required Duration delay,
    required String title,
    required String body,
  }) async {
    requests.add(
      _NotificationRequest(
        sessionId: sessionId,
        scenario: scenario,
        stage: stage,
        delay: delay,
        title: title,
        body: body,
      ),
    );
  }
}

class _NotificationRequest {
  _NotificationRequest({
    required this.sessionId,
    required this.scenario,
    required this.stage,
    required this.delay,
    required this.title,
    required this.body,
  });

  final String sessionId;
  final Scenario scenario;
  final int stage;
  final Duration delay;
  final String title;
  final String body;
}

class _TestAudioPlaybackContract implements AudioPlaybackContract {
  final List<PlayableAudioSource> played = [];
  final List<PlayableAudioSource> ringtoneLoops = [];
  int stopCount = 0;

  @override
  Future<void> playRingtoneLoop({required PlayableAudioSource source}) async {
    ringtoneLoops.add(source);
    await Future<void>.delayed(Duration.zero);
  }

  @override
  Future<void> playScenarioClip({
    required Scenario scenario,
    required int stage,
    required PlayableAudioSource source,
  }) async {
    played.add(source);
    await Future<void>.delayed(Duration.zero);
  }

  @override
  Future<void> stop() async {
    stopCount++;
  }
}

class _TestAudioLanguagePackManagerContract
    implements AudioLanguagePackManagerContract {
  @override
  Future<void> downloadLanguagePack(String localeTag) async {}

  @override
  Future<String> ensureSelectedLocale(List<Locale> preferredLocales) async {
    return 'zh';
  }

  @override
  Future<List<AudioLanguageAvailability>> listAvailableLanguages() async {
    return const <AudioLanguageAvailability>[];
  }

  @override
  Future<String?> getSelectedLocaleTag() async => 'zh';

  @override
  Future<ResolvedPlayableAudio> resolvePlayableAudio({
    required Scenario scenario,
    required int stage,
  }) async {
    return ResolvedPlayableAudio(
      localeTag: 'zh',
      source: BundledAudioSource(
        assetPath: 'audio/${scenario.name}_stage$stage.m4a',
      ),
    );
  }

  @override
  Future<void> selectLocale(String localeTag) async {}
}

class _TestContentResolverContract implements ContentResolverContract {
  @override
  List<AudioContentDescriptor> listRequiredAudio() =>
      const <AudioContentDescriptor>[];

  @override
  String resolveBundledAudioAssetPath({
    required String localeTag,
    required Scenario scenario,
    required int stage,
  }) {
    return '$localeTag/${scenario.name}/stage_$stage.m4a';
  }

  @override
  String resolveBundledRingtoneAssetPath() {
    return 'assets/audio/system/ringtone_loop.m4a';
  }

  @override
  String resolveCallerName({
    required Scenario scenario,
    required String localeTag,
  }) {
    switch (scenario) {
      case Scenario.presence:
      case Scenario.socialPull:
      case Scenario.exitPressure:
        return localeTag == 'en' ? 'Tommy' : '小陈';
    }
  }

  @override
  String resolveFollowUpNotificationBody({
    required Scenario scenario,
    required int stage,
    required String localeTag,
  }) {
    return localeTag == 'en'
        ? 'Tap to answer your support call.'
        : '点按即可接听你的支援来电。';
  }

  @override
  AudioContentDescriptor resolveAudioContent({
    required Scenario scenario,
    required int stage,
  }) {
    return AudioContentDescriptor(
      scenario: scenario,
      stage: stage,
      scenarioDirectory: scenario.name,
    );
  }
}

void main() {
  late _TestNotificationContract notification;
  late _TestAudioPlaybackContract audio;
  late _TestAudioLanguagePackManagerContract audioManager;
  late _TestContentResolverContract content;
  late FakeCallTimingService service;

  setUp(() {
    notification = _TestNotificationContract();
    audio = _TestAudioPlaybackContract();
    audioManager = _TestAudioLanguagePackManagerContract();
    content = _TestContentResolverContract();
    service = FakeCallTimingService(
      notificationContract: notification,
      audioPlaybackContract: audio,
      audioLanguagePackManagerContract: audioManager,
      contentResolverContract: content,
      localeTagProvider: () => 'en',
      random: Random(0),
    );
  });

  test('startFlow sets ringing state and stage 1', () async {
    await service.startFlow(sessionId: 's1', scenario: Scenario.socialPull);

    expect(service.currentState, FakeCallState.ringing);
    expect(service.currentStage, 1);
    expect(service.currentScenario, Scenario.socialPull);
    expect(notification.cancelled, isTrue);
    expect(
      (audio.ringtoneLoops.single as BundledAudioSource).assetPath,
      'assets/audio/system/ringtone_loop.m4a',
    );
  });

  test(
    'presence completes after stage 1 without scheduling follow-up',
    () async {
      await service.startFlow(
        sessionId: 'presence-session',
        scenario: Scenario.presence,
      );

      await service.acceptCurrentStage();

      expect(service.currentState, FakeCallState.completed);
      expect(audio.stopCount, greaterThanOrEqualTo(2));
      expect(
        (audio.played.single as BundledAudioSource).assetPath,
        'audio/presence_stage1.m4a',
      );
      expect(notification.requests, isEmpty);
    },
  );

  test('accepting stage 1 schedules stage 2 for socialPull', () async {
    await service.startFlow(sessionId: 's2', scenario: Scenario.socialPull);

    await service.acceptCurrentStage();

    expect(service.currentState, FakeCallState.awaitingNextStage);
    expect(notification.requests.length, 1);
    final req = notification.requests.single;
    expect(req.scenario, Scenario.socialPull);
    expect(req.stage, 2);
    expect(req.title, 'Tommy');
    expect(req.body, 'Tap to answer your support call.');
    expect(req.delay.inSeconds, inInclusiveRange(120, 240));
    expect(service.pendingFollowUpStage, 2);
    expect(service.nextStageReadyAt, isNotNull);
  });

  test(
    'declining stage 2 for socialPull schedules stage 3 and stage 3 decline completes',
    () async {
      await service.startFlow(sessionId: 's3', scenario: Scenario.socialPull);
      await service.acceptCurrentStage();
      await service.onNotificationTapped(
        sessionId: 's3',
        scenario: Scenario.socialPull,
        stage: 2,
      );
      await service.declineCurrentStage();

      expect(service.currentState, FakeCallState.awaitingNextStage);
      expect(notification.requests.length, 2);
      expect(notification.requests.last.stage, 3);
      expect(
        notification.requests.last.delay.inSeconds,
        inInclusiveRange(240, 480),
      );

      await service.onNotificationTapped(
        sessionId: 's3',
        scenario: Scenario.socialPull,
        stage: 3,
      );
      await service.declineCurrentStage();

      expect(service.currentState, FakeCallState.completed);
    },
  );

  test('exitPressure uses tight follow-up windows', () async {
    await service.startFlow(
      sessionId: 's4',
      scenario: Scenario.exitPressure,
      track: FakeCallTrack.background,
    );

    await service.acceptCurrentStage();

    final delay = notification.requests.single.delay;
    expect(delay.inSeconds, inInclusiveRange(45, 90));
  });

  test(
    'ending an active stage stops playback and resolves it immediately',
    () async {
      await service.startFlow(
        sessionId: 's-end',
        scenario: Scenario.exitPressure,
      );

      unawaited(service.acceptCurrentStage());
      await Future<void>.delayed(Duration.zero);
      await service.endCurrentStage();

      expect(service.currentState, FakeCallState.awaitingNextStage);
      expect(notification.requests.single.stage, 2);
    },
  );

  test('declining a ringing stage stops the ringtone', () async {
    await service.startFlow(
      sessionId: 's-decline',
      scenario: Scenario.socialPull,
    );

    await service.declineCurrentStage();

    expect(audio.stopCount, greaterThanOrEqualTo(2));
    expect(service.currentState, FakeCallState.awaitingNextStage);
  });

  test('presence notification tap rejects invalid follow-up stages', () async {
    expect(
      () => service.onNotificationTapped(
        sessionId: 's5',
        scenario: Scenario.presence,
        stage: 2,
      ),
      throwsArgumentError,
    );
  });
}
