# Premium Access Contract

| Field | Value |
|---|---|
| Version | `v0.1` |
| Status | `active` |
| Last Updated | `2026-04-02` |
| Generated | `manually curated` |
| ADR | `none` |
| Module | `commerce` |
| Source | `lib/contracts/commerce/premium_access_contract.dart` |

## Purpose

Define the entitlement boundary for premium-gated scenes and widget-related
capabilities.

## Contract Interface

```dart
enum PremiumAccessState { inactive, active }

abstract class PremiumAccessContract {
  Future<PremiumAccessState> getAccessState();

  Future<void> refresh();

  Future<void> recordPurchase();

  Future<void> restorePurchases();
}
```

## Rules

- Premium state is binary at the contract layer.
- Entitlement checks must not depend on user-identifiable data.
- Purchase restore behavior must be idempotent.
