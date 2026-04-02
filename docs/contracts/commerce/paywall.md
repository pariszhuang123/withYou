# Paywall Contract

| Field | Value |
|---|---|
| Version | `v0.1` |
| Status | `active` |
| Last Updated | `2026-04-02` |
| Generated | `manually curated` |
| ADR | `none` |
| Module | `commerce` |
| Source | `lib/contracts/commerce/paywall_contract.dart` |

## Purpose

Define the purchase-gating decision surface for non-call entry points without
interrupting an active call flow.

## Contract Interface

```dart
enum PaywallSurface {
  sceneSelection,
  settings,
  widgetSetup,
  postQuickExit,
}

enum PaywallDecision {
  hidden,
  showFeatureGate,
  showSoftPrompt,
}

abstract class PaywallContract {
  Future<PaywallDecision> evaluate({
    required PaywallSurface surface,
  });

  Future<void> recordDismissed({
    required PaywallSurface surface,
  });
}
```

## Rules

- Never show the paywall during trigger execution.
- Never show the paywall during widget launch.
- Never show the paywall during an active call flow.
- Show the paywall only at intention moments where the user is explicitly
  trying to access a premium capability.
- Evaluate from the current entitlement state, not cached UI state.
- `recordDismissed()` is analytics-free product state, not user tracking.
- Paywall copy should explain the capability being unlocked in context.
- Tone should remain calm, supportive, and non-urgent.
- Do not hardcode a store price in app copy; purchase UI owns localized
  pricing.

## Trigger Guidance

Allowed surfaces:

- `sceneSelection`
- `widgetSetup`
- `settings`
- `postQuickExit`

Not currently allowed:

- main trigger button
- widget activation
- app launch
- active scenario flow
- language selection

Language selection is excluded because the current product contract treats audio
language as an accessibility and preparedness setting, not a premium
capability.

## Dependencies

- `PremiumAccessContract.getAccessState()`
