import 'package:flutter/widgets.dart';

import '../../models/audio_language.dart';
import '../../models/playable_audio_source.dart';
import '../call_flow/fake_call_timing_contract.dart';

abstract class AudioLanguagePackManagerContract {
  Future<String> ensureSelectedLocale(List<Locale> preferredLocales);

  Future<String?> getSelectedLocaleTag();

  Future<void> selectLocale(String localeTag);

  Future<List<AudioLanguageAvailability>> listAvailableLanguages();

  Future<void> downloadLanguagePack(String localeTag);

  Future<ResolvedPlayableAudio> resolvePlayableAudio({
    required Scenario scenario,
    required int stage,
  });
}
