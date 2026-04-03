import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:with_you/blocs/audio_language_cubit.dart';
import 'package:with_you/contracts/audio_contracts.dart';
import 'package:with_you/contracts/call_flow_contracts.dart';
import 'package:with_you/models/audio_language.dart';
import 'package:with_you/models/playable_audio_source.dart';

class _TestAudioLanguagePackManagerContract
    implements AudioLanguagePackManagerContract {
  String? selectedLocaleTag;
  bool downloaded = false;

  @override
  Future<void> downloadLanguagePack(String localeTag) async {
    downloaded = true;
  }

  @override
  Future<String> ensureSelectedLocale(List<Locale> preferredLocales) async {
    selectedLocaleTag ??= 'zh';
    return selectedLocaleTag!;
  }

  @override
  Future<String?> getSelectedLocaleTag() async => selectedLocaleTag;

  @override
  Future<List<AudioLanguageAvailability>> listAvailableLanguages() async {
    return <AudioLanguageAvailability>[
      AudioLanguageAvailability(
        language: const AudioLanguage(
          localeTag: 'en',
          displayName: 'English',
          isBundled: true,
        ),
        status: AudioLanguagePackStatus.downloaded,
        isSelected: selectedLocaleTag == 'en',
      ),
      AudioLanguageAvailability(
        language: const AudioLanguage(
          localeTag: 'zh',
          displayName: 'Simplified Chinese',
          isBundled: true,
        ),
        status: AudioLanguagePackStatus.downloaded,
        isSelected: selectedLocaleTag == 'zh',
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
    selectedLocaleTag = localeTag;
  }
}

void main() {
  late _TestAudioLanguagePackManagerContract manager;
  late AudioLanguageCubit cubit;

  setUp(() {
    manager = _TestAudioLanguagePackManagerContract();
    cubit = AudioLanguageCubit(manager: manager);
  });

  test('load initializes the selected locale and languages', () async {
    await cubit.load(const <Locale>[Locale('zh', 'TW')]);

    expect(cubit.state.selectedLocaleTag, 'zh');
    expect(cubit.state.languages.length, 2);
  });

  test('selectLanguage updates selected locale', () async {
    await cubit.load(const <Locale>[Locale('zh')]);
    await cubit.selectLanguage('en');

    expect(cubit.state.selectedLocaleTag, 'en');
  });

  test('downloadLanguage refreshes statuses after download', () async {
    await cubit.load(const <Locale>[Locale('en')]);
    await cubit.downloadLanguage('zh');

    final zh = cubit.state.languages.firstWhere(
      (entry) => entry.language.localeTag == 'zh',
    );
    expect(zh.status, AudioLanguagePackStatus.downloaded);
  });
}
