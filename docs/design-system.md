# Design System

## Foundation: Material 3 (Material You)

### Why Material 3
- Native Flutter support: `useMaterial3: true` — zero extra dependencies
- Adaptive across Android and iOS
- Built-in dark mode (critical — many scenarios happen at night)
- Dynamic color on Android 12+
- Accessible by default (contrast ratios, touch target sizes)

## Theme Configuration

### Color Palette
```dart
// lib/theme/app_theme.dart

// App palette — calm, trustworthy
static const primaryColor = Color(0xFF2D5F7C);       // Muted teal-blue
static const onPrimaryColor = Color(0xFFFFFFFF);
static const secondaryColor = Color(0xFF5C8A9E);      // Lighter teal
static const surfaceColor = Color(0xFFF5F5F5);        // Light mode background
static const darkSurfaceColor = Color(0xFF121212);     // Dark mode background

// Call screen palette — must mimic native phone call UI
static const callBackground = Color(0xFF1A1A1A);      // Dark, full-screen
static const callAccept = Color(0xFF4CAF50);           // Green — accept
static const callDecline = Color(0xFFF44336);          // Red — decline
static const callTextPrimary = Color(0xFFFFFFFF);      // Caller name
static const callTextSecondary = Color(0xFFB0B0B0);    // "Incoming call..." label
```

### Typography
| Context | Style | Size | Weight |
|---------|-------|------|--------|
| Home — main button label | `headlineMedium` | 24sp | Medium |
| Home — subtitle | `bodyLarge` | 16sp | Regular |
| Call — caller name | `headlineLarge` | 32sp | Bold |
| Call — "Incoming call" label | `bodyMedium` | 14sp | Regular |
| Settings — option label | `bodyLarge` | 16sp | Regular |
| Settings — section header | `labelLarge` | 14sp | Medium |

### Spacing
- Grid system: 8dp increments (Material standard)
- Screen padding: 24dp horizontal, 16dp vertical
- Component spacing: 16dp between major elements

### Touch Targets
| Element | Minimum Size | Notes |
|---------|-------------|-------|
| Home — start button | 64×64dp | Primary action, must be easy to tap |
| Call — accept/decline | 72×72dp | Must be tappable under stress |
| Settings — list items | 48dp height | Material standard |

## Screen Specifications

### Home Screen
```
┌──────────────────────────────┐
│  [⚙]         [接送催促 ▼]    │  ← Settings icon left, scenario selector right
│                              │
│                              │
│                              │
│                              │
│         ┌──────────┐         │
│         │          │         │
│         │   LOGO   │         │  ← App logo as button, large, tappable
│         │          │         │
│         └──────────┘         │
│                              │
│         随时为你              │  ← bodyMedium, muted, centered
│                              │
│                              │
│                              │
└──────────────────────────────┘
```
- **Logo is the sole trigger** — no text button label. Tap logo → call starts.
- Scenario selector lives in the top bar, minimal footprint
- Subtitle "随时为你" (always with you) is decorative only, not a button
- Background: `surfaceColor` (light) or `darkSurfaceColor` (dark)
- Button: elevated, circular or rounded-square, with gentle shadow
- Maximum whitespace — screen should feel calm and empty
- If someone glances at the phone, it looks like a simple, unremarkable app
- Trigger time target: < 3 seconds from tap to call screen

### Call Screen (Critical — must look real)
```
┌──────────────────────────────┐
│                              │
│         ┌────────┐           │
│         │ AVATAR │           │  ← Circular, 96dp
│         └────────┘           │
│                              │
│           小陈                │  ← headlineLarge, white, centered
│       Incoming call...       │  ← bodyMedium, gray, centered
│                              │
│                              │
│                              │
│    🔴 Decline    Accept 🟢   │  ← 72dp circles, bottom third
│                              │
└──────────────────────────────┘
```
- Background: `callBackground` (solid dark)
- Status bar: HIDDEN during call
- No app branding visible
- Accept button: green circle with phone icon
- Decline button: red circle with phone-down icon
- During "in call" state: replace buttons with a timer and "End Call" button
- Subtle pulse animation on avatar while ringing

### Settings Screen
- Standard Material 3 list with sections
- Each option uses `ListTile` with trailing dropdown or radio
- Sections: Scenario
- Back navigation to Home

## Dark Mode
- Mandatory support — many use cases happen at night
- Home screen follows system theme
- Call screen is ALWAYS dark (mimics native call UI)

## Animations
| Element | Animation | Duration |
|---------|-----------|----------|
| Avatar pulse (ringing) | Scale 1.0 → 1.05 → 1.0 | 1.5s, repeat |
| Call screen entry | Slide up + fade in | 300ms |
| Accept/decline tap | Ripple + scale down | 150ms |
| Stage transition | Cross-fade | 200ms |

## Accessibility
- All interactive elements have semantic labels
- Minimum contrast ratio: 4.5:1 (WCAG AA)
- Support for system font scaling
- Call buttons large enough for motor impairment (72dp minimum)

## Localization (l10n)

UI strings follow the **device system locale** via Flutter's built-in l10n:

| Aspect | Rule |
|--------|------|
| UI strings | Localized via ARB files (`lib/l10n/app_en.arb`, `app_zh.arb`) |
| System locale detection | `Platform.localeName` / `Localizations.localeOf(context)` |
| Fallback | English if locale not supported |
| Audio content | Chinese only (v1) — NOT localized |
| Scenario names | Localized (e.g. "接送催促" in zh, "Pickup Expectation" in en) |
| Caller names | Always Chinese (part of audio content, not UI) |
| No manual language selector | System locale only — zero user configuration |

### Localized Strings (v1)

| Key | Chinese (zh) | English (en) |
|-----|-------------|-------------|
| `homeSubtitle` | 随时为你 | Always with you |
| `scenarioPickup` | 接送催促 | Pickup Expectation |
| `scenarioSafety` | 关心确认 | Safety Check |
| `scenarioCasual` | 轻松脱身 | Casual Exit |
| `scenarioUrgent` | 稍微紧急 | Urgent Pull-away |
| `callIncoming` | 来电 | Incoming call |
| `callAccept` | 接听 | Accept |
| `callDecline` | 拒绝 | Decline |
| `callEnd` | 挂断 | End Call |
| `settings` | 设置 | Settings |
| `paywallTitle` | 随时陪伴你 | Keep this with you |
| `paywallSubtitle` | 一次购买，永久使用 | One-time unlock. Works offline. |
| `paywallButton` | 解锁 WithYou | Unlock WithYou |

### MaterialApp Configuration

```dart
MaterialApp(
  // l10n
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  // Use device system locale — no manual override
)
```

## Implementation
Theme defined in `lib/theme/app_theme.dart`. Applied in `MaterialApp` in `main.dart`:
```dart
MaterialApp(
  theme: AppTheme.light(),
  darkTheme: AppTheme.dark(),
  themeMode: ThemeMode.system,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
)
```
