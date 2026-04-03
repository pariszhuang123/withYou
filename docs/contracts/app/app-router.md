# App Router Contract

| Field | Value |
|---|---|
| Version | `v0.1` |
| Status | `active` |
| Last Updated | `2026-04-03` |
| Generated | `manually curated` |
| ADR | `none` |
| Module | `app` |
| Source | `lib/contracts/app/app_router_contract.dart` |

## Purpose

Define the app-level navigation boundary for in-app routing and external launch
surfaces such as notifications, home-screen widgets, and Apple Watch handoff.

## Contract Interface

```dart
enum AppRouteDestination { home, settings, paywall, call }

enum AppLaunchSource { inApp, notification, homeScreenWidget, appleWatch }

class AppLaunchIntent {
  const AppLaunchIntent({
    required this.source,
    required this.destination,
    this.scenario,
    this.stage,
    this.sessionId,
  });

  final AppLaunchSource source;
  final AppRouteDestination destination;
  final Scenario? scenario;
  final int? stage;
  final String? sessionId;
}

class AppRouteState {
  const AppRouteState({
    required this.destination,
    this.scenario,
    this.stage,
    this.sessionId,
  });
}

abstract class AppRouterContract {
  RouterConfig<Object> get routerConfig;

  AppRouteState get currentRoute;

  Future<void> goHome();

  Future<void> openSettings();

  Future<bool> openPaywall({Scenario? scenario, AppLaunchIntent? intent});

  Future<void> syncCallRoute({
    required bool visible,
    Scenario? scenario,
    int? stage,
    String? sessionId,
    AppLaunchIntent? intent,
  });

  Future<void> handleExternalIntent(AppLaunchIntent intent);
}
```

## Rules

- Widgets do not choose paths directly; they call the app router contract.
- External launch surfaces must express navigation through `AppLaunchIntent`.
- Scenario-bearing external intents should persist the selected scenario before
  the route is opened.
- Call-screen routing remains derived from active call-flow state; external
  intent support must not bypass call-flow readiness rules.
- The router may use a URL-based implementation such as `go_router`, but the
  app depends on this contract rather than the package directly.
