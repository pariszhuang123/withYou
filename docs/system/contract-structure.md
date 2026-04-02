# Contract Structure

## Purpose

Define one standard way to organize contracts, implementations, repository
state, and documentation across the repo.

This is the source of truth for structure. `AGENTS.md` points to the rules;
this document defines them in full.

## Modules

Contracts are grouped by responsibility into barrel modules under
`lib/contracts/`.

| Module | Barrel | Responsibility |
|---|---|---|
| App | `lib/contracts/app_contracts.dart` | App preferences and locale resolution |
| Audio | `lib/contracts/audio_contracts.dart` | Audio readiness, playback, and content lookup |
| Call Flow | `lib/contracts/call_flow_contracts.dart` | Flow orchestration, templates, notifications, pending follow-ups |
| Commerce | `lib/contracts/commerce_contracts.dart` | Entitlements and paywall rules |
| Platform | `lib/contracts/platform_contracts.dart` | Cross-cutting platform-facing services such as logging |
| Readiness | `lib/contracts/readiness_contracts.dart` | Preflight availability, widget launch planning, notification readiness |
| Aggregate | `lib/contracts/contracts.dart` | Optional full-contract export for documentation or tests |

## File Rules

### Contract files

- Root-level `lib/contracts/` only contains barrel files
- Every concrete contract file lives under `lib/contracts/{module}/`
- Contract filenames end with `_contract.dart`
- Repository contracts also end with `_contract.dart`
- Barrel files end with `_contracts.dart`, except the aggregate barrel
  `contracts.dart`
- All contract imports in app code should prefer module barrels over ad hoc
  file imports

### Implementation files

- Services: `lib/services/{name}_service.dart`
- Repositories: `lib/repositories/{name}_repository.dart`
- Platform bridges: `lib/platform/{name}_service.dart` or a clearly named
  platform bridge file

### Documentation files

- Each concrete contract file must have a matching contract doc in
  `docs/contracts/{module}/`
- Contract docs use kebab-case names
- Each contract doc begins with a metadata table containing:
  - `Version`
  - `Status`
  - `Last Updated`
  - `Generated`
  - `ADR`
  - `Module`
  - `Source`
- Each contract doc must contain a `## Purpose` section near the top
- Structural docs that cover multiple contracts live under `docs/system/`

## Contract Shape Rules

- The primary abstract type in a contract file must end with `Contract`
- DTOs, enums, and value objects may live beside the contract when they are
  part of the contract surface
- Business logic must not live in contract files
- UI must depend on contract types, not concrete implementations

## Flow Ownership

- Widgets and screens depend on cubits/blocs
- Cubits/blocs depend on coordinator or service contracts
- Coordinators/services depend on lower-level service, repository, and platform
  contracts
- Notification payloads identify flow state using:
  - `sessionId`
  - `scenario`
  - `stage`

## Sequence

The follow-up lifecycle is:

```text
UI start action
  -> CallFlowCoordinatorContract.startFlow(scenario)
  -> FakeCallTimingContract.startFlow(sessionId, scenario)
  -> stage resolves
  -> coordinator persists PendingFollowUp
  -> NotificationContract.scheduleFollowUp(payload)
  -> native notification fires
  -> tap/missed emitted back through NotificationContract.eventStream
  -> coordinator reconciles pending follow-up state
  -> timing service enters tapped stage or schedules the next follow-up
```

## Enforcement

The single repo command:

```bash
flutter pub run tool/quality_gate.dart
```

must validate:

1. contract/module structure
2. custom lint rules
3. analyzer
4. tests
5. coverage threshold
