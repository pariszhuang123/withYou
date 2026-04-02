import 'package:flutter/widgets.dart';

import '../app.dart';
import '../config/app_config.dart';
import '../contracts/app_contracts.dart';
import '../contracts/audio_contracts.dart';
import '../contracts/call_flow_contracts.dart';
import '../contracts/readiness_contracts.dart';
import 'service_locator.dart';

Future<Widget> bootstrapWithYouApp(AppConfig config) async {
  await setupServiceLocator(config: config);
  await sl<NotificationContract>().initialize();
  await sl<CallFlowCoordinatorContract>().initialize();
  return WithYouApp(
    config: config,
    appLocaleResolverContract: sl<AppLocaleResolverContract>(),
    appStateContract: sl<AppStateContract>(),
    audioLanguagePackManagerContract: sl<AudioLanguagePackManagerContract>(),
    callFlowCoordinatorContract: sl<CallFlowCoordinatorContract>(),
    callTemplateContract: sl<CallTemplateContract>(),
    sceneReadinessContract: sl<SceneReadinessContract>(),
  );
}
