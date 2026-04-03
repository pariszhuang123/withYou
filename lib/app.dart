import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

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
    this.startupWarmup,
    this.onCallCompletedExit,
    super.key,
  });

  final AppConfig config;
  final AppLocaleResolverContract appLocaleResolverContract;
  final AppStateContract appStateContract;
  final AppRouterContract appRouterContract;
  final AudioLanguagePackManagerContract audioLanguagePackManagerContract;
  final CallFlowCoordinatorContract callFlowCoordinatorContract;
  final SceneReadinessContract sceneReadinessContract;
  final Future<void> Function()? startupWarmup;
  final Future<void> Function()? onCallCompletedExit;

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
      child: BlocConsumer<CallFlowCubit, CallFlowState>(
        listenWhen: (previous, current) =>
            previous.showsCallScreen != current.showsCallScreen,
        listener: (context, state) async {
          await appRouterContract.syncCallRoute(
            visible: state.showsCallScreen,
            scenario: state.activeScenario ?? state.selectedScenario,
            stage: state.currentStage,
            sessionId: state.sessionId,
          );

          if (!state.showsCallScreen && state.flowState != FakeCallState.idle) {
            await (onCallCompletedExit ?? _defaultCallCompletedExit)();
          }
        },
        builder: (context, state) {
          return _LifecycleAwareAppShell(
            startupWarmup: startupWarmup,
            child: MaterialApp.router(
              title: config.appName,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: ThemeMode.system,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              localeListResolutionCallback:
                  (preferredLocales, supportedLocales) {
                    return appLocaleResolverContract.resolve(
                      preferredLocales: preferredLocales,
                      supportedLocales: supportedLocales.toList(
                        growable: false,
                      ),
                    );
                  },
              routerConfig: appRouterContract.routerConfig,
            ),
          );
        },
      ),
    );
  }

  static Future<void> _defaultCallCompletedExit() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    await SystemNavigator.pop();
  }
}

class _LifecycleAwareAppShell extends StatefulWidget {
  const _LifecycleAwareAppShell({required this.child, this.startupWarmup});

  final Widget child;
  final Future<void> Function()? startupWarmup;

  @override
  State<_LifecycleAwareAppShell> createState() =>
      _LifecycleAwareAppShellState();
}

class _LifecycleAwareAppShellState extends State<_LifecycleAwareAppShell> {
  late final AppLifecycleListener _appLifecycleListener;
  bool _startupWarmupStarted = false;

  @override
  void initState() {
    super.initState();
    _appLifecycleListener = AppLifecycleListener(
      onResume: _markForeground,
      onInactive: _markBackground,
      onPause: _markBackground,
      onHide: _markBackground,
      onDetach: _markBackground,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _startWarmup();
      _markForeground();
    });
  }

  @override
  void dispose() {
    _appLifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  void _startWarmup() {
    if (_startupWarmupStarted) {
      return;
    }
    _startupWarmupStarted = true;
    final startupWarmup = widget.startupWarmup;
    if (startupWarmup == null) {
      return;
    }

    Future<void>(() async {
      try {
        await startupWarmup();
      } catch (error, stackTrace) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            library: 'with_you_startup',
            context: ErrorDescription('while warming startup services'),
          ),
        );
      }
    });
  }

  void _markForeground() {
    context.read<CallFlowCubit>().setAppInForeground(true);
  }

  void _markBackground() {
    context.read<CallFlowCubit>().setAppInForeground(false);
  }
}
