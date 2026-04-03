# Widget Launch Event Contract

| Field | Value |
|---|---|
| Version | `v0.1` |
| Status | `active` |
| Last Updated | `2026-04-03` |
| Generated | `manually curated` |
| ADR | `none` |
| Module | `platform` |
| Source | `lib/contracts/platform/widget_launch_event_contract.dart` |

## Purpose

Expose native home-screen widget tap events back to Dart through a platform
contract so app services can react without importing concrete platform bridge
implementations.

## Contract Interface

```dart
class WidgetLaunchEvent {
  const WidgetLaunchEvent({required this.scenario});

  final Scenario? scenario;
}

abstract class WidgetLaunchEventContract {
  Stream<WidgetLaunchEvent> get eventStream;
}
```

## Rules

- native widget launch payloads may omit `scenario`
- when present, `scenario` must map to the app's canonical scenario enum names
- app services depend on this contract, not the concrete event-channel bridge
