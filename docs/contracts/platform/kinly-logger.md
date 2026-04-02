# Kinly Logger Contract

| Field | Value |
|---|---|
| Version | `v0.1` |
| Status | `active` |
| Last Updated | `2026-04-02` |
| Generated | `manually curated` |
| ADR | `none` |
| Module | `platform` |
| Source | `lib/contracts/platform/kinly_logger_contract.dart` |

## Purpose

Provide consistent, sanitized logging across locale resolution, language-pack download, fallback, and playback.

## Contract Interface

```dart
abstract class KinlyLoggerContract {
  void debug(String message, {String category = 'app', Object? error});
  void info(String message, {String category = 'app'});
  void warn(String message, {String category = 'app', Object? error});
  void error(
    String message, {
      String category = 'app',
      Object? error,
      StackTrace? stackTrace,
    },
  );
}
```

## Rules

- No `print()`.
- No PII or session history.
- Log fallback decisions, download start/success/failure, checksum failures, and missing local audio.
