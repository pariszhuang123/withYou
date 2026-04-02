# Architecture Specification

## Summary

The app is offline-first for emergency use:

- UI strings follow device locale with exact-locale preference, then base
  language, then English
- audio language is user-selectable in the UI
- bundled audio remains local for `zh` and `en`
- additional locales are delivered as full downloadable language packs over
  public HTTPS
- active call flow only uses bundled or already-downloaded local audio

The design system is enforced through typed theme tokens plus repo-specific lint
rules.

For primitive hierarchy and accessibility behavior, `docs/ui/design-system.md`
is the normative source. This document summarizes enforcement and integration
only.

## Layers

```text
UI Layer
  -> Cubit / state layer
  -> Service layer
  -> Repository layer + local filesystem
```

## Contract Structure

Contract organization is standardized in
[Contract Structure](contract-structure.md). Use that document as the source of
truth for:

- module barrels
- contract naming
- implementation placement
- contract-to-doc mapping
- flow payload identity

## Key Contracts

- `AppLocaleResolverContract`
- `AppStateContract`
- `PaywallContract`
- `PremiumAccessContract`
- `SceneReadinessContract`
- `CallFlowCoordinatorContract`
- `ContentResolverContract`
- `AudioLanguagePackManagerContract`
- `AudioLanguagePackRepositoryContract`
- `AudioPlaybackContract`
- `CallTemplateContract`
- `NotificationContract`
- `NotificationReadinessContract`
- `WidgetAvailabilityContract`
- `WidgetLaunchContract`
- `PendingFollowUpRepositoryContract`
- `KinlyLoggerContract`

## Dependency Rules

- widgets do not contain language-pack or call-flow business logic
- services depend on contracts
- repositories hide persistence details
- only `lib/di/` wires concrete implementations
- no raw SQLite API contract is introduced

## Persistence Strategy

Current implementation uses local JSON-backed repositories for selected audio
locale, selected scene, downloaded language-pack metadata, and pending
follow-up metadata. This keeps the contract boundary at the repository level
while leaving room for a later Drift migration.

Why JSON-backed first:

- the current data set is small and document-shaped
- offline emergency execution needs simple local reads more than relational
  queries
- repository interfaces stay stable while product rules are still moving
- it avoids introducing a low-level persistence dependency before the schema
  settles

Tradeoffs:

- no typed schema enforcement at the storage layer
- weaker migration tooling than Drift
- harder to express richer queries if state becomes relational
- more care is required to maintain backward compatibility in serialized files

Future direction:

- Drift becomes the better choice once purchase state, scene-readiness caches,
  widget metadata, or other structured local records need transactional updates
  or multi-entity querying
- until then, JSON remains acceptable because the app stores a small set of
  low-volume local preferences and offline metadata

## Locale Rules

### UI locale

1. exact locale match, e.g. `zh-TW`
2. base language, e.g. `zh`
3. `en`

### Audio locale

1. selected exact locale
2. base `zh` for Chinese regional locales
3. `en`

Audio fallback only considers local sources.

## Language-Pack Rules

- download scope is the full locale pack
- download happens only from non-emergency UI
- a pack is ready only when all required scenario/stage files exist locally
- playback uses local file paths after download
- no emergency-time download is allowed

## Design System Enforcement

### Why `custom_lint` instead of a full analyzer plugin

This repo uses `custom_lint`, not a bespoke analyzer plugin.

Reasoning:

- it integrates with normal Dart and Flutter workflows without maintaining a
  separate analyzer-plugin runtime
- it is simpler to version and run locally and in CI
- it is sufficient for AST-based repo rules such as banning raw colors and raw
  spacing in presentation code
- it keeps maintenance cost low while still enforcing design-system contracts

A full analyzer plugin would only be justified if the repo later needs deeper
cross-file analysis, package-graph reasoning, or editor features that
`custom_lint` cannot provide.

### Current custom lint rules

The repo now ships an in-repo lint package at `tool/with_you_custom_lints`.

