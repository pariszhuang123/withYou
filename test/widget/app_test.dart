import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/app.dart';
import 'package:with_you/config/app_config.dart';
import 'package:with_you/config/app_environment.dart';
import 'package:with_you/contracts/app_locale_resolver_contract.dart';
import 'package:with_you/contracts/audio_language_pack_manager_contract.dart';
import 'package:with_you/contracts/fake_call_timing_contract.dart';
import 'package:with_you/models/audio_language.dart';
import 'package:with_you/models/playable_audio_source.dart';

class _TestAppLocaleResolverContract implements AppLocaleResolverContract {
  @override
  Locale resolve({
    required List<Locale>? preferredLocales,
    required List<Locale> supportedLocales,
  }) {
    return const Locale('en');
  }
}

class _TestAudioLanguagePackManagerContract
    implements AudioLanguagePackManagerContract {
  bool downloaded = false;
  String? selectedLocale = 'zh';

  @override
  Future<void> downloadLanguagePack(String localeTag) async {
    downloaded = true;
  }

  @override
  Future<String> ensureSelectedLocale(List<Locale> preferredLocales) async {
    return selectedLocale!;
  }

  @override
  Future<String?> getSelectedLocaleTag() async => selectedLocale;

  @override
  Future<List<AudioLanguageAvailability>> listAvailableLanguages() async {
    return <AudioLanguageAvailability>[
      AudioLanguageAvailability(
        language: const AudioLanguage(
          localeTag: 'zh',
          displayName: '简体中文',
          isBundled: true,
        ),
        status: AudioLanguagePackStatus.downloaded,
        isSelected: selectedLocale == 'zh',
      ),
      AudioLanguageAvailability(
        language: const AudioLanguage(
          localeTag: 'zh-TW',
          displayName: '繁體中文',
          isBundled: false,
        ),
        status: downloaded
            ? AudioLanguagePackStatus.downloaded
            : AudioLanguagePackStatus.notDownloaded,
        isSelected: selectedLocale == 'zh-TW',
      ),
    ];
  }

  @override
  Future<ResolvedPlayableAudio> resolvePlayableAudio({
    required Scenario scenario,
    required int stage,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> selectLocale(String localeTag) async {
    selectedLocale = localeTag;
  }
}

void main() {
  testWidgets('dev app shows development metadata and audio language section', (
    tester,
  ) async {
    final manager = _TestAudioLanguagePackManagerContract();
    await tester.pumpWidget(
      WithYouApp(
        config: AppConfig(environment: AppEnvironment.dev),
        appLocaleResolverContract: _TestAppLocaleResolverContract(),
        audioLanguagePackManagerContract: manager,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('With You'), findsNWidgets(2));
    expect(find.text('Release channel: development'), findsOneWidget);
    expect(find.text('APP_ENV=dev'), findsOneWidget);
    expect(find.text('Audio language'), findsOneWidget);
    expect(find.text('繁體中文'), findsOneWidget);
    expect(find.byIcon(Icons.download_outlined), findsOneWidget);
  });

  testWidgets('download action updates audio language readiness', (
    tester,
  ) async {
    final manager = _TestAudioLanguagePackManagerContract();
    await tester.pumpWidget(
      WithYouApp(
        config: AppConfig(environment: AppEnvironment.prod),
        appLocaleResolverContract: _TestAppLocaleResolverContract(),
        audioLanguagePackManagerContract: manager,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.download_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Ready offline'), findsNWidgets(2));
    expect(manager.downloaded, isTrue);
  });
}
