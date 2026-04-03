import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/blocs/call_flow_cubit.dart';
import 'package:with_you/contracts/app_contracts.dart';
import 'package:with_you/contracts/call_flow_contracts.dart';
import 'package:with_you/contracts/commerce_contracts.dart';
import 'package:with_you/contracts/readiness_contracts.dart';
import 'package:with_you/l10n/app_localizations.dart';
import 'package:with_you/services/app_router_service.dart';
import 'package:with_you/theme/app_theme.dart';

class _TestAppStateContract implements AppStateContract {
  Scenario? selectedScenario;

  @override
  Future<String?> getSelectedAudioLocaleTag() async => null;

  @override
  Future<Scenario?> getSelectedScenario() async => selectedScenario;

  @override
  Future<bool> hasPremiumAccess() async => false;

  @override
  Future<void> setPremiumAccess(bool hasPremiumAccess) async {}

  @override
  Future<void> setSelectedAudioLocaleTag(String localeTag) async {}

  @override
  Future<void> setSelectedScenario(Scenario scenario) async {
    selectedScenario = scenario;
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

class _TestNotificationReadinessContract
    implements NotificationReadinessContract {
  @override
  Future<NotificationReadinessState> getReadiness() async {
    return NotificationReadinessState.ready;
  }

  @override
  Future<NotificationReadinessState> requestPermission() async {
    return NotificationReadinessState.ready;
  }

  @override
  Future<void> openSystemSettings() async {}
}

class _TestPremiumAccessContract implements PremiumAccessContract {
  @override
  Future<PremiumAccessState> getAccessState() async {
    return PremiumAccessState.inactive;
  }

  @override
  Future<void> recordPurchase() async {}

  @override
  Future<void> refresh() async {}

  @override
  Future<void> restorePurchases() async {}
}

class _TestPaywallContract implements PaywallContract {
  @override
  Future<PaywallDecision> evaluate({required PaywallSurface surface}) async {
    return PaywallDecision.showFeatureGate;
  }

  @override
  Future<void> recordDismissed({required PaywallSurface surface}) async {}
}

class _TestCallFlowCoordinatorContract implements CallFlowCoordinatorContract {
  @override
  CallFlowSnapshot currentSnapshot = CallFlowSnapshot.idle();

  @override
  Stream<CallFlowSnapshot> get snapshotStream => const Stream.empty();

  @override
  Future<void> acceptCurrentStage() async {}

  @override
  Future<void> declineCurrentStage() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> endCurrentStage() async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> resumeFromNotification({
    required String sessionId,
    required Scenario scenario,
    required int stage,
  }) async {}

  @override
  Future<void> startFlow(Scenario scenario) async {}

  @override
  Future<void> triggerFollowUpStage() async {}
}

class _TestSceneReadinessContract implements SceneReadinessContract {
  @override
  Future<List<SceneReadinessSnapshot>> getAllReadiness() async {
    return Scenario.values
        .map(
          (scenario) => SceneReadinessSnapshot(
            scenario: scenario,
            state: SceneReadinessState.ready,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<SceneReadinessSnapshot> getReadiness(Scenario scenario) async {
    return SceneReadinessSnapshot(
      scenario: scenario,
      state: SceneReadinessState.ready,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  AppRouterService buildService(_TestAppStateContract appState) {
    return AppRouterService(
      appName: 'With You',
      appStateContract: appState,
      callTemplateContract: _TestCallTemplateContract(),
      notificationReadinessContract: _TestNotificationReadinessContract(),
      premiumAccessContract: _TestPremiumAccessContract(),
      paywallContract: _TestPaywallContract(),
    );
  }

  test('starts on the home route by default', () {
    final service = buildService(_TestAppStateContract());

    expect(service.currentRoute.destination, AppRouteDestination.home);
  });

  test('handleExternalIntent persists a widget-selected scenario', () async {
    final appState = _TestAppStateContract();
    final service = buildService(appState);

    await service.handleExternalIntent(
      const AppLaunchIntent(
        source: AppLaunchSource.homeScreenWidget,
        destination: AppRouteDestination.home,
        scenario: Scenario.socialPull,
      ),
    );

    expect(appState.selectedScenario, Scenario.socialPull);
    expect(service.currentRoute.destination, AppRouteDestination.home);
  });

  testWidgets(
    'queued notification call intent routes to the call screen after router attach',
    (tester) async {
      final appState = _TestAppStateContract();
      final service = buildService(appState);

      await service.handleExternalIntent(
        const AppLaunchIntent(
          source: AppLaunchSource.notification,
          destination: AppRouteDestination.call,
          scenario: Scenario.exitPressure,
          stage: 2,
          sessionId: 'session-99',
        ),
      );

      await tester.pumpWidget(
        BlocProvider(
          create: (_) => CallFlowCubit(
            coordinator: _TestCallFlowCoordinatorContract(),
            appStateContract: appState,
            sceneReadinessContract: _TestSceneReadinessContract(),
          ),
          child: MaterialApp.router(
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: service.routerConfig,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(service.currentRoute.destination, AppRouteDestination.call);
      expect(service.currentRoute.scenario, Scenario.exitPressure);
      expect(service.currentRoute.stage, 2);
      expect(service.currentRoute.sessionId, 'session-99');
      expect(appState.selectedScenario, Scenario.exitPressure);
    },
  );
}
