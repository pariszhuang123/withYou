# Paywall Contract

## Purpose

Gates access after the first free flow using an emergency bypass model. Must NEVER interrupt an active call. Contract doc for `lib/contracts/paywall_contract.dart`.

## Contract Interface

```dart
abstract class PaywallContract {
  /// Evaluate whether user can start a new flow.
  Future<PaywallDecision> evaluateAccess();

  /// Records a successful purchase.
  Future<void> recordPurchase();

  /// Uses the emergency bypass. Returns false if not available.
  Future<bool> useEmergencyBypass();
}

enum PaywallDecision {
  /// Access granted — start call immediately.
  granted,

  /// Show paywall WITH emergency bypass button.
  showWithEmergency,

  /// Show paywall WITHOUT emergency bypass (used, not reset yet).
  showBlocking,
}
```

## Flow Logic

```
User taps trigger
  → evaluateAccess()
    → granted
      → start call flow immediately
      → (first flow, or purchased, or active flow in progress)
    → showWithEmergency
      → show paywall screen with "紧急使用" button
        → user taps "紧急使用" → useEmergencyBypass() → start call flow
        → user taps "Unlock" → purchase flow → recordPurchase()
        → user dismisses → nothing happens
    → showBlocking
      → show paywall screen (no emergency button)
        → user taps "Unlock" → purchase flow → recordPurchase()
        → user dismisses → nothing happens
```

## Business Rules

### Free Tier

- First complete 3-stage flow is free.
- "Complete" = Stage 3 resolves (accepted or declined). Any flow where all 3 stages fire counts.

### Emergency Bypass

- Available on the paywall screen as a **visible, prominent** "紧急使用" button.
- Tap → **immediately triggers call flow**, zero friction, zero confirmation.
- One emergency bypass available at a time.
- Resets every 30 days — so there is always one available eventually.
- After emergency use, paywall returns with gentle messaging.

### Purchase

- Unlocks: unlimited use, all scenarios
- Platform: iOS App Store / Google Play IAP
- Do not show a hardcoded purchase amount in-app; the App Store / Google Play purchase button displays the current localized price
- Note: purchase requires internet, but app works offline after purchase

### Critical Rules

1. **NEVER show paywall during an active call flow.** `evaluateAccess()` returns `granted` if any flow is active.
2. **Emergency button must be immediately visible** — not hidden, not small. User may be stressed.
3. **Emergency tap triggers call with zero friction** — no confirmation dialog, no delay.

## Paywall Screen Copy

| Element | Chinese (zh) | English (en) |
|---------|-------------|-------------|
| Headline | 随时陪伴你 | Keep this with you |
| Subtitle | 一次购买，永久使用 | One-time unlock. Works offline. |
| Purchase button | 解锁 WithYou（金额由商店按钮显示） | Unlock WithYou (price shown by store button) |
| Emergency button | 紧急使用 | I need this now |
| Post-emergency headline | 我们很高兴能帮到你 | We're glad we could help |
| Post-emergency subtitle | 解锁 WithYou，随时为你准备 | Unlock to have it ready anytime |

## Data Dependencies

- `AppStateContract.getCompletedFlowCount()`
- `AppStateContract.hasPurchased()`
- `AppStateContract.isEmergencyBypassAvailable()`
- `AppStateContract.useEmergencyBypass()`

## Implementation File

`lib/services/paywall_service.dart`

## Test File

`test/unit/services/paywall_service_test.dart`
