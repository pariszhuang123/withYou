# Architecture Specification

> **Source of truth for project structure, dependency rules, and data flow.**
> Read this before any structural work.
>
> **v1 scope:** Audio content is Chinese only. UI strings are localized via Flutter l10n (system locale — zh/en). Fixed caller identity per scenario (no persona selection), maximum 4 scenarios. Multi-language audio and persona selection are de-scoped from v1.

---

## Layer Diagram

```
┌─────────────────────────────────────────────┐
│              UI Layer                       │
│   Screens / Widgets                         │
│   (display state, forward user gestures)    │
└──────────────────┬──────────────────────────┘
                   │ consumes
                   ▼
┌─────────────────────────────────────────────┐
│          ViewModel / Bloc Layer             │
│   Blocs / Cubits                            │
│   (map events → state, orchestrate calls)   │
└──────────────────┬──────────────────────────┘
                   │ consumes
                   ▼
┌─────────────────────────────────────────────┐
│            Service Layer                    │
│   implements contracts                      │
│   (business logic, validation, rules)       │
└──────────────┬──────────────┬───────────────┘
               │              │
               ▼              ▼
┌──────────────────┐ ┌────────────────────────┐
│ Repository Layer │ │   Platform Layer       │
│ (Drift / SQLite) │ │ (audio, notifications) │
│ (persistence)    │ │ (platform channels)    │
└──────────────────┘ └────────────────────────┘
```

**Key rule:** Every arrow represents a dependency injected via its **contract type** (abstract class). No layer may import a concrete implementation from a lower layer directly.

---

## Dependency Injection Rules

| Rule | Detail |
|------|--------|
| DI container | `get_it` singleton registered in `lib/di/service_locator.dart` |
| Registration | All contracts registered at app startup before `runApp()` |
| Injection style | Constructor injection — blocs and screens receive contract types |
| No service locator in widgets | Widgets never call `GetIt.I` directly; they receive blocs via `BlocProvider` |
| No concrete imports | Code outside `lib/di/` must never `import` a file from `services/`, `repositories/`, or `platform/` |

### Contract Registration Example

```dart
// lib/di/service_locator.dart

import 'package:get_it/get_it.dart';

// Contracts (abstract)
import 'package:with_you/contracts/call_session_repository_contract.dart';
import 'package:with_you/contracts/call_flow_contract.dart';
import 'package:with_you/contracts/audio_playback_contract.dart';
import 'package:with_you/contracts/notification_contract.dart';
import 'package:with_you/contracts/content_resolver_contract.dart';
import 'package:with_you/contracts/paywall_contract.dart';

// Concrete implementations (only imported here)
import 'package:with_you/repositories/call_session_repository.dart';
import 'package:with_you/services/call_flow_service.dart';
import 'package:with_you/platform/audio_playback_service.dart';
import 'package:with_you/platform/notification_service.dart';
import 'package:with_you/services/content_resolver_service.dart';
import 'package:with_you/services/paywall_service.dart';
import 'package:with_you/database/app_database.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  // Database
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Repositories
  sl.registerLazySingleton<CallSessionRepositoryContract>(
    () => CallSessionRepository(database: sl<AppDatabase>()),
  );

  // Platform
  sl.registerLazySingleton<AudioPlaybackContract>(
    () => AudioPlaybackService(),
  );
  sl.registerLazySingleton<NotificationContract>(
    () => NotificationService(),
  );

  // Services
  sl.registerLazySingleton<ContentResolverContract>(
    () => ContentResolverService(),
  );
  sl.registerLazySingleton<CallFlowContract>(
    () => CallFlowService(
      repository: sl<CallSessionRepositoryContract>(),
      audio: sl<AudioPlaybackContract>(),
      notification: sl<NotificationContract>(),
      contentResolver: sl<ContentResolverContract>(),
    ),
  );
  sl.registerLazySingleton<PaywallContract>(
    () => PaywallService(),
  );
}
```

---

## Data Flow

```
User tap (UI)
  │
  ▼
Bloc receives Event
  │
  ▼
Bloc calls Service method (via contract)
  │
  ▼
Service executes business logic
  │
  ├──► Repository.save()  (persist to Drift/SQLite)
  └──► Platform.play()    (trigger audio / schedule notification)
        │
        ▼
Service returns result
  │
  ▼
Bloc emits new State
  │
  ▼
UI rebuilds from State
```

**Concrete example — accepting an incoming call:**

1. User taps **Accept** → `CallBloc` receives `CallAccepted` event.
2. `CallBloc` calls `callFlowService.acceptCall(sessionId)`.
3. `CallFlowService` updates the session via `CallSessionRepositoryContract.updateStage(...)`.
4. `CallFlowService` starts audio via `AudioPlaybackContract.play(...)`.
5. `CallFlowService` returns the updated `CallSession`.
6. `CallBloc` emits `CallInProgress(session)` state.
7. `CallScreen` rebuilds to show the active call UI.

---

## Approved Dependencies

### Production Dependencies

