import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/app.dart';
import 'package:with_you/config/app_config.dart';
import 'package:with_you/config/app_environment.dart';
import 'package:with_you/contracts/app_contracts.dart';
import 'package:with_you/contracts/audio_contracts.dart';
import 'package:with_you/contracts/call_flow_contracts.dart';
import 'package:with_you/contracts/commerce_contracts.dart';
import 'package:with_you/contracts/readiness_contracts.dart';
import 'package:with_you/models/audio_language.dart';
import 'package:with_you/models/playable_audio_source.dart';
import 'package:with_you/services/app_router_service.dart';

class _TestAppLocaleResolverContract implements AppLocaleResolverContract {
  _TestAppLocaleResolverContract([this.locale = const Locale('en')]);

  final Locale locale;

  @override
  Locale resolve({
    required List<Locale>? preferredLocales,
    required List<Locale> supportedLocales,
  }) {
    return locale;
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
          localeTag: 'en',
          displayName: 'English',
          isBundled: true,
        ),
        status: AudioLanguagePackStatus.downloaded,
        isSelected: selectedLocale == 'en',
      ),
      AudioLanguageAvailability(
        language: const AudioLanguage(
          localeTag: 'zh',
          displayName: 'Simplified Chinese',
          isBundled: true,
        ),
        status: AudioLanguagePackStatus.downloaded,
        isSelected: selectedLocale == 'zh',
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
  _TestSceneReadinessContract([Map<Scenario, SceneReadinessState>? states])
    : _states =
          states ??
          const <Scenario, SceneReadinessState>{
            Scenario.presence: SceneReadinessState.ready,
            Scenario.socialPull: SceneReadinessState.lockedPremium,
            Scenario.exitPressure: SceneReadinessState.needsNotification,
          };

  final Map<Scenario, SceneReadinessState> _states;

  @override
  Future<List<SceneReadinessSnapshot>> getAllReadiness() async {
    return Scenario.values
        .map(
          (scenario) => SceneReadinessSnapshot(
            scenario: scenario,
            state: _states[scenario] ?? SceneReadinessState.ready,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<SceneReadinessSnapshot> getReadiness(Scenario scenario) async {
    return (await getAllReadiness()).singleWhere(
      (snapshot) => snapshot.scenario == scenario,
    );
  }
}

class _DerivedSceneReadinessContract implements SceneReadinessContract {
  const _DerivedSceneReadinessContract({
    required this.appState,
    required this.notificationReadiness,
  });

  final _TestAppStateContract appState;
  final _TestNotificationReadinessContract notificationReadiness;

  @override
  Future<List<SceneReadinessSnapshot>> getAllReadiness() async {
    return Scenario.values
        .map(
          (scenario) => SceneReadinessSnapshot(
            scenario: scenario,
            state: _stateFor(scenario),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<SceneReadinessSnapshot> getReadiness(Scenario scenario) async {
    return SceneReadinessSnapshot(
      scenario: scenario,
      state: _stateFor(scenario),
    );
  }

  SceneReadinessState _stateFor(Scenario scenario) {
    if (scenario == Scenario.presence) {
      return SceneReadinessState.ready;
    }
    if (notificationReadiness.state != NotificationReadinessState.ready) {
      return SceneReadinessState.needsNotification;
    }
    if (!appState.premiumAccess) {
      return SceneReadinessState.lockedPremium;
    }
    return SceneReadinessState.ready;
  }
}

class _TestNotificationReadinessContract
    implements NotificationReadinessContract {
  NotificationReadinessState state = NotificationReadinessState.ready;
  NotificationReadinessState? stateAfterRequest;
  int requestCount = 0;
  int openSettingsCount = 0;

  @override
  Future<NotificationReadinessState> getReadiness() async => state;

  @override
  Future<NotificationReadinessState> requestPermission() async {
    requestCount++;
    if (stateAfterRequest != null) {
      state = stateAfterRequest!;
    }
    return state;
  }

  @override
  Future<void> openSystemSettings() async {
    openSettingsCount++;
  }
}

class _TestPremiumAccessContract implements PremiumAccessContract {
  _TestPremiumAccessContract(this._appStateContract);

  final _TestAppStateContract _appStateContract;
  int restoreCount = 0;

  @override
  Future<PremiumAccessState> getAccessState() async {
    return _appStateContract.premiumAccess
        ? PremiumAccessState.active
        : PremiumAccessState.inactive;
  }

  @override
  Future<void> recordPurchase() async {
    _appStateContract.premiumAccess = true;
  }

  @override
  Future<void> refresh() async {}

  @override
  Future<void> restorePurchases() async {
    restoreCount++;
  }
}

class _TestPaywallContract implements PaywallContract {
  _TestPaywallContract({this.decision = PaywallDecision.showFeatureGate});

  final PaywallDecision decision;

  @override
  Future<PaywallDecision> evaluate({required PaywallSurface surface}) async {
    return decision;
  }

  @override
  Future<void> recordDismissed({required PaywallSurface surface}) async {}
}

class _TestCallFlowCoordinatorContract implements CallFlowCoordinatorContract {
  final _controller = StreamController<CallFlowSnapshot>.broadcast();
  FakeCallState declineResultState;

  _TestCallFlowCoordinatorContract({
    this.declineResultState = FakeCallState.completed,
  });

  @override
  CallFlowSnapshot currentSnapshot = CallFlowSnapshot.idle();

  @override
  Stream<CallFlowSnapshot> get snapshotStream => _controller.stream;

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
      flowState: declineResultState,
      scenario: currentSnapshot.scenario,
      currentStage: currentSnapshot.currentStage,
      callerName: currentSnapshot.callerName,
      sessionId: currentSnapshot.sessionId,
      followUpStage: declineResultState == FakeCallState.awaitingNextStage
          ? currentSnapshot.currentStage + 1
          : null,
      followUpReadyAt: declineResultState == FakeCallState.awaitingNextStage
          ? DateTime.now()
          : null,
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
  Future<void> initialize() async {}

  @override
  Future<void> resumeFromNotification({
    required String sessionId,
    required Scenario scenario,
    required int stage,
  }) async {
    currentSnapshot = CallFlowSnapshot(
      flowState: FakeCallState.ringing,
      scenario: scenario,
      currentStage: stage,
      callerName: switch (scenario) {
        Scenario.presence => 'Xiao Chen',
        Scenario.socialPull => 'Xiao Li',
        Scenario.exitPressure => 'Xiao Zhang',
      },
      sessionId: sessionId,
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
  Future<void> pumpForCallUi(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
  }

  WithYouApp buildApp({
    required _TestAudioLanguagePackManagerContract manager,
    required _TestCallFlowCoordinatorContract coordinator,
    required _TestAppStateContract appState,
    required _TestNotificationReadinessContract notificationReadiness,
    required _TestPremiumAccessContract premiumAccess,
    SceneReadinessContract? sceneReadiness,
    _TestPaywallContract? paywallContract,
    Future<void> Function()? onCallCompletedExit,
    Locale locale = const Locale('en'),
  }) {
    final appRouterContract = AppRouterService(
      appName: 'With You',
      appStateContract: appState,
      callTemplateContract: _TestCallTemplateContract(),
      notificationReadinessContract: notificationReadiness,
      premiumAccessContract: premiumAccess,
      paywallContract: paywallContract ?? _TestPaywallContract(),
    );

    return WithYouApp(
      config: AppConfig(environment: AppEnvironment.prod),
      appLocaleResolverContract: _TestAppLocaleResolverContract(locale),
      appStateContract: appState,
      appRouterContract: appRouterContract,
      audioLanguagePackManagerContract: manager,
      callFlowCoordinatorContract: coordinator,
      sceneReadinessContract: sceneReadiness ?? _TestSceneReadinessContract(),
      onCallCompletedExit: onCallCompletedExit,
    );
  }

  testWidgets('home screen removes environment metadata and opens settings', (
    tester,
  ) async {
    final manager = _TestAudioLanguagePackManagerContract();
    final coordinator = _TestCallFlowCoordinatorContract();
    final appState = _TestAppStateContract();
    final notificationReadiness = _TestNotificationReadinessContract();
    final premiumAccess = _TestPremiumAccessContract(appState);

    await tester.pumpWidget(
      buildApp(
        manager: manager,
        coordinator: coordinator,
        appState: appState,
        notificationReadiness: notificationReadiness,
        premiumAccess: premiumAccess,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Release channel: development'), findsNothing);
    expect(find.text('APP_ENV=dev'), findsNothing);
    expect(find.text('Tap when you need me.'), findsOneWidget);
    expect(find.text('What do you need right now?'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Open settings'));
    await tester.pumpAndSettle();

    expect(find.text('Audio language'), findsWidgets);
    expect(find.text('Unlock Premium'), findsOneWidget);
    expect(find.text('Home-screen widget'), findsNothing);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.textContaining('Traditional Chinese'), findsNothing);
    expect(find.text('English is ready offline.'), findsNothing);
  });

  testWidgets(
    'settings notification row opens system settings when already enabled',
    (tester) async {
      final manager = _TestAudioLanguagePackManagerContract();
      final coordinator = _TestCallFlowCoordinatorContract();
      final appState = _TestAppStateContract();
      final notificationReadiness = _TestNotificationReadinessContract()
        ..state = NotificationReadinessState.ready;
      final premiumAccess = _TestPremiumAccessContract(appState);

      await tester.pumpWidget(
        buildApp(
          manager: manager,
          coordinator: coordinator,
          appState: appState,
          notificationReadiness: notificationReadiness,
          premiumAccess: premiumAccess,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Open settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Open system settings').first);
      await tester.pumpAndSettle();

      expect(notificationReadiness.openSettingsCount, 1);
      expect(notificationReadiness.requestCount, 0);
    },
  );

  testWidgets(
    'settings notification row requests permission then opens system settings when still off',
    (tester) async {
      final manager = _TestAudioLanguagePackManagerContract();
      final coordinator = _TestCallFlowCoordinatorContract();
      final appState = _TestAppStateContract();
      final notificationReadiness = _TestNotificationReadinessContract()
        ..state = NotificationReadinessState.needsPermission
        ..stateAfterRequest = NotificationReadinessState.needsPermission;
      final premiumAccess = _TestPremiumAccessContract(appState);

      await tester.pumpWidget(
        buildApp(
          manager: manager,
          coordinator: coordinator,
          appState: appState,
          notificationReadiness: notificationReadiness,
          premiumAccess: premiumAccess,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Open settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Turn on notifications').first);
      await tester.pumpAndSettle();

      expect(notificationReadiness.requestCount, 1);
      expect(notificationReadiness.openSettingsCount, 1);
    },
  );

  testWidgets('settings only shows bundled audio languages', (tester) async {
    final manager = _TestAudioLanguagePackManagerContract();
    final coordinator = _TestCallFlowCoordinatorContract();
    final appState = _TestAppStateContract();
    final notificationReadiness = _TestNotificationReadinessContract();
    final premiumAccess = _TestPremiumAccessContract(appState);

    await tester.pumpWidget(
      buildApp(
        manager: manager,
        coordinator: coordinator,
        appState: appState,
        notificationReadiness: notificationReadiness,
        premiumAccess: premiumAccess,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Open settings'));
    await tester.pumpAndSettle();

    final audioDropdown = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(audioDropdown);
    await tester.tap(audioDropdown);
    await tester.pumpAndSettle();

    expect(find.textContaining('English'), findsWidgets);
    expect(find.textContaining('Simplified Chinese'), findsWidgets);
    expect(find.textContaining('Traditional Chinese'), findsNothing);
    expect(manager.downloaded, isFalse);
  });

  testWidgets('settings renames Chinese to 繁体字 for zh_TW locale', (
    tester,
  ) async {
    final manager = _TestAudioLanguagePackManagerContract();
    final coordinator = _TestCallFlowCoordinatorContract();
    final appState = _TestAppStateContract();
    final notificationReadiness = _TestNotificationReadinessContract();
    final premiumAccess = _TestPremiumAccessContract(appState);

    await tester.pumpWidget(
      buildApp(
        manager: manager,
        coordinator: coordinator,
        appState: appState,
        notificationReadiness: notificationReadiness,
        premiumAccess: premiumAccess,
        locale: const Locale('zh', 'TW'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Open settings'));
    await tester.pumpAndSettle();

    final audioDropdown = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(audioDropdown);
    await tester.tap(audioDropdown);
    await tester.pumpAndSettle();

    expect(find.textContaining('繁体字'), findsWidgets);
    expect(find.textContaining('Simplified Chinese'), findsNothing);
  });

  testWidgets('starting the stay with me scenario opens the call screen', (
    tester,
  ) async {
    final manager = _TestAudioLanguagePackManagerContract();
    final coordinator = _TestCallFlowCoordinatorContract();
    final appState = _TestAppStateContract();
    final notificationReadiness = _TestNotificationReadinessContract();
    final premiumAccess = _TestPremiumAccessContract(appState);

    await tester.pumpWidget(
      buildApp(
        manager: manager,
        coordinator: coordinator,
        appState: appState,
        notificationReadiness: notificationReadiness,
        premiumAccess: premiumAccess,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Start selected support call'));
    await pumpForCallUi(tester);

    expect(find.bySemanticsLabel('Accept support call'), findsOneWidget);
    expect(find.text('Xiao Chen'), findsOneWidget);
    expect(find.bySemanticsLabel('Caller avatar'), findsNothing);
  });

  testWidgets('completing an in-app call requests app exit on Android', (
    tester,
  ) async {
    final manager = _TestAudioLanguagePackManagerContract();
    final coordinator = _TestCallFlowCoordinatorContract();
    final appState = _TestAppStateContract();
    final notificationReadiness = _TestNotificationReadinessContract();
    final premiumAccess = _TestPremiumAccessContract(appState);
    var exitCount = 0;

    await tester.pumpWidget(
      buildApp(
        manager: manager,
        coordinator: coordinator,
        appState: appState,
        notificationReadiness: notificationReadiness,
        premiumAccess: premiumAccess,
        onCallCompletedExit: () async {
          exitCount++;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Start selected support call'));
    await pumpForCallUi(tester);
    await tester.tap(find.bySemanticsLabel('Decline support call'));
    await pumpForCallUi(tester);

    expect(exitCount, 1);
  });

  testWidgets('dismissing a call stage with follow-up still exits the app', (
    tester,
  ) async {
    final manager = _TestAudioLanguagePackManagerContract();
    final coordinator = _TestCallFlowCoordinatorContract(
      declineResultState: FakeCallState.awaitingNextStage,
    );
    final appState = _TestAppStateContract();
    final notificationReadiness = _TestNotificationReadinessContract();
    final premiumAccess = _TestPremiumAccessContract(appState);
    var exitCount = 0;

    await tester.pumpWidget(
      buildApp(
        manager: manager,
        coordinator: coordinator,
        appState: appState,
        notificationReadiness: notificationReadiness,
        premiumAccess: premiumAccess,
        onCallCompletedExit: () async {
          exitCount++;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Start selected support call'));
    await pumpForCallUi(tester);
    await tester.tap(find.bySemanticsLabel('Decline support call'));
    await pumpForCallUi(tester);

    expect(exitCount, 1);
    expect(find.bySemanticsLabel('Accept support call'), findsNothing);
  });

  testWidgets(
    'locked premium scenarios open the paywall and can unlock premium',
    (tester) async {
      final manager = _TestAudioLanguagePackManagerContract();
      final coordinator = _TestCallFlowCoordinatorContract();
      final appState = _TestAppStateContract();
      final notificationReadiness = _TestNotificationReadinessContract();
      final premiumAccess = _TestPremiumAccessContract(appState);

      await tester.pumpWidget(
        buildApp(
          manager: manager,
          coordinator: coordinator,
          appState: appState,
          notificationReadiness: notificationReadiness,
          premiumAccess: premiumAccess,
          sceneReadiness: _DerivedSceneReadinessContract(
            appState: appState,
            notificationReadiness: notificationReadiness,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('🕒 Ease me out'));
      await tester.pumpAndSettle();

      expect(
        find.text('Unlock follow-up calls for 🕒 Ease me out and 🚪 Get me out'),
        findsOneWidget,
      );

      final purchaseButton = find.byType(ElevatedButton).first;
      await tester.ensureVisible(purchaseButton);
      await tester.tap(purchaseButton);
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Start selected support call'));
      await pumpForCallUi(tester);

      expect(find.bySemanticsLabel('Accept support call'), findsOneWidget);
      expect(find.text('Xiao Li'), findsOneWidget);
    },
  );

  testWidgets(
    'follow-up scenario selection checks notifications then paywall',
    (tester) async {
      final manager = _TestAudioLanguagePackManagerContract();
      final coordinator = _TestCallFlowCoordinatorContract();
      final appState = _TestAppStateContract();
      final notificationReadiness = _TestNotificationReadinessContract()
        ..state = NotificationReadinessState.needsPermission
        ..stateAfterRequest = NotificationReadinessState.ready;
      final premiumAccess = _TestPremiumAccessContract(appState);

      await tester.pumpWidget(
        buildApp(
          manager: manager,
          coordinator: coordinator,
          appState: appState,
          notificationReadiness: notificationReadiness,
          premiumAccess: premiumAccess,
          sceneReadiness: _DerivedSceneReadinessContract(
            appState: appState,
            notificationReadiness: notificationReadiness,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('🚪 Get me out'));
      await tester.pumpAndSettle();

      expect(find.text('Turn on notifications'), findsOneWidget);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(notificationReadiness.requestCount, 1);
      expect(
        find.text('Unlock follow-up calls for 🕒 Ease me out and 🚪 Get me out'),
        findsOneWidget,
      );

      final purchaseButton = find.byType(ElevatedButton).first;
      await tester.ensureVisible(purchaseButton);
      await tester.tap(purchaseButton);
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Start selected support call'));
      await pumpForCallUi(tester);

      expect(find.bySemanticsLabel('Accept support call'), findsOneWidget);
      expect(find.text('Xiao Zhang'), findsOneWidget);
    },
  );

  testWidgets(
    'rejecting notification for get me out bounces selection back to stay with me',
    (tester) async {
      final manager = _TestAudioLanguagePackManagerContract();
      final coordinator = _TestCallFlowCoordinatorContract();
      final appState = _TestAppStateContract();
      final notificationReadiness = _TestNotificationReadinessContract()
        ..state = NotificationReadinessState.needsPermission;
      final premiumAccess = _TestPremiumAccessContract(appState);

      await tester.pumpWidget(
        buildApp(
          manager: manager,
          coordinator: coordinator,
          appState: appState,
          notificationReadiness: notificationReadiness,
          premiumAccess: premiumAccess,
          sceneReadiness: _DerivedSceneReadinessContract(
            appState: appState,
            notificationReadiness: notificationReadiness,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('🚪 Get me out'));
      await tester.pumpAndSettle();

      expect(find.text('Turn on notifications'), findsOneWidget);
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Start selected support call'));
      await pumpForCallUi(tester);

      expect(notificationReadiness.requestCount, 0);
      expect(find.bySemanticsLabel('Accept support call'), findsOneWidget);
      expect(find.text('Xiao Chen'), findsOneWidget);
    },
  );

  testWidgets(
    'dismissing paywall for ease me out bounces selection back to stay with me',
    (tester) async {
      final manager = _TestAudioLanguagePackManagerContract();
      final coordinator = _TestCallFlowCoordinatorContract();
      final appState = _TestAppStateContract();
      final notificationReadiness = _TestNotificationReadinessContract();
      final premiumAccess = _TestPremiumAccessContract(appState);

      await tester.pumpWidget(
        buildApp(
          manager: manager,
          coordinator: coordinator,
          appState: appState,
          notificationReadiness: notificationReadiness,
          premiumAccess: premiumAccess,
          sceneReadiness: _DerivedSceneReadinessContract(
            appState: appState,
            notificationReadiness: notificationReadiness,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('🕒 Ease me out'));
      await tester.pumpAndSettle();

      expect(
        find.text('Unlock follow-up calls for 🕒 Ease me out and 🚪 Get me out'),
        findsOneWidget,
      );
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Start selected support call'));
      await pumpForCallUi(tester);

      expect(find.bySemanticsLabel('Accept support call'), findsOneWidget);
      expect(find.text('Xiao Chen'), findsOneWidget);
    },
  );

  testWidgets('restore purchase path stays visible when nothing is restored', (
    tester,
  ) async {
    final manager = _TestAudioLanguagePackManagerContract();
    final coordinator = _TestCallFlowCoordinatorContract();
    final appState = _TestAppStateContract();
    final notificationReadiness = _TestNotificationReadinessContract();
    final premiumAccess = _TestPremiumAccessContract(appState);

    await tester.pumpWidget(
      buildApp(
        manager: manager,
        coordinator: coordinator,
        appState: appState,
        notificationReadiness: notificationReadiness,
        premiumAccess: premiumAccess,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('🕒 Ease me out'));
    await tester.pumpAndSettle();
    final restoreButton = find.text('Restore purchase');
    await tester.ensureVisible(restoreButton);
    await tester.tap(restoreButton);
    await tester.pumpAndSettle();

    expect(premiumAccess.restoreCount, 1);
    expect(find.text('No premium purchase was restored.'), findsOneWidget);
  });

  testWidgets('settings premium button confirms active entitlement', (
    tester,
  ) async {
    final manager = _TestAudioLanguagePackManagerContract();
    final coordinator = _TestCallFlowCoordinatorContract();
    final appState = _TestAppStateContract()..premiumAccess = true;
    final notificationReadiness = _TestNotificationReadinessContract();
    final premiumAccess = _TestPremiumAccessContract(appState);

    await tester.pumpWidget(
      buildApp(
        manager: manager,
        coordinator: coordinator,
        appState: appState,
        notificationReadiness: notificationReadiness,
        premiumAccess: premiumAccess,
        sceneReadiness:
            _TestSceneReadinessContract(const <Scenario, SceneReadinessState>{
              Scenario.presence: SceneReadinessState.ready,
              Scenario.socialPull: SceneReadinessState.ready,
              Scenario.exitPressure: SceneReadinessState.ready,
            }),
        paywallContract: _TestPaywallContract(decision: PaywallDecision.hidden),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Open settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Premium active'));
    await tester.pumpAndSettle();

    expect(
      find.text('Premium is active. You can use all features.'),
      findsOneWidget,
    );
  });
}
