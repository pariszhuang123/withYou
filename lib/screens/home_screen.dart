import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/call_flow_cubit.dart';
import '../contracts/call_flow_contracts.dart';
import '../contracts/commerce_contracts.dart';
import '../contracts/readiness_contracts.dart';
import '../l10n/app_localizations.dart';
import '../theme/design_tokens.dart';
import '../widgets/themed_components.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.notificationReadinessContract,
    required this.paywallContract,
    required this.onOpenSettings,
    required this.onOpenPaywall,
    super.key,
  });

  final NotificationReadinessContract notificationReadinessContract;
  final PaywallContract paywallContract;
  final VoidCallback onOpenSettings;
  final Future<bool> Function(Scenario scenario) onOpenPaywall;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isHandlingTrigger = false;
  bool _isHandlingSelection = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.appSpacing;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.only(right: spacing.small),
            child: Center(
              child: ThemedIconButton(
                icon: Icons.settings_outlined,
                semanticLabel: localizations.homeOpenSettingsSemanticLabel,
                tooltip: localizations.settings,
                onPressed: widget.onOpenSettings,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: EdgeInsets.all(spacing.large),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 640,
                  minHeight: constraints.maxHeight > (spacing.large * 2)
                      ? constraints.maxHeight - (spacing.large * 2)
                      : 0,
                ),
                child: BlocBuilder<CallFlowCubit, CallFlowState>(
                  builder: (context, callFlowState) {
                    final selectedSnapshot = callFlowState
                        .sceneReadiness[callFlowState.selectedScenario];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ThemedCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                localizations.homeSupportStyleTitle,
                                style: theme.textTheme.headlineMedium,
                              ),
                              SizedBox(height: spacing.large),
                              _ScenarioSelectionCard(
                                title: localizations.homeSupportStyleGentle,
                                snapshot: callFlowState.sceneReadiness[
                                    Scenario.presence],
                                selected:
                                    callFlowState.selectedScenario ==
                                    Scenario.presence,
                                onPressed: () => _selectScenario(
                                  context,
                                  Scenario.presence,
                                ),
                              ),
                              SizedBox(height: spacing.medium),
                              _ScenarioSelectionCard(
                                title: localizations.homeSupportStyleSteady,
                                snapshot: callFlowState.sceneReadiness[
                                    Scenario.socialPull],
                                selected:
                                    callFlowState.selectedScenario ==
                                    Scenario.socialPull,
                                onPressed: () => _selectScenario(
                                  context,
                                  Scenario.socialPull,
                                ),
                              ),
                              SizedBox(height: spacing.medium),
                              _ScenarioSelectionCard(
                                title: localizations.homeSupportStyleUrgent,
                                snapshot: callFlowState.sceneReadiness[
                                    Scenario.exitPressure],
                                selected:
                                    callFlowState.selectedScenario ==
                                    Scenario.exitPressure,
                                onPressed: () => _selectScenario(
                                  context,
                                  Scenario.exitPressure,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: spacing.xLarge),
                        Center(
                          child: GestureDetector(
                            onTap: _isHandlingTrigger
                                ? null
                                : () => _handleTriggerPressed(
                                    context.read<CallFlowCubit>(),
                                    callFlowState,
                                    selectedSnapshot,
                                  ),
                            child: Semantics(
                              container: true,
                              button: true,
                              enabled: !_isHandlingTrigger,
                              label: localizations.homeStartCallSemanticLabel,
                              child: ExcludeSemantics(
                                child: AppLogo(
                                  size: theme.appSizes.homeTriggerSize * 3.2,
                                  animated: true,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: spacing.medium),
                        Text(
                          localizations.homeTriggerHint,
                          style: theme.textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        if (callFlowState.flowState ==
                            FakeCallState.awaitingNextStage) ...[
                          SizedBox(height: spacing.xLarge),
                          _AwaitingStageCard(state: callFlowState),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleTriggerPressed(
    CallFlowCubit cubit,
    CallFlowState state,
    SceneReadinessSnapshot? snapshot,
  ) async {
    if (_isHandlingTrigger) {
      return;
    }

    setState(() {
      _isHandlingTrigger = true;
    });

    final selectedScenario = state.selectedScenario;

    try {
      final isReady = await _ensureScenarioAccess(
        cubit: cubit,
        scenario: selectedScenario,
        initialReadiness: snapshot?.state,
      );
      if (!mounted || !isReady) {
        return;
      }

      await cubit.startFlow();
    } finally {
      if (mounted) {
        setState(() {
          _isHandlingTrigger = false;
        });
      }
    }
  }

  Future<void> _handleScenarioSelection(
    CallFlowCubit cubit,
    Scenario scenario,
  ) async {
    if (_isHandlingSelection) {
      return;
    }

    setState(() {
      _isHandlingSelection = true;
    });

    try {
      await cubit.selectScenario(scenario);
      if (!mounted || scenario == Scenario.presence) {
        return;
      }

      final isReady = await _ensureScenarioAccess(
        cubit: cubit,
        scenario: scenario,
      );
      if (!mounted || isReady) {
        return;
      }

      await cubit.selectScenario(Scenario.presence);
    } finally {
      if (mounted) {
        setState(() {
          _isHandlingSelection = false;
        });
      }
    }
  }

  void _selectScenario(BuildContext context, Scenario scenario) {
    unawaited(
      _handleScenarioSelection(context.read<CallFlowCubit>(), scenario),
    );
  }

  Future<bool> _ensureScenarioAccess({
    required CallFlowCubit cubit,
    required Scenario scenario,
    SceneReadinessState? initialReadiness,
  }) async {
    if (initialReadiness == null &&
        !cubit.state.sceneReadiness.containsKey(scenario)) {
      await cubit.refreshReadiness();
    }

    var readiness = initialReadiness ?? _readinessFor(cubit.state, scenario);
    if (!cubit.state.sceneReadiness.containsKey(scenario)) {
      return false;
    }

    while (mounted) {
      if (cubit.state.selectedScenario != scenario) {
        return false;
      }

      switch (readiness) {
        case SceneReadinessState.ready:
          return true;
        case SceneReadinessState.needsNotification:
          final notificationReady = await _requestNotifications();
          await cubit.refreshReadiness();
          if (!mounted || !notificationReady) {
            return false;
          }
          readiness = _readinessFor(cubit.state, scenario);
          continue;
        case SceneReadinessState.lockedPremium:
          final canContinue = await _openPaywall(scenario);
          await cubit.refreshReadiness();
          if (!mounted || !canContinue) {
            return false;
          }
          readiness = _readinessFor(cubit.state, scenario);
          continue;
      }
    }

    return false;
  }

  Future<bool> _requestNotifications() async {
    final localizations = AppLocalizations.of(context)!;
    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.notificationsPermissionDialogTitle),
        content: Text(localizations.notificationsPermissionDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(localizations.notificationsPermissionDialogNotNow),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(localizations.notificationsPermissionDialogContinue),
          ),
        ],
      ),
    );

    if (shouldContinue != true) {
      return false;
    }

    final readiness = await widget.notificationReadinessContract
        .requestPermission();
    if (!mounted) {
      return false;
    }

    if (readiness == NotificationReadinessState.ready) {
      return true;
    }

    final message = readiness == NotificationReadinessState.unavailable
        ? localizations.notificationsSectionUnavailable
        : localizations.notificationsPermissionStillOff;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(content: Text(message)));
    return false;
  }

  Future<bool> _openPaywall(Scenario scenario) async {
    final decision = await widget.paywallContract.evaluate(
      surface: PaywallSurface.sceneSelection,
    );
    if (decision == PaywallDecision.hidden) {
      return true;
    }

    return widget.onOpenPaywall(scenario);
  }

  SceneReadinessState _readinessFor(CallFlowState state, Scenario scenario) {
    return state.sceneReadiness[scenario]?.state ?? SceneReadinessState.ready;
  }
}

class _ScenarioSelectionCard extends StatelessWidget {
  const _ScenarioSelectionCard({
    required this.title,
    required this.snapshot,
    required this.selected,
    required this.onPressed,
  });

  final String title;
  final SceneReadinessSnapshot? snapshot;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ThemedSelectionCard(
      title: title,
      semanticLabel: title,
      selected: selected,
      onPressed: onPressed,
      trailing: _statusIconFor(snapshot),
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

class _AwaitingStageCard extends StatelessWidget {
  const _AwaitingStageCard({required this.state});

  final CallFlowState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.appSpacing;
    final localizations = AppLocalizations.of(context)!;

    return ThemedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.awaitingStageTitle,
            style: theme.textTheme.titleLarge,
          ),
          SizedBox(height: spacing.small),
          Text(
            localizations.awaitingStageBody(state.followUpStage.toString()),
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: spacing.small),
          Text(
            state.followUpReady
                ? localizations.awaitingStageReady
                : localizations.awaitingStageCountdown(
                    _formatRemaining(state.followUpRemaining),
                  ),
            style: theme.textTheme.bodyLarge,
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
