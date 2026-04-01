import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../contracts/audio_language_pack_manager_contract.dart';
import '../models/audio_language.dart';

class AudioLanguageState {
  const AudioLanguageState({
    required this.languages,
    required this.selectedLocaleTag,
    required this.isLoading,
  });

  factory AudioLanguageState.initial() {
    return const AudioLanguageState(
      languages: <AudioLanguageAvailability>[],
      selectedLocaleTag: null,
      isLoading: true,
    );
  }

  final List<AudioLanguageAvailability> languages;
  final String? selectedLocaleTag;
  final bool isLoading;

  AudioLanguageState copyWith({
    List<AudioLanguageAvailability>? languages,
    String? selectedLocaleTag,
    bool? isLoading,
  }) {
    return AudioLanguageState(
      languages: languages ?? this.languages,
      selectedLocaleTag: selectedLocaleTag ?? this.selectedLocaleTag,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AudioLanguageCubit extends Cubit<AudioLanguageState> {
  AudioLanguageCubit({required AudioLanguagePackManagerContract manager})
    : _manager = manager,
      super(AudioLanguageState.initial());

  final AudioLanguagePackManagerContract _manager;

  Future<void> load(List<Locale> preferredLocales) async {
    emit(state.copyWith(isLoading: true));
    final selectedLocaleTag = await _manager.ensureSelectedLocale(preferredLocales);
    final languages = await _manager.listAvailableLanguages();
    emit(
      AudioLanguageState(
        languages: languages,
        selectedLocaleTag: selectedLocaleTag,
        isLoading: false,
      ),
    );
  }

  Future<void> selectLanguage(String localeTag) async {
    await _manager.selectLocale(localeTag);
    await refresh();
  }

  Future<void> downloadLanguage(String localeTag) async {
    emit(
      state.copyWith(
        languages: state.languages.map((language) {
          if (language.language.localeTag != localeTag) {
            return language;
          }
          return AudioLanguageAvailability(
            language: language.language,
            status: AudioLanguagePackStatus.downloading,
            isSelected: language.isSelected,
          );
        }).toList(growable: false),
      ),
    );
    try {
      await _manager.downloadLanguagePack(localeTag);
    } finally {
      await refresh();
    }
  }

  Future<void> refresh() async {
    final selectedLocaleTag = await _manager.getSelectedLocaleTag();
    final languages = await _manager.listAvailableLanguages();
    emit(
      AudioLanguageState(
        languages: languages,
        selectedLocaleTag: selectedLocaleTag,
        isLoading: false,
      ),
    );
  }
}
