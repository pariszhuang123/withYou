import 'package:flutter/widgets.dart';

import '../app.dart';
import '../config/app_config.dart';
import '../contracts/app_contracts.dart';
import '../contracts/audio_contracts.dart';
import '../contracts/call_flow_contracts.dart';
import '../contracts/commerce_contracts.dart';
import '../contracts/readiness_contracts.dart';
import '../services/app_notification_launch_service.dart';
import '../services/app_widget_launch_service.dart';
import 'service_locator.dart';

Future<Widget> bootstrapWithYouApp(AppConfig config) async {
  await setupServiceLocator(config: config);
  return WithYouApp(
    config: config,
    appLocaleResolverContract: sl<AppLocaleResolverContract>(),
    appStateContract: sl<AppStateContract>(),
    appRouterContract: sl<AppRouterContract>(),
    audioLanguagePackManagerContract: sl<AudioLanguagePackManagerContract>(),
    callFlowCoordinatorContract: sl<CallFlowCoordinatorContract>(),
    sceneReadinessContract: sl<SceneReadinessContract>(),
    startupWarmup: () async {
      final callFlowCoordinator = sl<CallFlowCoordinatorContract>();
      await sl<PremiumAccessContract>().refresh();
      sl<AppNotificationLaunchService>().start();
      sl<AppWidgetLaunchService>().start();
      await sl<NotificationContract>().initialize();
      await callFlowCoordinator.initialize();
    },
  );
}
