import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/audio_language_cubit.dart';
import 'config/app_config.dart';
import 'contracts/app_locale_resolver_contract.dart';
import 'contracts/audio_language_pack_manager_contract.dart';
import 'l10n/app_localizations.dart';
import 'models/audio_language.dart';
import 'theme/app_theme.dart';
import 'theme/design_tokens.dart';
import 'widgets/themed_components.dart';

class WithYouApp extends StatelessWidget {
  const WithYouApp({
    required this.config,
    required this.appLocaleResolverContract,
    required this.audioLanguagePackManagerContract,
    super.key,
  });

  final AppConfig config;
  final AppLocaleResolverContract appLocaleResolverContract;
  final AudioLanguagePackManagerContract audioLanguagePackManagerContract;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AudioLanguageCubit(manager: audioLanguagePackManagerContract)
            ..load(WidgetsBinding.instance.platformDispatcher.locales),
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
        home: _EnvironmentHome(config: config),
      ),
    );
  }
}

class _EnvironmentHome extends StatelessWidget {
  const _EnvironmentHome({required this.config});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = theme.appSpacing;
    final colors = theme.appColors;

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
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: colors.surfaceCritical,
                              borderRadius: BorderRadius.circular(
                                theme.appSizes.cornerRadius,
                              ),
                              border: Border.all(color: colors.borderSubtle),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(spacing.medium),
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
                          ),
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
                          ThemedButton(
                            onPressed: () {},
                            semanticLabel: 'Start support call',
                            size: ThemedButtonSize.homeTrigger,
                            child: Text(localizations.accept),
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
    switch (language.status) {
      case AudioLanguagePackStatus.downloaded:
        return const Icon(Icons.check_circle_outline);
      case AudioLanguagePackStatus.downloading:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case AudioLanguagePackStatus.failed:
      case AudioLanguagePackStatus.notDownloaded:
      case AudioLanguagePackStatus.updateAvailable:
        if (language.language.isBundled) {
          return const Icon(Icons.check_circle_outline);
        }
        return IconButton(
          tooltip: localizations.audioLanguageDownload,
          onPressed: () => cubit.downloadLanguage(language.language.localeTag),
          icon: const Icon(Icons.download_outlined),
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