Current rules:

- `avoid_raw_color_in_presentation`
  - bans raw `Color(...)` and `Colors.*` usage in `lib/widgets/` and
    `lib/screens/`
  - excludes `lib/theme/` and generated/localization code
- `avoid_raw_spacing_in_presentation`
  - bans numeric `EdgeInsets.*(...)` and numeric `SizedBox(height|width: ...)`
    in `lib/widgets/` and `lib/screens/`
  - pushes spacing decisions through theme tokens instead
- `avoid_raw_border_radius_in_presentation`
  - bans numeric `BorderRadius.*(...)` and `Radius.circular(...)` in
    presentation code
  - keeps curvature decisions anchored to component-size tokens
- `avoid_raw_decoration_in_presentation`
  - bans raw `BoxDecoration`, `ShapeDecoration`, and `BorderSide` usage in
    presentation code
  - pushes surface, avatar, and chip styling into the primitive layer
- `require_semantic_label_on_app_interactive_widgets`
  - requires `semanticLabel` on app-defined interactive building blocks such as
    `ThemedButton` and `ThemedIconButton`
  - keeps semantics attached to the approved lego-block controls rather than
    relying on ad hoc widget composition
- `avoid_raw_tappable_controls_without_token_constraints`
  - bans raw tappable controls such as `IconButton`, `ElevatedButton`,
    `GestureDetector`, and related primitives in presentation code
  - forces presentation code to build interactions from design-system
    components that already enforce token sizing, focus order, and semantics

These rules are intentionally narrow. They target the highest-value design
system drift points with low false-positive risk.

Presentation code should treat design-system widgets as lego blocks.
Interactive UI should be composed from approved primitives in `lib/widgets/`,
not rebuilt from raw tappable Material widgets in feature screens.

### Primitive taxonomy

The design-system hierarchy is intentionally narrow.

1. Token layer
   - `lib/theme/design_tokens.dart`
   - owns semantic color, spacing, size, motion, and accessibility values
   - feature code may read tokens but must not redefine them
2. Primitive component layer
   - `lib/widgets/themed_components.dart`
   - owns reusable lego blocks such as buttons, panels, cards, avatar chrome,
     and display-only chips
   - raw decoration primitives belong here if they are needed at all
3. Template composition layer
   - `lib/widgets/call_templates/`
   - arranges approved primitives into template-specific layouts
   - may choose alignment and tokenized spacing but should not recreate actions
     or visual chrome
4. Screen layer
   - `lib/app.dart` and future `lib/screens/`
   - composes blocs, layout, and design-system primitives only
   - should not introduce raw tappable widgets or raw decoration values

Rules:

- if a visual treatment repeats, extract it into a primitive
- if a widget owns semantics, focus order, or touch-target guarantees, screens
  must use that widget instead of rebuilding it
- if a feature needs `BoxDecoration`, `BorderRadius`, or `BorderSide`, prefer
  moving that styling into the primitive layer so the presentation surface stays
  lintable

### Quality gate integration

The single repo command:

```bash
flutter pub run tool/quality_gate.dart
```

now runs, in order:

1. `dart run custom_lint`
2. `flutter analyze --fatal-infos`
3. `flutter test --coverage`
4. coverage threshold enforcement

That makes custom design-system linting part of both local development and CI.

Note: the repo does not currently enable `custom_lint` through the analyzer
plugin hook in `analysis_options.yaml`. On the current Flutter/Dart toolchain in
this project, that hook causes `dart analyze` and `flutter analyze` plugin AOT
startup failures. The command-driven quality gate remains the stable
enforcement point for now.

## Approved Dependencies

Current implementation adds:

- `flutter_bloc` for state orchestration
- `get_it` for DI registration
- `path_provider` for local storage roots
- `crypto` for checksum verification
- `custom_lint` for repo-specific design-system linting

The in-repo custom lint package depends on:

- `custom_lint_builder`
- `analyzer`
