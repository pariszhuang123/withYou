import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/audio_language_cubit.dart';
import '../blocs/call_flow_cubit.dart';
import '../contracts/call_flow_contracts.dart';
import '../contracts/commerce_contracts.dart';
import '../contracts/readiness_contracts.dart';
import '../l10n/app_localizations.dart';
import '../models/audio_language.dart';
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

    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.only(right: spacing.small),
            child: Center(
              child: ThemedIconButton(
                icon: Icons.settings_outlined,
                semanticLabel: 'Open settings',
                tooltip: 'Settings',
                onPressed: widget.onOpenSettings,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(spacing.large),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
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
                              'Choose support style',
                              style: theme.textTheme.headlineMedium,
                            ),
                            SizedBox(height: spacing.large),
                            SegmentedButton<Scenario>(
                              segments: <ButtonSegment<Scenario>>[
                                ButtonSegment<Scenario>(
                                  value: Scenario.presence,
                                  icon: _statusIconFor(
                                    callFlowState.sceneReadiness[Scenario
                                        .presence],
                                  ),
                                  label: const Text('Gentle'),
                                ),
                                ButtonSegment<Scenario>(
                                  value: Scenario.socialPull,
                                  icon: _statusIconFor(
                                    callFlowState.sceneReadiness[Scenario
                                        .socialPull],
                                  ),
                                  label: const Text('Steady'),
                                ),
                                ButtonSegment<Scenario>(
                                  value: Scenario.exitPressure,
                                  icon: _statusIconFor(
                                    callFlowState.sceneReadiness[Scenario
                                        .exitPressure],
                                  ),
                                  label: const Text('Urgent'),
                                ),
                              ],
                              selected: <Scenario>{
                                callFlowState.selectedScenario,
                              },
                              onSelectionChanged: (selection) {
                                unawaited(
                                  _handleScenarioSelection(
                                    context.read<CallFlowCubit>(),
                                    selection.first,
                                  ),
                                );
                              },
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
                            label: 'Start selected support call',
                            child: ExcludeSemantics(
                              child: AppLogo(
                                size: spacing.xLarge * 3,
                                animated: true,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (callFlowState.flowState ==
                          FakeCallState.awaitingNextStage) ...[
                        SizedBox(height: spacing.large),
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

  Future<bool> _ensureScenarioAccess({
    required CallFlowCubit cubit,
    required Scenario scenario,
    SceneReadinessState? initialReadiness,
  }) async {
    var readiness = initialReadiness ?? _readinessFor(cubit.state, scenario);
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
    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Turn on notifications'),
        content: const Text(
          'Steady and urgent need notifications before the follow-up calls can arrive.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Continue'),
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
        ? 'Notifications are unavailable on this device.'
        : 'Notifications are still off.';
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

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    required this.notificationReadinessContract,
    required this.premiumAccessContract,
    required this.paywallContract,
    required this.onOpenPaywall,
    super.key,
  });

  final NotificationReadinessContract notificationReadinessContract;
  final PremiumAccessContract premiumAccessContract;
  final PaywallContract paywallContract;
  final Future<bool> Function(Scenario? scenario) onOpenPaywall;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final AppLifecycleListener _appLifecycleListener;
  NotificationReadinessState? _notificationReadinessState;
  bool _loadingNotificationState = true;
  bool _updatingNotificationState = false;
  bool _loadingPremium = true;
  bool _hasPremiumAccess = false;

  @override
  void initState() {
    super.initState();
    _appLifecycleListener = AppLifecycleListener(
      onResume: _refreshNotificationState,
    );
    _refreshNotificationState();
    _refreshPremiumState();
  }

  @override
  void dispose() {
    _appLifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.appSpacing;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: spacing.small),
            child: Center(
              child: _loadingPremium
                  ? const SizedBox.shrink()
                  : SizedBox(
                      width: 160,
                      child: ThemedButton(
                        onPressed: _hasPremiumAccess
                            ? () => _showPremiumActiveMessage(context)
                            : () => _openUpgrade(context),
                        semanticLabel: _hasPremiumAccess
                            ? 'Premium active'
                            : 'Upgrade to premium',
                        child: Text(
                          _hasPremiumAccess
                              ? 'Premium active'
                              : 'Upgrade to premium',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(spacing.large),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: BlocBuilder<AudioLanguageCubit, AudioLanguageState>(
                builder: (context, state) {
                  final selectedLanguage = state.languages
                      .where(
                        (language) =>
                            language.language.localeTag ==
                            state.selectedLocaleTag,
                      )
                      .firstOrNull;

                  return ThemedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _NotificationsSettingsRow(
                          title: localizations.notificationsSectionTitle,
                          helper: localizations.notificationsSectionHelper,
                          statusText: _notificationStatusText(localizations),
                          actionLabel: _notificationActionLabel(localizations),
                          isBusy:
                              _loadingNotificationState ||
                              _updatingNotificationState,
                          actionEnabled:
                              !_loadingNotificationState &&
                              !_updatingNotificationState &&
                              _notificationReadinessState !=
                                  NotificationReadinessState.unavailable,
                          onActionPressed: _handleNotificationAction,
                        ),
                        SizedBox(height: spacing.large),
                        Text(
                          'Audio language',
                          style: theme.textTheme.headlineMedium,
                        ),
                        SizedBox(height: spacing.small),
                        Text(
                          'English and Simplified Chinese are built in. Any other language shows a download icon and is stored on the device after download.',
                          style: theme.textTheme.bodyLarge,
                        ),
                        SizedBox(height: spacing.large),
                        if (state.isLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          DropdownButtonFormField<String>(
                            initialValue: state.selectedLocaleTag,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Language',
                            ),
                            items: state.languages
                                .map(
                                  (language) => DropdownMenuItem<String>(
                                    value: language.language.localeTag,
                                    child: Text(
                                      _languageLabelWithStatus(language),
                                    ),
                                  ),
                                )
                                .toList(growable: false),
                            selectedItemBuilder: (context) => state.languages
                                .map(
                                  (language) => Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(language.language.displayName),
                                  ),
                                )
                                .toList(growable: false),
                            onChanged: (localeTag) {
                              if (localeTag == null) {
                                return;
                              }
                              _selectLanguage(
                                context,
                                localeTag,
                                state.languages,
                              );
                            },
                          ),
                        if (selectedLanguage != null) ...[
                          SizedBox(height: spacing.medium),
                          ThemedSurfacePanel(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _selectedLanguageSummary(selectedLanguage),
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                                if (_showsDownloadAction(selectedLanguage))
                                  ThemedIconButton(
                                    icon: Icons.download_outlined,
                                    semanticLabel:
                                        'Download ${selectedLanguage.language.displayName}',
                                    tooltip: 'Download language pack',
                                    onPressed: () => context
                                        .read<AudioLanguageCubit>()
                                        .downloadLanguage(
                                          selectedLanguage.language.localeTag,
                                        ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],
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

  Future<void> _selectLanguage(
    BuildContext context,
    String localeTag,
    List<AudioLanguageAvailability> languages,
  ) async {
    final cubit = context.read<AudioLanguageCubit>();
    await cubit.selectLanguage(localeTag);
    final selected = languages
        .where((language) => language.language.localeTag == localeTag)
        .firstOrNull;
    if (selected == null) {
      return;
    }

    if (_showsDownloadAction(selected)) {
      await cubit.downloadLanguage(localeTag);
    }
  }

  bool _showsDownloadAction(AudioLanguageAvailability language) {
    return !language.language.isBundled && !language.isReadyOffline;
  }

  String _languageLabelWithStatus(AudioLanguageAvailability language) {
    final status = switch (language.status) {
      AudioLanguagePackStatus.downloaded => 'Ready offline',
      AudioLanguagePackStatus.downloading => 'Downloading',
      AudioLanguagePackStatus.failed => 'Download failed',
      AudioLanguagePackStatus.notDownloaded => 'Download needed',
      AudioLanguagePackStatus.updateAvailable => 'Update available',
    };
    return '${language.language.displayName} · $status';
  }

  String _selectedLanguageSummary(AudioLanguageAvailability language) {
    if (language.language.localeTag == 'zh') {
      return 'Simplified Chinese is a bundled offline language and is treated as ready immediately.';
    }
    if (language.language.localeTag == 'en') {
      return 'English is bundled and ready immediately.';
    }
    if (language.isReadyOffline) {
      return '${language.language.displayName} is stored locally and ready for offline playback.';
    }
    return '${language.language.displayName} needs a one-time download before it can be used offline.';
  }

  Future<void> _refreshPremiumState() async {
    final accessState = await widget.premiumAccessContract.getAccessState();
    if (!mounted) {
      return;
    }

    setState(() {
      _hasPremiumAccess = accessState == PremiumAccessState.active;
      _loadingPremium = false;
    });
  }

  Future<void> _refreshNotificationState() async {
    final readiness = await widget.notificationReadinessContract.getReadiness();
    if (!mounted) {
      return;
    }

    setState(() {
      _notificationReadinessState = readiness;
      _loadingNotificationState = false;
    });
  }

  Future<void> _handleNotificationAction() async {
    final readiness = _notificationReadinessState;
    if (readiness == null ||
        readiness == NotificationReadinessState.unavailable ||
        _updatingNotificationState) {
      return;
    }

    setState(() {
      _updatingNotificationState = true;
    });

    try {
      if (readiness == NotificationReadinessState.ready) {
        await widget.notificationReadinessContract.openSystemSettings();
      } else {
        final requested = await widget.notificationReadinessContract
            .requestPermission();
        if (!mounted) {
          return;
        }
        if (requested != NotificationReadinessState.ready) {
          await widget.notificationReadinessContract.openSystemSettings();
        }
      }
      await _refreshNotificationState();
    } finally {
      if (mounted) {
        setState(() {
          _updatingNotificationState = false;
        });
      }
    }
  }

  String _notificationStatusText(AppLocalizations localizations) {
    if (_loadingNotificationState) {
      return localizations.notificationsSectionHelper;
    }

    return switch (_notificationReadinessState) {
      NotificationReadinessState.ready =>
        localizations.notificationsSectionEnabled,
      NotificationReadinessState.unavailable =>
        localizations.notificationsSectionUnavailable,
      NotificationReadinessState.needsPermission ||
      null => localizations.notificationsSectionNeedsPermission,
    };
  }

  String _notificationActionLabel(AppLocalizations localizations) {
    return switch (_notificationReadinessState) {
      NotificationReadinessState.ready =>
        localizations.notificationsSectionManage,
      NotificationReadinessState.unavailable =>
        localizations.notificationsSectionManage,
      NotificationReadinessState.needsPermission ||
      null => localizations.notificationsSectionTurnOn,
    };
  }

  Future<void> _openUpgrade(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final decision = await widget.paywallContract.evaluate(
      surface: PaywallSurface.settings,
    );
    if (decision == PaywallDecision.hidden) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Premium is active. You can use all features.'),
        ),
      );
      return;
    }

    await widget.onOpenPaywall(null);
    await _refreshPremiumState();
  }

  void _showPremiumActiveMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Premium is active. You can use all features.'),
      ),
    );
  }
}

class _NotificationsSettingsRow extends StatelessWidget {
  const _NotificationsSettingsRow({
    required this.title,
    required this.helper,
    required this.statusText,
    required this.actionLabel,
    required this.isBusy,
    required this.actionEnabled,
    required this.onActionPressed,
  });

  final String title;
  final String helper;
  final String statusText;
  final String actionLabel;
  final bool isBusy;
  final bool actionEnabled;
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.appSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: theme.textTheme.headlineMedium),
        SizedBox(height: spacing.small),
        Text(helper, style: theme.textTheme.bodyLarge),
        SizedBox(height: spacing.medium),
        ThemedSurfacePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(statusText, style: theme.textTheme.bodyMedium),
              SizedBox(height: spacing.medium),
              isBusy
                  ? const Center(child: CircularProgressIndicator())
                  : ThemedButton(
                      onPressed: actionEnabled ? onActionPressed : null,
                      semanticLabel: actionLabel,
                      child: Text(actionLabel, textAlign: TextAlign.center),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({
    required this.premiumAccessContract,
    required this.focusedScenario,
    super.key,
  });

  final PremiumAccessContract premiumAccessContract;
  final Scenario? focusedScenario;

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.appSpacing;
    final benefits = _orderedBenefits(widget.focusedScenario);

    return Scaffold(
      appBar: AppBar(title: const Text('Upgrade to premium')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(spacing.large),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ThemedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Unlock stronger support options',
                          style: theme.textTheme.headlineMedium,
                        ),
                        SizedBox(height: spacing.small),
                        Text(
                          'Premium adds the follow-up call scenarios and prepares the app for faster access from a home-screen widget.',
                          style: theme.textTheme.bodyLarge,
                        ),
                        SizedBox(height: spacing.medium),
                        ThemedSurfacePanel(
                          child: Text(
                            'The store should show the current localized price during checkout. This screen keeps the value explanation together with purchase and restore actions.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: spacing.large),
                  for (final benefit in benefits) ...[
                    ThemedCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            benefit.title,
                            style: theme.textTheme.titleLarge,
                          ),
                          SizedBox(height: spacing.xSmall),
                          Text(benefit.body, style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    SizedBox(height: spacing.medium),
                  ],
                  ThemedButton(
                    onPressed: _busy ? null : _purchase,
                    semanticLabel: 'Unlock premium',
                    child: const Text('See price in store'),
                  ),
                  SizedBox(height: spacing.small),
                  ThemedButton(
                    onPressed: _busy ? null : _restore,
                    semanticLabel: 'Restore premium purchase',
                    child: const Text('Restore purchase'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _purchase() async {
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
    });
    await widget.premiumAccessContract.recordPurchase();
    if (!mounted) {
      return;
    }
    navigator.pop(true);
  }

  Future<void> _restore() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _busy = true;
    });
    await widget.premiumAccessContract.restorePurchases();
    final accessState = await widget.premiumAccessContract.getAccessState();
    if (!mounted) {
      return;
    }

    if (accessState == PremiumAccessState.active) {
      navigator.pop(true);
      return;
    }

    setState(() {
      _busy = false;
    });
    messenger.showSnackBar(
      const SnackBar(content: Text('No premium purchase was restored.')),
    );
  }

  List<_PaywallBenefit> _orderedBenefits(Scenario? focusedScenario) {
    final benefits = <_PaywallBenefit>[
      _benefitForScenario(Scenario.socialPull),
      _benefitForScenario(Scenario.exitPressure),
      const _PaywallBenefit(
        key: 'widget',
        title: 'Quick access widget',
        body:
            'Prepare for faster launch from a home-screen widget so your selected support style is ready with fewer taps.',
      ),
    ];

    if (focusedScenario == null) {
      return benefits;
    }

    final focusKey = focusedScenario.name;
    benefits.sort((left, right) {
      if (left.key == focusKey) {
        return -1;
      }
      if (right.key == focusKey) {
        return 1;
      }
      return 0;
    });
    return benefits;
  }

  _PaywallBenefit _benefitForScenario(Scenario scenario) {
    return switch (scenario) {
      Scenario.presence => const _PaywallBenefit(
        key: 'presence',
        title: 'Scenario 1: Gentle',
        body: 'One immediate call for a light interruption.',
      ),
      Scenario.socialPull => const _PaywallBenefit(
        key: 'socialPull',
        title: 'Scenario 2: Steady',
        body:
            'One call now, then two follow-up calls later for a believable reason to keep stepping away.',
      ),
      Scenario.exitPressure => const _PaywallBenefit(
        key: 'exitPressure',
        title: 'Scenario 3: Urgent',
        body:
            'Faster follow-up calls that build pressure when you need a stronger reason to leave quickly.',
      ),
    };
  }
}

class _PaywallBenefit {
  const _PaywallBenefit({
    required this.key,
    required this.title,
    required this.body,
  });

  final String key;
  final String title;
  final String body;
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

    return ThemedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Follow-up scheduled', style: theme.textTheme.titleLarge),
          SizedBox(height: spacing.small),
          Text(
            'Stage ${state.followUpStage} is waiting on the local notification timer.',
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: spacing.small),
          Text(
            state.followUpReady
                ? 'The next follow-up can open now.'
                : 'Ready in ${_formatRemaining(state.followUpRemaining)}',
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
