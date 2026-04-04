# Widget Visual State Contract

| Field | Value |
|---|---|
| Version | `v0.1` |
| Status | `active` |
| Last Updated | `2026-04-04` |
| Generated | `manually curated` |
| ADR | `none` |
| Module | `platform` |
| Source | `lib/contracts/platform/widget_visual_state_contract.dart` |

## Purpose

Define the platform-facing sync boundary that keeps native home-screen widget
visuals aligned with the app's premium entitlement state.

## Contract Interface

```dart
abstract class WidgetVisualStateContract {
  Future<void> syncPremiumAccess({required bool isActive});
}
```

## Rules

- The widget visual state must be derived from the current premium entitlement
  state, not stale UI state.
- Sync must write state into platform-native widget storage so installed widgets
  can render without launching Flutter first.
- Sync should request a native widget refresh after state changes.
- Sync must not start a support flow or route the app directly.
