import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/app.dart';
import 'package:with_you/config/app_config.dart';
import 'package:with_you/config/app_environment.dart';
import 'package:with_you/contracts/app_contracts.dart';
import 'package:with_you/contracts/call_flow_contracts.dart';
import 'package:with_you/contracts/commerce_contracts.dart';
import 'package:with_you/contracts/platform_contracts.dart';
import 'package:with_you/contracts/readiness_contracts.dart';
import 'package:with_you/di/bootstrap.dart';
import 'package:with_you/di/service_locator.dart';
import 'package:with_you/services/app_notification_launch_service.dart';
import 'package:with_you/services/app_widget_launch_service.dart';

class _TestNotificationContract implements NotificationContract {
  int initializeCount = 0;

  @override
  Stream<NotificationEvent> get eventStream =>
      const Stream<NotificationEvent>.empty();

  @override
  Future<void> cancelAll(String sessionId) async {}

  @override
  Future<bool> initialize() async {
    initializeCount++;
    return true;
  }

  @override
  Future<void> openSystemSettings() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> scheduleFollowUp({
    required String sessionId,
    required Scenario scenario,
    required int stage,
    required Duration delay,
    required String title,
    required String body,
  }) async {}
}

class _TestCallFlowCoordinatorContract implements CallFlowCoordinatorContract {
  int initializeCount = 0;

  @override
  CallFlowSnapshot get currentSnapshot => CallFlowSnapshot.idle();

  @override
  Stream<CallFlowSnapshot> get snapshotStream =>
      const Stream<CallFlowSnapshot>.empty();

  @override
  Future<void> acceptCurrentStage() async {}

  @override
  Future<void> declineCurrentStage() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> endCurrentStage() async {}

  @override
  Future<void> initialize() async {
    initializeCount++;
  }

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

class _TestAppNotificationLaunchService extends AppNotificationLaunchService {
  _TestAppNotificationLaunchService()
    : super(
        notificationContract: _TestNotificationContract(),
        callFlowCoordinatorContract: _TestCallFlowCoordinatorContract(),
        appRouterContract: _NoopAppRouterContract(),
      );

  int startCount = 0;

  @override
  void start() {
    startCount++;
  }
}

class _TestWidgetVisualStateContract implements WidgetVisualStateContract {
  int syncCount = 0;

  @override
  Future<void> syncPremiumAccess({required bool isActive}) async {
    syncCount++;
  }
}

class _TestPremiumAccessContract implements PremiumAccessContract {
  int refreshCount = 0;

  @override
  Future<PremiumAccessState> getAccessState() async {
    return PremiumAccessState.inactive;
  }

  @override
  Future<void> recordPurchase() async {}

  @override
  Future<void> refresh() async {
    refreshCount++;
  }

  @override
  Future<void> restorePurchases() async {}
}

class _TestAppWidgetLaunchService extends AppWidgetLaunchService {
  _TestAppWidgetLaunchService()
    : super(
        widgetLaunchEventContract: _NoopWidgetLaunchEventContract(),
        widgetLaunchContract: _NoopWidgetLaunchContract(),
        appStateContract: _NoopAppStateContract(),
        callFlowCoordinatorContract: _TestCallFlowCoordinatorContract(),
        appRouterContract: _NoopAppRouterContract(),
      );

  int startCount = 0;

  @override
  void start() {
    startCount++;
  }
}

class _NoopWidgetLaunchEventContract implements WidgetLaunchEventContract {
  @override
  Stream<WidgetLaunchEvent> get eventStream =>
      const Stream<WidgetLaunchEvent>.empty();
}

class _NoopWidgetLaunchContract implements WidgetLaunchContract {
  @override
  Future<WidgetLaunchPlan> planLaunch({
    required LaunchSurface surface,
    required Scenario selectedScenario,
  }) async {
    throw UnimplementedError();
  }
}

class _NoopAppStateContract implements AppStateContract {
  @override
  Future<String?> getSelectedAudioLocaleTag() async => null;

  @override
  Future<Scenario?> getSelectedScenario() async => null;

  @override
  Future<bool> hasPremiumAccess() async => false;

  @override
  Future<void> setPremiumAccess(bool hasPremiumAccess) async {}

  @override
  Future<void> setSelectedAudioLocaleTag(String localeTag) async {}

  @override
  Future<void> setSelectedScenario(Scenario scenario) async {}
}

class _NoopAppRouterContract implements AppRouterContract {
  @override
  AppRouteState get currentRoute => const AppRouteState.home();

  @override
  Future<void> goHome() async {}

  @override
  Future<void> handleExternalIntent(AppLaunchIntent intent) async {}

  @override
  Future<void> openSettings() async {}

  @override
  Future<bool> openPaywall({
    Scenario? scenario,
    AppLaunchIntent? intent,
  }) async => false;

  @override
  RouterConfig<Object> get routerConfig => throw UnimplementedError();

  @override
  Future<void> syncCallRoute({
    required bool visible,
    Scenario? scenario,
    int? stage,
    String? sessionId,
    AppLaunchIntent? intent,
  }) async {}
}

void main() {
  tearDown(() async {
    await sl.reset();
  });

  test(
    'bootstrap startupWarmup starts both launch listeners and initializes services',
    () async {
      final bootstrapped = await bootstrapWithYouApp(
        AppConfig(environment: AppEnvironment.prod),
      );
      final app = bootstrapped as WithYouApp;
      final notificationContract = _TestNotificationContract();
      final coordinator = _TestCallFlowCoordinatorContract();
      final notificationLaunch = _TestAppNotificationLaunchService();
      final widgetLaunch = _TestAppWidgetLaunchService();
      final premiumAccess = _TestPremiumAccessContract();

      await sl.unregister<NotificationContract>();
      await sl.unregister<CallFlowCoordinatorContract>();
      await sl.unregister<AppNotificationLaunchService>();
      await sl.unregister<AppWidgetLaunchService>();
      await sl.unregister<WidgetVisualStateContract>();
      await sl.unregister<PremiumAccessContract>();

      sl.registerSingleton<NotificationContract>(notificationContract);
      sl.registerSingleton<CallFlowCoordinatorContract>(coordinator);
      sl.registerSingleton<AppNotificationLaunchService>(notificationLaunch);
      sl.registerSingleton<AppWidgetLaunchService>(widgetLaunch);
      sl.registerSingleton<WidgetVisualStateContract>(
        _TestWidgetVisualStateContract(),
      );
      sl.registerSingleton<PremiumAccessContract>(premiumAccess);

      await app.startupWarmup!.call();

      expect(notificationLaunch.startCount, 1);
      expect(widgetLaunch.startCount, 1);
      expect(premiumAccess.refreshCount, 1);
      expect(notificationContract.initializeCount, 1);
      expect(coordinator.initializeCount, 1);
    },
  );
}
