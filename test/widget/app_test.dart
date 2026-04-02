import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/app.dart';
import 'package:with_you/config/app_config.dart';
import 'package:with_you/config/app_environment.dart';
import 'package:with_you/contracts/app_contracts.dart';
import 'package:with_you/contracts/audio_contracts.dart';
import 'package:with_you/contracts/call_flow_contracts.dart';
import 'package:with_you/contracts/readiness_contracts.dart';
import 'package:with_you/models/audio_language.dart';
import 'package:with_you/models/playable_audio_source.dart';

class _TestAppLocaleResolverContract implements AppLocaleResolverContract {
  @override
  Locale resolve({
    required List<Locale>? preferredLocales,
    required List<Locale> supportedLocales,
  }) {
    return const Locale('en');
  }
}

class _TestAudioLanguagePackManagerContract
    implements AudioLanguagePackManagerContract {
  bool downloaded = false;
  String? selectedLocale = 'zh';

  @override
  Future<void> downloadLanguagePack(String localeTag) async {
    downloaded = true;
  }

  @override
  Future<String> ensureSelectedLocale(List<Locale> preferredLocales) async {
    return selectedLocale!;
  }

  @override
  Future<String?> getSelectedLocaleTag() async => selectedLocale;

  @override
  Future<List<AudioLanguageAvailability>> listAvailableLanguages() async {
    return <AudioLanguageAvailability>[
      AudioLanguageAvailability(
        language: const AudioLanguage(
          localeTag: 'zh',
          displayName: 'Traditional Chinese',
          isBundled: true,
        ),
        status: AudioLanguagePackStatus.downloaded,
        isSelected: selectedLocale == 'zh',
      ),
      AudioLanguageAvailability(
        language: const AudioLanguage(
          localeTag: 'zh-TW',
          displayName: 'Traditional Chinese (Taiwan)',
          isBundled: false,
        ),
        status: downloaded
            ? AudioLanguagePackStatus.downloaded
            : AudioLanguagePackStatus.notDownloaded,
        isSelected: selectedLocale == 'zh-TW',
      ),
    ];
  }

  @override
  Future<ResolvedPlayableAudio> resolvePlayableAudio({
    required Scenario scenario,
    required int stage,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> selectLocale(String localeTag) async {
    selectedLocale = localeTag;
  }
}

class _TestCallTemplateContract implements CallTemplateContract {
  @override
  CallTemplateSpec resolve(Locale locale, TargetPlatform platform) {
    return const CallTemplateSpec(
      template: CallTemplate.androidNative,
      layout: CallTemplateLayout.androidInCallTopAligned,
      palette: CallTemplatePalette(
        ringingBackground: Color(0xFF101417),
        inCallBackground: Color(0xFF101417),
        acceptAction: Color(0xFF4CAF50),
        declineAction: Color(0xFFF44336),
        textPrimary: Color(0xFFF1F4F6),
        textSecondary: Color(0xFFC5CCD2),
      ),
      ringingScreenIsDark: true,
      inCallScreenIsDark: true,
      supportsAvatarPulse: true,
      localizedVoiceCallLabel: 'Incoming call',
      displayOnlyControls: <String>[],
    );
  }
}

class _TestAppStateContract implements AppStateContract {
  String? selectedAudioLocaleTag;
  Scenario? selectedScenario;
  bool premiumAccess = false;

  @override
  Future<String?> getSelectedAudioLocaleTag() async => selectedAudioLocaleTag;

  @override
  Future<Scenario?> getSelectedScenario() async => selectedScenario;

  @override
  Future<bool> hasPremiumAccess() async => premiumAccess;

  @override
  Future<void> setPremiumAccess(bool hasPremiumAccess) async {
    premiumAccess = hasPremiumAccess;
  }

  @override
  Future<void> setSelectedAudioLocaleTag(String localeTag) async {
    selectedAudioLocaleTag = localeTag;
  }

  @override
  Future<void> setSelectedScenario(Scenario scenario) async {
    selectedScenario = scenario;
  }
}

class _TestSceneReadinessContract implements SceneReadinessContract {
  @override
  Future<List<SceneReadinessSnapshot>> getAllReadiness() async {
    return const <SceneReadinessSnapshot>[
      SceneReadinessSnapshot(
        scenario: Scenario.presence,
        state: SceneReadinessState.ready,
      ),
      SceneReadinessSnapshot(
        scenario: Scenario.socialPull,
        state: SceneReadinessState.lockedPremium,
      ),
      SceneReadinessSnapshot(
        scenario: Scenario.exitPressure,
        state: SceneReadinessState.needsNotification,
      ),
    ];
  }

  @override
  Future<SceneReadinessSnapshot> getReadiness(Scenario scenario) async {
    return (await getAllReadiness()).singleWhere(
      (snapshot) => snapshot.scenario == scenario,
    );
  }
}

class _TestCallFlowCoordinatorContract implements CallFlowCoordinatorContract {
  final _controller = StreamController<CallFlowSnapshot>.broadcast();

  @override
  CallFlowSnapshot currentSnapshot = CallFlowSnapshot.idle();

  @override
  Stream<CallFlowSnapshot> get snapshotStream => _controller.stream;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> acceptCurrentStage() async {
    currentSnapshot = CallFlowSnapshot(
      flowState: FakeCallState.inCall,
      scenario: currentSnapshot.scenario,
      currentStage: currentSnapshot.currentStage,
      callerName: currentSnapshot.callerName,
      sessionId: currentSnapshot.sessionId,
      followUpStage: null,
      followUpReadyAt: null,
    );
    _controller.add(currentSnapshot);
  }

  @override
  Future<void> declineCurrentStage() async {
    currentSnapshot = CallFlowSnapshot(
      flowState: FakeCallState.completed,
      scenario: currentSnapshot.scenario,
      currentStage: currentSnapshot.currentStage,
      callerName: currentSnapshot.callerName,
      sessionId: currentSnapshot.sessionId,
      followUpStage: null,
      followUpReadyAt: null,
    );
    _controller.add(currentSnapshot);
  }

  @override
  Future<void> dispose() async {
    await _controller.close();
  }

  @override
  Future<void> endCurrentStage() async {
    currentSnapshot = CallFlowSnapshot(
      flowState: FakeCallState.completed,
      scenario: currentSnapshot.scenario,
      currentStage: currentSnapshot.currentStage,
      callerName: currentSnapshot.callerName,
      sessionId: currentSnapshot.sessionId,
      followUpStage: null,
      followUpReadyAt: null,
    );
    _controller.add(currentSnapshot);
  }

  @override
  Future<void> startFlow(Scenario scenario) async {
    currentSnapshot = CallFlowSnapshot(
      flowState: FakeCallState.ringing,
      scenario: scenario,
      currentStage: 1,
      callerName: switch (scenario) {
        Scenario.presence => 'Xiao Chen',
        Scenario.socialPull => 'Xiao Li',
        Scenario.exitPressure => 'Xiao Zhang',
      },
      sessionId: 'session-1',
      followUpStage: null,
      followUpReadyAt: null,
    );
    _controller.add(currentSnapshot);
  }

  @override
  Future<void> triggerFollowUpStage() async {}
}

void main() {
  testWidgets('dev app shows development metadata and selected readiness', (
    tester,
  ) async {
    final manager = _TestAudioLanguagePackManagerContract();
    final coordinator = _TestCallFlowCoordinatorContract();
    final appState = _TestAppStateContract();
    await tester.pumpWidget(
      WithYouApp(
        config: AppConfig(environment: AppEnvironment.dev),
        appLocaleResolverContract: _TestAppLocaleResolverContract(),
        appStateContract: appState,
        audioLanguagePackManagerContract: manager,
        callFlowCoordinatorContract: coordinator,
        callTemplateContract: _TestCallTemplateContract(),
        sceneReadinessContract: _TestSceneReadinessContract(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('With You'), findsNWidgets(2));
    expect(find.text('Release channel: development'), findsOneWidget);
    expect(find.text('APP_ENV=dev'), findsOneWidget);
    expect(find.text('Audio language'), findsOneWidget);
    expect(find.text('Selected scene: Presence · Ready'), findsOneWidget);
    expect(find.byIcon(Icons.download_outlined), findsOneWidget);
  });

  testWidgets('download action updates audio language readiness', (
    tester,
  ) async {
    final manager = _TestAudioLanguagePackManagerContract();
    final coordinator = _TestCallFlowCoordinatorContract();
    final appState = _TestAppStateContract();
    await tester.pumpWidget(
      WithYouApp(
        config: AppConfig(environment: AppEnvironment.prod),
        appLocaleResolverContract: _TestAppLocaleResolverContract(),
        appStateContract: appState,
        audioLanguagePackManagerContract: manager,
        callFlowCoordinatorContract: coordinator,
        callTemplateContract: _TestCallTemplateContract(),
        sceneReadinessContract: _TestSceneReadinessContract(),
      ),
    );
    await tester.pumpAndSettle();

    final downloadButton = find.byIcon(Icons.download_outlined);
    await tester.ensureVisible(downloadButton);
    await tester.tap(downloadButton);
    await tester.pumpAndSettle();

    expect(find.text('Ready offline'), findsNWidgets(2));
    expect(manager.downloaded, isTrue);
  });

  testWidgets('start call action enters the placeholder call screen', (
    tester,
  ) async {
    final manager = _TestAudioLanguagePackManagerContract();
    final coordinator = _TestCallFlowCoordinatorContract();
    final appState = _TestAppStateContract();
    await tester.pumpWidget(
      WithYouApp(
        config: AppConfig(environment: AppEnvironment.prod),
        appLocaleResolverContract: _TestAppLocaleResolverContract(),
        appStateContract: appState,
        audioLanguagePackManagerContract: manager,
        callFlowCoordinatorContract: coordinator,
        callTemplateContract: _TestCallTemplateContract(),
        sceneReadinessContract: _TestSceneReadinessContract(),
      ),
    );
    await tester.pumpAndSettle();

    final startCallButton = find.bySemanticsLabel('Start support call');
    await tester.ensureVisible(startCallButton);
    await tester.tap(startCallButton);
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Accept support call'), findsOneWidget);
    expect(find.text('Xiao Chen'), findsOneWidget);
  });
}
