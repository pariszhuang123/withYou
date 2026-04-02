# Widget Contract

| Field | Value |
|---|---|
| Version | `v0.1` |
| Status | `active` |
| Last Updated | `2026-04-02` |
| Generated | `manually curated` |
| ADR | `none` |
| Module | `readiness` |
| Source | `lib/contracts/readiness/widget_contract.dart` |

## Purpose

Define widget availability and launch-planning behavior for home-screen entry
points that may need premium or fallback handling.

## Contract Interface

```dart
enum WidgetAvailabilityState { available, requiresPremium, unavailable }

class WidgetAvailability {
  const WidgetAvailability({
    required this.state,
    this.supportsDirectPickerLaunch = false,
  });

  final WidgetAvailabilityState state;
  final bool supportsDirectPickerLaunch;
}

enum LaunchSurface { appButton, homeScreenWidget }

enum WidgetLaunchOutcome {
  launchSelectedScene,
  fallbackToPresence,
  openPremiumScreen,
}

class WidgetLaunchPlan {
  const WidgetLaunchPlan({
    required this.outcome,
    required this.requestedScenario,
    required this.resolvedScenario,
    this.showFallbackMessage = false,
  });

  final WidgetLaunchOutcome outcome;
  final Scenario requestedScenario;
  final Scenario resolvedScenario;
  final bool showFallbackMessage;
}

abstract class WidgetAvailabilityContract {
  Future<WidgetAvailability> getAvailability();
}

abstract class WidgetLaunchContract {
  Future<WidgetLaunchPlan> planLaunch({
    required LaunchSurface surface,
    required Scenario selectedScenario,
  });
}
```

## Rules

- Widgets must never bypass scenario safety/readiness checks.
- Launch planning can resolve to fallback behavior.
- Direct widget launch support is explicitly surfaced, not inferred.
