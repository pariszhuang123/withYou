# Design System

## Purpose

This design system is a safety contract, not a mood board.

The UI must remain legible, tappable, and predictable in low light, under time
pressure, and at large text scales. Any visual choice that conflicts with
clarity, accessibility, or behavioral honesty loses.

Material 3 remains the base system. Custom tokens and call-template specs are
the source of truth for app-specific behavior.

This document is the normative source for primitive hierarchy and accessibility
rules. If any other doc summarizes those rules differently, this document wins.

## Structure

The design system is implemented in typed primitives under `lib/theme/`.

| Layer | Responsibility |
|------|----------------|
| `AppTheme` | Builds explicit light and dark `ThemeData` |
| `ThemeExtension` tokens | Typed access to semantic colors, spacing, sizes, motion, accessibility, and call theme values |
| `CallTemplateContract` | Resolves locale + platform into a call template spec |
| `CallTemplateSpec` | Declares layout + palette + behavior flags for a template |

Do not use string-key maps for tokens. Do not hardcode spacing, colors, or hit
targets in widgets.

## Approved primitives

Presentation code should be assembled from approved lego blocks.

| Layer | Allowed ownership |
|------|-------------------|
| `lib/theme/` | Tokens, `ThemeData`, typography, icon theme, accessibility values |
| `lib/widgets/themed_components.dart` | Primitive actions, cards, panels, avatar chrome, display-only chips |
| `lib/widgets/call_templates/` | Layout composition of approved primitives |
| `lib/app.dart` and future screens | Screen composition only |

Rules:

- If a visual treatment repeats, promote it into `themed_components.dart`.
- If a widget owns touch target, semantics, focus order, reduced motion, or
  decorative safety constraints, feature code must reuse that widget.
- Raw `BoxDecoration`, `BorderRadius`, tappable Material controls, typography
  overrides, and icon sizing do not belong in presentation code outside the
  primitive layer.
- `docs/system/architecture.md` may summarize the hierarchy, but this document
  remains the normative source.

## Core Tokens

### Semantic color tokens

Use semantic intent, not direct hex values, in widget code.

| Token | Purpose |
|------|---------|
| `safeAction` | Accept / continue / confirm actions |
| `dangerAction` | Decline / end / destructive actions |
| `surfacePrimary` | App screen background |
| `surfaceSecondary` | Cards, sheets, grouped content |
| `surfaceCritical` | High-attention but non-destructive support surfaces |
| `textPrimary` | Primary readable copy |
| `textSecondary` | Supporting copy |
| `borderSubtle` | Non-dominant separators and outlines |
| `focusRing` | Keyboard and accessibility focus treatment |

### Spacing tokens

Spacing follows an 8dp grid for all major layout decisions.

| Token | Value |
|------|-------|
| `xSmall` | 4 |
| `small` | 8 |
| `medium` | 16 |
| `large` | 24 |
| `xLarge` | 32 |

### Component size tokens

| Token | Value | Requirement |
|------|-------|-------------|
| `homeTriggerSize` | 64dp | Primary home action |
| `callActionSize` | 72dp | Call accept / decline / end actions |
| `settingsTileMinHeight` | 56dp | Accessible settings rows |
| `cornerRadius` | 16dp | Standard action/input radius |
| `cardRadius` | 20dp | Elevated grouped content |

### Motion tokens

| Token | Value |
|------|-------|
| `avatarPulse` | 1500ms |
| `screenEntry` | 300ms |
| `actionFeedback` | 150ms |
| `stageTransition` | 200ms |

Motion must degrade safely. If platform accessibility settings request reduced
motion, non-essential animation should collapse to `Duration.zero` or a minimal
fade.

### Accessibility tokens

| Token | Value |
|------|-------|
| `minContrastRatio` | 4.5 |
| `minTouchTarget` | 48dp |
| `largeTouchTarget` | 72dp |
| `maxSupportedTextScale` | 2.0 |
| `reduceMotionDuration` | 0ms |

