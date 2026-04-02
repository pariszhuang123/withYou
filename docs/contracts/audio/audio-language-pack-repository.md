# Audio Language Pack Repository Contract

| Field | Value |
|---|---|
| Version | `v0.1` |
| Status | `active` |
| Last Updated | `2026-04-02` |
| Generated | `manually curated` |
| ADR | `none` |
| Module | `audio` |
| Source | `lib/contracts/audio/audio_language_pack_repository_contract.dart` |

## Purpose

Persist cached language-pack metadata without exposing a raw database API.

## Contract Interface

```dart
abstract class AudioLanguagePackRepositoryContract {
  Future<List<AudioLanguagePackRecord>> getAllPacks();
  Future<AudioLanguagePackRecord?> getPack(String localeTag);
  Future<void> savePack(AudioLanguagePackRecord record);
}
```

## Stored Metadata

- locale tag
- pack status
- version
- checksum marker
- local root path
- downloaded-at UTC timestamp

## Rules

- This is a domain repository contract, not a low-level SQLite contract.
- Implementations may use JSON, Drift, or another local persistence layer later without changing callers.
