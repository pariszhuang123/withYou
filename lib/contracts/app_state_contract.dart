abstract class AppStateContract {
  Future<String?> getSelectedAudioLocaleTag();

  Future<void> setSelectedAudioLocaleTag(String localeTag);
}