## Theme Rules

### Light and dark mode

- Home and settings surfaces follow the system light/dark theme.
- Call surfaces use a dedicated dark-biased call theme, even when the rest of
  the app is light.
- `ThemeData` must explicitly define `ColorScheme`, `TextTheme`, button themes,
  input themes, icon theme, list tile theme, and focus treatment. Do not rely
  on Flutter defaults for critical text/background combinations.

### Typography

| Context | Style | Requirement |
|------|-------|-------------|
| Main heading | `headlineMedium` | 24sp, semibold |
| Call identity | `headlineLarge` | 32sp, bold |
| Body copy | `bodyLarge` | 16sp, regular |
| Supporting copy | `bodyMedium` | 14sp, regular |
| Action labels | `labelLarge` | 14sp, semibold |

All text must remain readable up to `TextScaler.linear(2.0)` without clipped
critical actions or hidden status.

Do not define raw `TextStyle` values in presentation code. Screens and
templates should use `Theme.of(context).textTheme` styles or approved primitive
wrappers.

### Icon sizing

- Presentation code must inherit icon sizing from `IconTheme`, component
  tokens, or approved primitives.
- Raw `Icon(size: ...)` values are only allowed inside primitive-layer widgets
  that own the sizing contract.

## Call Template Rules

Call templates are style variants, not behavior variants.

The following are invariant across all templates:

- Only `accept`, `decline`, and `end` are actionable.
- No fake mute, keypad, speaker, add-call, or message controls may be
  interactive.
- Display-only chrome is allowed only if it is excluded from semantics and
  cannot receive focus.
- Caller identity, timer, and call state semantics must remain consistent.
- Accept uses the semantic safe-action color family.
- Decline and end use the semantic danger-action color family.

### Template resolution

`CallTemplateContract.resolve(Locale locale, TargetPlatform platform)` returns a
typed `CallTemplateSpec`.

Resolution priority:

1. `countryCode`
2. `languageCode`
3. platform fallback

Current mapping:

| Locale / Platform | Template |
|------|----------|
| `zh-CN` or bare `zh` | `wechatStyle` |
| `zh-TW` | `lineStyle` |
| `zh-HK` | `whatsappStyle` |
| `ja` | `lineStyle` |
| iOS / macOS fallback | `iosNative` |
| Android and all other fallback | `androidNative` |

Template choice may support more locales than app l10n. This affects visual
layout selection only; it does not imply additional translated UI strings.

## RTL and locale expansion

The design system must survive locale expansion even before a locale has full
product translation support.

Rules:

- Start/end alignment must use directional behavior where layout direction
  matters.
- Layouts must remain stable under RTL `Directionality`.
- Long localized labels and caller names must not hide primary actions or clip
  essential status.
- Template fallback for unsupported locales must remain visually safe even when
  labels expand significantly.

## Accessibility Acceptance Criteria

The design system is not valid unless the following are testable and passing:

- All required foreground/background pairs meet WCAG AA contrast.
- Home, settings, and call actions meet tokenized minimum target sizes.
- Critical controls expose clear semantics labels and button roles.
- Display-only call chrome is absent from semantics.
- Theme surfaces and text pairings are correct in both light and dark mode.
- Large text scales do not produce overflow for critical actions or status copy.
- Reduced-motion behavior preserves state clarity.
- RTL layout and expanded localized strings do not break critical call actions
  or screen hierarchy.

## Testing Expectations

At minimum:

- Unit tests for token integrity and semantic token mapping
- Unit tests for call-template resolution and fallback behavior
- Widget tests for hit targets, semantics, text scaling, and theme rendering
- Widget tests for RTL layout and long localized strings
- Contrast-ratio assertions for required color pairs
- Golden tests for critical call, disabled, loading, and error states

If a design-system change modifies a token, template mapping, or accessibility
rule, tests must change in the same commit.
