# App Locale Resolver Contract

| Field | Value |
|---|---|
| Version | `v0.1` |
| Status | `active` |
| Last Updated | `2026-04-02` |
| Generated | `manually curated` |
| ADR | `none` |
| Module | `app` |
| Source | `lib/contracts/app/app_locale_resolver_contract.dart` |

## Purpose

Resolve the app UI locale from the device preference list and the supported
locales bundled with the app.

## Contract Interface

```dart
abstract class AppLocaleResolverContract {
  Locale resolve({
    required List<Locale>? preferredLocales,
    required List<Locale> supportedLocales,
  });
}
```

## Rules

- prefer exact locale matches first
- then prefer base language matches
- then fall back to English
- resolution is for UI copy only, not audio language selection

## Implementation

- `lib/services/app_locale_resolver_service.dart`

## Tests

- `test/unit/services/app_locale_resolver_service_test.dart`
