import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/call_flow_cubit.dart';
import 'blocs/audio_language_cubit.dart';
import 'config/app_config.dart';
import 'contracts/app_contracts.dart';
import 'contracts/audio_contracts.dart';
import 'contracts/call_flow_contracts.dart';
import 'contracts/readiness_contracts.dart';
import 'l10n/app_localizations.dart';
import 'models/audio_language.dart';
import 'theme/app_theme.dart';
import 'theme/design_tokens.dart';
import 'widgets/call_templates/call_template_renderer.dart';
import 'widgets/call_templates/call_template_widget.dart';
import 'widgets/themed_components.dart';

class WithYouApp extends StatelessWidget {
  const WithYouApp({
    required this.config,
    required this.appLocaleResolverContract,
    required this.appStateContract,
    required this.audioLanguagePackManagerContract,
    required this.callFlowCoordinatorContract,
    required this.callTemplateContract,
    required this.sceneReadinessContract,
    super.key,
  });

  final AppConfig config;
  final AppLocaleResolverContract appLocaleResolverContract;
  final AppStateContract appStateContract;
  final AudioLanguagePackManagerContract audioLanguagePackManagerContract;
  final CallFlowCoordinatorContract callFlowCoordinatorContract;
  final CallTemplateContract callTemplateContract;
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
          create: (_) =>
              CallFlowCubit(
                coordinator: callFlowCoordinatorContract,
                appStateContract: appStateContract,
                sceneReadinessContract: sceneReadinessContract,
              ),
        ),
      ],
      child: MaterialApp(
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
        home: _EnvironmentHome(
          config: config,
          callTemplateContract: callTemplateContract,
        ),
      ),
    );
  }
}

class _EnvironmentHome extends StatelessWidget {
  const _EnvironmentHome({
    required this.config,
    required this.callTemplateContract,
  });

  final AppConfig config;
  final CallTemplateContract callTemplateContract;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CallFlowCubit, CallFlowState>(
      builder: (context, callFlowState) {
        if (callFlowState.showsCallScreen) {
          return _CallFlowScaffold(
            config: config,
            callTemplateContract: callTemplateContract,
            state: callFlowState,
          );
        }

        return _HomeScaffold(config: config, callFlowState: callFlowState);
      },
    );
  }
}

class _HomeScaffold extends StatelessWidget {
  const _HomeScaffold({required this.config, required this.callFlowState});

  final AppConfig config;
  final CallFlowState callFlowState;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.appSpacing;
    final colors = theme.appColors;
    final callFlowCubit = context.read<CallFlowCubit>();
    final presenceReadiness = callFlowState.sceneReadiness[Scenario.presence];
    final socialPullReadiness =
        callFlowState.sceneReadiness[Scenario.socialPull];
    final exitPressureReadiness =
        callFlowState.sceneReadiness[Scenario.exitPressure];

