import '../../models/audio_language.dart';

abstract class AudioLanguagePackRepositoryContract {
  Future<List<AudioLanguagePackRecord>> getAllPacks();

  Future<AudioLanguagePackRecord?> getPack(String localeTag);

  Future<void> savePack(AudioLanguagePackRecord record);
}
