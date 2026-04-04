import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/audio_language_cubit.dart';
import '../contracts/call_flow_contracts.dart';
import '../contracts/commerce_contracts.dart';
import '../contracts/readiness_contracts.dart';
import '../l10n/app_localizations.dart';
import '../models/audio_language.dart';
import '../theme/design_tokens.dart';
import '../widgets/themed_components.dart';

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
      appBar: AppBar(title: Text(localizations.settings)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(spacing.large),
          child: Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: BlocBuilder<AudioLanguageCubit, AudioLanguageState>(
                builder: (context, state) {
                  return ThemedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!_loadingPremium) ...[
                          ThemedButton(
                            onPressed: _hasPremiumAccess
                                ? () => _showPremiumActiveMessage(context)
                                : () => _openUpgrade(context),
                            semanticLabel: _hasPremiumAccess
                                ? localizations.premiumActive
                                : localizations.upgradeToPremium,
                            child: Text(
                              _hasPremiumAccess
                                  ? localizations.premiumActive
                                  : localizations.upgradeToPremium,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: spacing.large),
                        ],
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
                          localizations.audioLanguageSectionTitle,
                          style: theme.textTheme.headlineMedium,
                        ),
                        SizedBox(height: spacing.large),
                        if (state.isLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          DropdownButtonFormField<String>(
                            initialValue: state.selectedLocaleTag,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText:
                                  localizations.audioLanguageSectionTitle,
                            ),
                            items: state.languages
                                .map(
                                  (language) => DropdownMenuItem<String>(
                                    value: language.language.localeTag,
                                    child: Text(
                                      _languageLabelWithStatus(
                                        context,
                                        language,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(growable: false),
                            selectedItemBuilder: (context) => state.languages
                                .map(
                                  (language) => Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _languageDisplayName(
                                        context,
                                        language.language,
                                      ),
                                    ),
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

  String _languageLabelWithStatus(
    BuildContext context,
    AudioLanguageAvailability language,
  ) {
    final localizations = AppLocalizations.of(context)!;
    final status = switch (language.status) {
      AudioLanguagePackStatus.downloaded => localizations.audioLanguageReady,
      AudioLanguagePackStatus.downloading =>
        localizations.audioLanguageDownloading,
      AudioLanguagePackStatus.failed => localizations.audioLanguageFailed,
      AudioLanguagePackStatus.notDownloaded =>
        localizations.audioLanguageNotDownloaded,
      AudioLanguagePackStatus.updateAvailable =>
        localizations.audioLanguageUpdateAvailable,
    };
    return '${_languageDisplayName(context, language.language)} · $status';
  }

  String _languageDisplayName(BuildContext context, AudioLanguage language) {
    final locale = Localizations.localeOf(context);
    if (language.localeTag == 'zh' &&
        locale.languageCode == 'zh' &&
        locale.countryCode?.toUpperCase() == 'TW') {
      return '\u7E41\u4F53\u5B57';
    }
    return language.displayName;
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
    final premiumActiveMessage = AppLocalizations.of(
      context,
    )!.premiumActiveMessage;
    final decision = await widget.paywallContract.evaluate(
      surface: PaywallSurface.settings,
    );
    if (decision == PaywallDecision.hidden) {
      messenger.showSnackBar(SnackBar(content: Text(premiumActiveMessage)));
      return;
    }

    await widget.onOpenPaywall(null);
    await _refreshPremiumState();
  }

  void _showPremiumActiveMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.premiumActiveMessage),
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