    return Scaffold(
      appBar: AppBar(title: Text(config.appName)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(spacing.large),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: BlocBuilder<AudioLanguageCubit, AudioLanguageState>(
                builder: (context, state) {
                  return ThemedCard(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            config.appName,
                            style: theme.textTheme.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: spacing.small),
                          Text(
                            localizations.homeSubtitle,
                            style: theme.textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: spacing.large),
                          ThemedSurfacePanel(
                            backgroundColor: colors.surfaceCritical,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Release channel: ${config.releaseChannel}',
                                  style: theme.textTheme.bodyLarge,
                                ),
                                SizedBox(height: spacing.xSmall),
                                Text(
                                  'APP_ENV=${config.environmentLabel.toLowerCase()}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: spacing.large),
                          Text(
                            localizations.scenarioSelector,
                            style: theme.textTheme.titleLarge,
                          ),
                          SizedBox(height: spacing.medium),
                          SegmentedButton<Scenario>(
                            segments: <ButtonSegment<Scenario>>[
                              ButtonSegment<Scenario>(
                                value: Scenario.presence,
                                icon: _statusIconFor(presenceReadiness),
                                label: Text(localizations.scenarioPresence),
                              ),
                              ButtonSegment<Scenario>(
                                value: Scenario.socialPull,
                                icon: _statusIconFor(socialPullReadiness),
                                label: Text(localizations.scenarioSocialPull),
                              ),
                              ButtonSegment<Scenario>(
                                value: Scenario.exitPressure,
                                icon: _statusIconFor(exitPressureReadiness),
                                label: Text(localizations.scenarioExitPressure),
                              ),
                            ],
                            selected: <Scenario>{
                              callFlowState.selectedScenario,
                            },
                            onSelectionChanged: (selection) {
                              unawaited(
                                callFlowCubit.selectScenario(selection.first),
                              );
                            },
                          ),
                          if (callFlowState.sceneReadiness.isNotEmpty) ...[
                            SizedBox(height: spacing.medium),
                            _ScenarioReadinessSummary(state: callFlowState),
                          ],
                          SizedBox(height: spacing.large),
                          Text(
                            localizations.audioLanguageSectionTitle,
                            style: theme.textTheme.titleLarge,
                          ),
                          SizedBox(height: spacing.xSmall),
                          Text(
                            localizations.audioLanguageSectionSubtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          SizedBox(height: spacing.medium),
                          if (state.isLoading)
                            const Center(child: CircularProgressIndicator())
                          else
                            ...state.languages.map(
                              (language) => _LanguageTile(
                                language: language,
                                selectedLocaleTag: state.selectedLocaleTag,
                              ),
                            ),
                          SizedBox(height: spacing.medium),
                          Text(
                            localizations.audioLanguageFallbackHint,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          SizedBox(height: spacing.large),
                          if (callFlowState.flowState ==
                              FakeCallState.awaitingNextStage)
                            Padding(
                              padding: EdgeInsets.only(bottom: spacing.large),
                              child: _AwaitingStageCard(state: callFlowState),
                            ),
                          if (callFlowState.flowState ==
                              FakeCallState.completed)
                            Padding(
                              padding: EdgeInsets.only(bottom: spacing.large),
                              child: _CompletedFlowCard(
                                scenario:
                                    callFlowState.activeScenario ??
                                    callFlowState.selectedScenario,
                              ),
                            ),
                          ThemedButton(
                            onPressed: () => callFlowCubit.startFlow(),
                            semanticLabel: 'Start support call',
                            size: ThemedButtonSize.homeTrigger,
                            child: Text(localizations.incomingCall),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget? _statusIconFor(SceneReadinessSnapshot? snapshot) {
  if (snapshot == null) {
    return null;
  }

  return switch (snapshot.state) {
    SceneReadinessState.ready => const Icon(Icons.check_circle_outline),
    SceneReadinessState.needsNotification => const Icon(
      Icons.notifications_off_outlined,
    ),
    SceneReadinessState.lockedPremium => const Icon(Icons.lock_outline),
  };
}

class _ScenarioReadinessSummary extends StatelessWidget {
  const _ScenarioReadinessSummary({required this.state});

  final CallFlowState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final selectedSnapshot = state.sceneReadiness[state.selectedScenario];

    return Text(
      'Selected scene: ${_scenarioLabel(localizations, state.selectedScenario)} · ${_readinessLabel(selectedSnapshot)}',
      style: theme.textTheme.bodyMedium,
    );
  }

  String _scenarioLabel(AppLocalizations localizations, Scenario scenario) {
    return switch (scenario) {
      Scenario.presence => localizations.scenarioPresence,
      Scenario.socialPull => localizations.scenarioSocialPull,
      Scenario.exitPressure => localizations.scenarioExitPressure,
    };
  }

  String _readinessLabel(SceneReadinessSnapshot? snapshot) {
    if (snapshot == null) {
      return 'Checking readiness';
    }

    return switch (snapshot.state) {
      SceneReadinessState.ready => 'Ready',
      SceneReadinessState.needsNotification => 'Enable notifications',
      SceneReadinessState.lockedPremium => 'Premium required',
    };
  }
}

class _AwaitingStageCard extends StatelessWidget {
  const _AwaitingStageCard({required this.state});

  final CallFlowState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.appSpacing;
    final readyIn = _formatRemaining(state.followUpRemaining);

    return ThemedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Next stage scheduled', style: theme.textTheme.titleLarge),
          SizedBox(height: spacing.small),
          Text(
            'Stage ${state.followUpStage} will be ready after the randomized delay.',
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: spacing.small),
          Text(
            state.followUpReady ? 'Follow-up ready now.' : 'Ready in $readyIn',
            style: theme.textTheme.bodyLarge,
          ),
          SizedBox(height: spacing.medium),
          Text(
            'Follow-up delivery is now handled by the platform notification bridge.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _formatRemaining(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _CompletedFlowCard extends StatelessWidget {
  const _CompletedFlowCard({required this.scenario});

  final Scenario scenario;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.appSpacing;

    return ThemedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Flow completed', style: theme.textTheme.titleLarge),
          SizedBox(height: spacing.small),
          Text(
            'The ${scenario.name} flow finished. You can start another flow at any time.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.language,
    required this.selectedLocaleTag,
  });

  final AudioLanguageAvailability language;
  final String? selectedLocaleTag;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final cubit = context.read<AudioLanguageCubit>();
    final theme = Theme.of(context);
    final spacing = theme.appSpacing;
    final isSelected = language.language.localeTag == selectedLocaleTag;

    return Card(
      margin: EdgeInsets.only(bottom: spacing.small),
      child: ListTile(
        onTap: () => cubit.selectLanguage(language.language.localeTag),
        leading: Icon(
          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        ),
        title: Text(language.language.displayName),
        subtitle: Text(
          _statusLabel(localizations, language.status, language.isReadyOffline),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Padding(
                padding: EdgeInsets.only(right: spacing.small),
                child: Text(
                  localizations.audioLanguageSelected,
                  style: theme.textTheme.labelMedium,
                ),
              ),
            _buildTrailingAction(context, localizations),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailingAction(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    final cubit = context.read<AudioLanguageCubit>();
    final spinnerSize = Theme.of(context).appSpacing.large;
    switch (language.status) {
      case AudioLanguagePackStatus.downloaded:
        return const Icon(Icons.check_circle_outline);
      case AudioLanguagePackStatus.downloading:
        return SizedBox(
          width: spinnerSize,
          height: spinnerSize,
          child: const CircularProgressIndicator(strokeWidth: 2),
        );
      case AudioLanguagePackStatus.failed:
      case AudioLanguagePackStatus.notDownloaded:
      case AudioLanguagePackStatus.updateAvailable:
        if (language.language.isBundled) {
          return const Icon(Icons.check_circle_outline);
        }
        return ThemedIconButton(
          semanticLabel: localizations.audioLanguageDownload,
          tooltip: localizations.audioLanguageDownload,
          onPressed: () => cubit.downloadLanguage(language.language.localeTag),
          icon: Icons.download_outlined,
        );
    }
  }

  String _statusLabel(
    AppLocalizations localizations,
    AudioLanguagePackStatus status,
    bool isReadyOffline,
  ) {
    if (isReadyOffline) {
      return localizations.audioLanguageReady;
    }

    switch (status) {
      case AudioLanguagePackStatus.notDownloaded:
        return localizations.audioLanguageNotDownloaded;
      case AudioLanguagePackStatus.downloading:
        return localizations.audioLanguageDownloading;
      case AudioLanguagePackStatus.failed:
        return localizations.audioLanguageFailed;
      case AudioLanguagePackStatus.updateAvailable:
        return localizations.audioLanguageDownload;
      case AudioLanguagePackStatus.downloaded:
        return localizations.audioLanguageReady;
    }
  }
}

class _CallFlowScaffold extends StatelessWidget {
  const _CallFlowScaffold({
    required this.config,
    required this.callTemplateContract,
    required this.state,
  });

  final AppConfig config;
  final CallTemplateContract callTemplateContract;
  final CallFlowState state;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final spec = callTemplateContract.resolve(
      locale,
      Theme.of(context).platform,
    );

    return Scaffold(
      body: CallTemplateRenderer(
        spec: spec,
        visualState: state.flowState == FakeCallState.ringing
            ? CallScreenVisualState.ringing
            : CallScreenVisualState.inCall,
        callerName: state.callerName ?? config.appName,
        callDuration: state.callDuration,
        onAccept: () => context.read<CallFlowCubit>().accept(),
        onDecline: () => context.read<CallFlowCubit>().decline(),
        onEnd: () => context.read<CallFlowCubit>().end(),
      ),
    );
  }
}
