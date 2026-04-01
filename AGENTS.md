# AGENTS.md — AI Agent Instructions

> **Read this before writing ANY code in this repository.**

This is a safety-critical app. People rely on it in real social situations. A crash, missed notification, or broken flow is not a minor bug — it is a safety failure.

---

## 📁 Documentation Map

All specifications live in `docs/`. Read the relevant doc before implementing.

| Doc | Purpose | Read Before... |
|-----|---------|----------------|
| [Architecture](docs/architecture.md) | Layer diagram, DI rules, data flow | Any structural work |
| [Call Flow Contract](docs/contracts/call-flow.md) | 3-stage call orchestration | Touching call logic |
| [Audio Playback Contract](docs/contracts/audio-playback.md) | Speaker-first audio rules | Touching audio |
| [Notification Contract](docs/contracts/notification.md) | Follow-up call scheduling | Touching notifications |
| [App State Contract](docs/contracts/app-state.md) | Scenario preference + purchase state persistence | Touching app state |
| [Call Template Contract](docs/contracts/call-template.md) | Platform-specific call UI templates | Touching call UI |
| [Content Resolver Contract](docs/contracts/content-resolver.md) | Scenario-based asset resolution | Touching content/assets |
| [Paywall Contract](docs/contracts/paywall.md) | Purchase gating rules | Touching paywall |
| [Data Model](docs/data-model.md) | Database tables, Drift schema | Touching database |
| [Content Model](docs/content-model.md) | Scenario × caller mapping (Chinese audio only, no personas) | Touching assets/content |
| [Design System](docs/design-system.md) | Material 3 theme, call screen UI | Touching UI |
| [Testing Strategy](docs/testing.md) | Test plan, critical test cases, mocks | Writing any tests |
| [CI/CD](docs/ci-cd.md) | GitHub Actions pipeline | Modifying CI |

---

## ✅ MUST Rules

1. **Read the contract before implementing.** Every service/repository maps to a contract in `lib/contracts/`. Read the contract doc first. Implement every method.
2. **Write tests alongside code.** Every new file must have a corresponding test file. No exceptions.
3. **Run `flutter analyze` and `flutter test` before declaring done.** Zero warnings. Zero test failures.
4. **Use dependency injection via contracts.** All contract implementations are registered in `lib/di/service_locator.dart`. Screens and blocs receive contracts via constructor injection.
5. **Never hardcode asset paths.** Use `ContentResolverContract` to resolve audio/avatar paths.
6. **Never put business logic in widgets.** Widgets bind to blocs/cubits. Logic lives in services.
7. **Handle all call flow states explicitly.** Every combination of accept/decline/miss for every stage must be handled. All 3 stages fire regardless. No implicit fallthrough.
8. **Test the decline path as thoroughly as the happy path.** Decline at Stage 1, 2, 3. Missed notification. App killed mid-flow.
9. **No session history persistence.** Only app_state (scenario preference + purchase state). Active flow state is in-memory only.
10. **Validate notification permission on first launch.** Handle denial gracefully.

## 🚫 MUST NOT Rules

1. **Do not add dependencies not listed in `docs/architecture.md`.** If a new package is needed, document why and update the spec first.
2. **Do not modify contracts without updating all implementations AND tests.**
3. **Do not use `print()` for logging.** Use `dart:developer` `log()` or a logging contract.
4. **Do not store any user-identifiable information.** No analytics IDs, device IDs, or PII. No session logs, no call history.
5. **Do not use real telephony APIs.** This is a simulation.
6. **Do not auto-play audio without user interaction** (Accept tap).
7. **Do not show paywall during an active call flow.** Ever.
8. **Do not add decorative non-functional UI controls** (no fake mute/speaker/keypad buttons).

---

## 🔒 Code Quality Gates

Every PR / task completion must pass:

| Gate | Command | Requirement |
|------|---------|-------------|
| Static analysis | `flutter analyze` | Zero issues |
| Unit tests | `flutter test test/unit/` | 100% pass |
| Widget tests | `flutter test test/widget/` | 100% pass |
| Integration tests | `flutter test test/integration/` | 100% pass |
| Coverage | `flutter test --coverage` | ≥ 80% line coverage |

---

## 🏗️ Architecture Summary

```
UI Layer (Screens/Widgets)
    ↓ consumes
ViewModel / Bloc Layer
    ↓ consumes
Service Layer (implements contracts)
    ↓ consumes
Repository Layer (Drift) + Platform Layer (channels)
```

**Key rule:** Every dependency is injected via its **contract type** (abstract class). Never import a concrete implementation directly.

---

## 📂 File Conventions

- Contracts: `lib/contracts/{name}_contract.dart`
- Services: `lib/services/{name}_service.dart`
- Repositories: `lib/repositories/{name}_repository.dart`
- Blocs: `lib/blocs/{name}_bloc.dart`
- Screens: `lib/screens/{name}_screen.dart`
- Call templates: `lib/widgets/call_templates/{platform}_call_template.dart`
- App state: `lib/contracts/app_state_contract.dart` (replaces call_session_repository)
- Tests mirror source: `test/unit/services/{name}_service_test.dart`
- Mocks: `test/mocks/mock_{name}.dart`