| Package | Purpose | Notes |
|---------|---------|-------|
| Flutter SDK | Framework | — |
| `flutter_bloc` | State management | Blocs + Cubits |
| `get_it` | Dependency injection | Singleton container |
| `drift` | Local database (ORM) | Type-safe SQLite |
| `sqlite3_flutter_libs` | SQLite native bindings | Required by Drift |
| `flutter_local_notifications` | Scheduling follow-up calls | Local-only, no server |
| `audioplayers` | Audio playback | **Evaluate `just_audio` as alternative** — `just_audio` offers better streaming control and iOS background audio, but `audioplayers` has a simpler API for local asset playback. Decision: start with `audioplayers`; switch to `just_audio` if background playback or gapless looping is needed. |
| `flutter_localizations` | Flutter SDK l10n support | Built-in, enables Material/Cupertino localized widgets |
| `intl` | Internationalization utilities | Message formatting, plurals, date/number formatting |

### Dev Dependencies

| Package | Purpose |
|---------|---------|
| `mocktail` | Mock generation for contract-based testing |
| `bloc_test` | Testing Bloc event → state sequences |
| `build_runner` | Code generation runner |
| `drift_dev` | Drift code generation |

### Rules for Adding New Dependencies

1. **Document the rationale.** Why can't this be done with existing packages or plain Dart?
2. **Update this table.** Add the package, purpose, and any notes.
3. **Get approval.** New dependencies must be reviewed before merging.
4. **Check license compatibility.** Only MIT, BSD, and Apache 2.0 licenses are accepted.
5. **Prefer pure Dart.** Avoid native plugins unless platform access is strictly required.
6. **No analytics or tracking packages.** This app stores zero user-identifiable information.

---

## Project Structure

```
lib/
├── contracts/          # Abstract interfaces — source of truth for every
│                       # service, repository, and platform capability.
│                       # All other layers depend on these, never the reverse.
│                       # Includes CallTemplateContract for region+platform
│                       # call screen template selection.
│
├── models/             # Data classes and enums: Scenario, CallStage,
│                       # SessionStatus, etc.
│                       # Pure Dart — no Flutter or package imports.
│                       # v1: no Persona or Language enums — caller
│                       # identity is fixed per scenario, Chinese only.
│
├── services/           # Business logic implementations of contracts.
│                       # Stateless where possible. Receives repositories
│                       # and platform contracts via constructor injection.
│
├── repositories/       # Data persistence implementations using Drift.
│                       # Implements repository contracts. Only layer that
│                       # imports Drift classes directly.
│
├── platform/           # Platform-specific implementations: audio playback,
│                       # local notifications. Implements platform contracts.
│                       # Only layer that imports plugin packages directly.
│
├── database/           # Drift database definition (tables, DAOs) and
│                       # generated code (*.g.dart). Owned by repository layer.
│
├── screens/            # UI screens: HomeScreen, CallScreen, SettingsScreen.
│                       # Each screen receives its Bloc via BlocProvider.
│                       # No business logic — only state binding and gestures.
│                       # v1 SettingsScreen: scenario selection only (max 4).
│                       # No language selector or persona selector.
│
├── widgets/            # Reusable UI components: avatar display, call timer,
│                       # waveform visualizer, etc. Stateless where possible.
│   └── call_templates/ # Region+platform call screen templates:
│                       # wechat, line, whatsapp, ios_native, android_native.
│                       # All implement same CallTemplateWidget interface.
│
├── blocs/              # Bloc / Cubit classes + Events + States.
│                       # Orchestrate user interaction → service calls → state.
│                       # Receive service contracts via constructor injection.
│
├── theme/              # Material 3 theme: ColorScheme, TextTheme, custom
│                       # tokens. Single source of truth for visual style.
│
├── constants/          # Timing values (ring duration, stage delays),
│                       # default settings, asset keys. No logic.
│
├── di/                 # service_locator.dart — the ONLY file that imports
│                       # concrete implementations. Wires contracts to impls.
│
├── l10n/               # ARB localization files for UI strings.
│   ├── app_en.arb      # English UI strings (fallback)
│   └── app_zh.arb      # Chinese UI strings
│                       # Audio content is Chinese-only (v1).
│                       # UI strings follow device system locale.
│
└── main.dart           # Entry point. Calls setupServiceLocator(), runApp().

test/
├── unit/               # Isolated tests — every dependency is a mock.
│   ├── services/       # Service logic tests against mocked contracts.
│   ├── repositories/   # Repository tests with in-memory Drift DB.
│   └── blocs/          # Bloc tests using bloc_test (event → state).
│
├── integration/        # Tests with real dependencies (actual DB, plugins).
│
├── widget/             # Widget render + interaction tests using
│                       # WidgetTester. Blocs are mocked.
│
├── mocks/              # Shared mock implementations of all contracts
│                       # (using mocktail). One file per contract.
│
└── fixtures/           # Test data: sample audio files, JSON payloads,
                        # pre-built model instances.

integration_test/       # Full end-to-end on-device tests.
```

---

## Summary of Architectural Constraints

| Constraint | Enforced By |
|------------|-------------|
| No concrete imports outside `lib/di/` | Code review + `flutter analyze` custom lint |
| All contracts must have tests | CI gate: coverage ≥ 80% |
| No business logic in widgets | Code review |
| No `print()` — use `dart:developer` `log()` | `flutter analyze` |
| No user-identifiable data stored | Code review |
| No real telephony APIs | Contract boundary — platform layer is a simulation |
| No auto-play audio without user interaction | Call flow contract enforces Accept-first |
| No paywall during active call flow | Call flow contract + Bloc guard |
