# App State Contract

| Field | Value |
|---|---|
| Version | `v0.1` |
| Status | `active` |
| Last Updated | `2026-04-02` |
| Generated | `manually curated` |
| ADR | `none` |
| Module | `app` |
| Source | `lib/contracts/app/app_state_contract.dart` |

## Purpose

Persist minimal non-sensitive app preferences needed by the offline emergency
experience.

Current implementation persists:

- selected audio locale tag
- selected scene
- premium access flag

Pending follow-up scheduling metadata is persisted separately through
`PendingFollowUpRepositoryContract`. It is not part of `AppStateContract`.

## Contract Interface

```dart
abstract class AppStateContract {
  Future<String?> getSelectedAudioLocaleTag();
  Future<void> setSelectedAudioLocaleTag(String localeTag);
  Future<Scenario?> getSelectedScenario();
  Future<void> setSelectedScenario(Scenario scenario);
  Future<bool> hasPremiumAccess();
  Future<void> setPremiumAccess(bool hasPremiumAccess);
}
```

## Rules

- No user-identifiable data.
- No call history.
- No active flow state.
- Selected scene persists so the home screen and widget launch the same preset.
- Premium access is stored as local entitlement state for offline gating.
- Selected audio locale is used by the language-pack manager to determine exact-locale playback preference.
