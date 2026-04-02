# Audio Language Pack Manager Contract

| Field | Value |
|---|---|
| Version | `v0.1` |
| Status | `active` |
| Last Updated | `2026-04-02` |
| Generated | `manually curated` |
| ADR | `none` |
| Module | `audio` |
| Source | `lib/contracts/audio/audio_language_pack_manager_contract.dart` |

## Purpose

Own offline readiness for audio languages.

This contract:

- selects and persists the preferred audio locale
- reports language-pack availability for the UI
- downloads an entire language pack ahead of time
- resolves a local playable source for scenario/stage audio
- applies exact-locale, then base-language, then English fallback without downloading during an active flow

## Contract Interface

```dart
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
```

## Rules

- Download scope is the whole language pack, never a single stage.
- Download is only initiated from non-emergency UI.
- Playback resolution only uses bundled or previously downloaded local files.
- Fallback order is:
  1. exact selected locale
  2. base `zh` for Chinese regional locales
  3. `en`
- Download failures must leave the app usable via local fallback.
