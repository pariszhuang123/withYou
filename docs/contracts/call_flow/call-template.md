# Call Template Contract

| Field | Value |
|---|---|
| Version | `v0.1` |
| Status | `active` |
| Last Updated | `2026-04-02` |
| Generated | `manually curated` |
| ADR | `none` |
| Module | `call_flow` |
| Source | `lib/contracts/call_flow/call_template_contract.dart` |

## Purpose

Select the visual call-screen template from locale + platform without changing
call behavior.

This contract is for style resolution only. It must not introduce different
accept/decline/end rules between templates.

## Contract Interface

```dart
abstract class CallTemplateContract {
  CallTemplateSpec resolve(Locale locale, TargetPlatform platform);
}
```

The resolver returns a typed spec containing:

- template identity
- layout family
- ringing and in-call palette
- dark/light flags for each call state
- localized display label for the call subtitle
- a list of display-only controls

`displayOnlyControls` must default to empty. Any future non-empty value must be
excluded from semantics and focus handling.

## Resolution Rules

Priority:

1. `countryCode`
2. `languageCode`
3. platform fallback

Current mapping:

| Input | Result |
|------|--------|
| `zh-CN` or bare `zh` | `wechatStyle` |
| `zh-TW` | `lineStyle` |
| `zh-HK` | `whatsappStyle` |
| `ja` | `lineStyle` |
| iOS / macOS fallback | `iosNative` |
| Android and all other fallback | `androidNative` |

## Behavior Invariants

All templates share these rules:

- Only accept, decline, and end may be interactive.
- Ringing and in-call semantics stay consistent across templates.
- Accept uses a safe-action color family.
- Decline and end use a danger-action color family.
- Avatar pulse is allowed during ringing only.
- Template differences are cosmetic. They must not change state flow.

## Tests

The following must be covered:

- Mainland Chinese locale resolves to WeChat-style
- Taiwan and Japanese locales resolve to LINE-style
- Hong Kong locale resolves to WhatsApp-style
- iOS and macOS fall back to iOS-native
- Android and unsupported locales fall back to Android-native
- No resolved template exposes interactive decorative controls by default
