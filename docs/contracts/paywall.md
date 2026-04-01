# Paywall Contract

## Purpose
Gates access to the app after the first free call flow. Must NEVER interrupt an active call. Contract doc for `lib/contracts/paywall_contract.dart`.

## Contract Interface
```dart
abstract class PaywallContract {
  Future<bool> shouldShowPaywall();
  Future<void> recordPurchase();
  Future<bool> hasPurchased();
}
```

## Business Rules

### Free Tier
- The user's first complete call flow (all 3 stages completed) is free.
- "Complete" means Stage 3 audio finishes. Declined or cancelled flows do not count.

### Paywall Trigger
- After the first completed flow, `shouldShowPaywall()` returns `true`.
- The paywall screen is shown ONLY when:
  - No active call flow is in progress
  - User has not already purchased
  - At least one flow has been completed

### Purchase
- One-time purchase: $3.99
- Unlocks: unlimited use, all scenarios
- `recordPurchase()` stores the purchase state locally
- No server validation (offline-first)
- Platform: iOS App Store / Google Play in-app purchase

### Critical Rule
> **NEVER show the paywall during an active call flow.**
> Even if the completed count threshold is met mid-flow, the paywall waits until the flow ends.

### Copy
- Headline: "Keep this with you anytime"
- Subtext: "One-time unlock. Works offline."
- Price: "$3.99"
- Button: "Unlock WithYou"

## Data Dependencies
- `CallSessionRepository.getCompletedCallCount()` — to check if first flow is done
- `app_state.has_purchased_unlock` — purchase state

## Implementation File
`lib/services/paywall_service.dart`

## Test File
`test/unit/services/paywall_service_test.dart`
