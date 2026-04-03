import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/audio_language_cubit.dart';
import 'blocs/call_flow_cubit.dart';
import 'config/app_config.dart';
import 'contracts/app_contracts.dart';
import 'contracts/audio_contracts.dart';
import 'contracts/call_flow_contracts.dart';
import 'contracts/readiness_contracts.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';

class WithYouApp extends StatelessWidget {
  const WithYouApp({
    required this.config,
    required this.appLocaleResolverContract,
    required this.appStateContract,
    required this.appRouterContract,
    required this.audioLanguagePackManagerContract,
    required this.callFlowCoordinatorContract,
    required this.sceneReadinessContract,
    super.key,
  });

  final AppConfig config;
  final AppLocaleResolverContract appLocaleResolverContract;
  final AppStateContract appStateContract;
  final AppRouterContract appRouterContract;
  final AudioLanguagePackManagerContract audioLanguagePackManagerContract;
  final CallFlowCoordinatorContract callFlowCoordinatorContract;
  final SceneReadinessContract sceneReadinessContract;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              AudioLanguageCubit(manager: audioLanguagePackManagerContract)
                ..load(WidgetsBinding.instance.platformDispatcher.locales),
        ),
        BlocProvider(
          create: (_) => CallFlowCubit(
            coordinator: callFlowCoordinatorContract,
            appStateContract: appStateContract,
            sceneReadinessContract: sceneReadinessContract,
          ),
        ),
      ],
      child: BlocListener<CallFlowCubit, CallFlowState>(
        listenWhen: (previous, current) =>
            previous.showsCallScreen != current.showsCallScreen,
        listener: (context, state) {
          appRouterContract.syncCallRoute(
            visible: state.showsCallScreen,
            scenario: state.activeScenario ?? state.selectedScenario,
            stage: state.currentStage,
            sessionId: state.sessionId,
          );
        },
        child: MaterialApp.router(
          title: config.appName,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.system,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          localeListResolutionCallback: (preferredLocales, supportedLocales) {
            return appLocaleResolverContract.resolve(
              preferredLocales: preferredLocales,
              supportedLocales: supportedLocales.toList(growable: false),
            );
          },
          routerConfig: appRouterContract.routerConfig,
        ),
      ),
    );
  }
}
