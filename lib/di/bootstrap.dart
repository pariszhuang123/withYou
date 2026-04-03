import 'package:flutter/widgets.dart';

import '../app.dart';
import '../config/app_config.dart';
import '../contracts/app_contracts.dart';
import '../contracts/audio_contracts.dart';
import '../contracts/call_flow_contracts.dart';
import '../contracts/readiness_contracts.dart';
import '../services/app_notification_launch_service.dart';
import 'service_locator.dart';

Future<Widget> bootstrapWithYouApp(AppConfig config) async {
  await setupServiceLocator(config: config);
  final callFlowCoordinator = sl<CallFlowCoordinatorContract>();
  sl<AppNotificationLaunchService>().start();
  await sl<NotificationContract>().initialize();
  await callFlowCoordinator.initialize();
  return WithYouApp(
    config: config,
    appLocaleResolverContract: sl<AppLocaleResolverContract>(),
    appStateContract: sl<AppStateContract>(),
    appRouterContract: sl<AppRouterContract>(),
    audioLanguagePackManagerContract: sl<AudioLanguagePackManagerContract>(),
    callFlowCoordinatorContract: sl<CallFlowCoordinatorContract>(),
    sceneReadinessContract: sl<SceneReadinessContract>(),
  );
}
