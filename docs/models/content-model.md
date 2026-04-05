# Content Model

## Purpose

Defines how the three scenarios map to caller names, ringtone, and audio assets.
v1 remains Chinese audio only with fixed caller identity per scenario.

User-facing naming and emoji rules for these scenarios are defined separately in
`docs/models/emoji-language-contract.md`.

## Scenarios

| Enum Value | User-Facing State | Existing Chinese Label | Existing English Label | Description | Caller Name | Required Audio Files |
|------------|-------------------|------------------------|------------------------|-------------|-------------|----------------------|
| `presence` | `👀 Stay with me` | `陪伴掩护` | `Presence` | One-call anchor for companionship or passive cover | `Xiao Chen` | `stage_1` |
| `socialPull` | `🕒 Ease me out` | `柔性牵引` | `Social Pull` | Believable ongoing expectation without urgency | `Xiao Li` | `stage_1`, `stage_2`, `stage_3` |
| `exitPressure` | `🚪 Get me out` | `快速脱身` | `Exit Pressure` | Urgent but controlled reason to leave now | `Xiao Zhang` | `stage_1`, `stage_2`, `stage_3` |

Notes:

- enum values are the source of truth for code and assets
- user-facing labels should follow the emoji and language contract
- legacy style-based labels are not valid user-facing replacements

## Caller Name Rules

- Must use neutral, common names
- Must not use relationship-specific names
- Must not use generic labels
- Caller names are fixed per scenario

## Asset Structure

```text
assets/
├── audio/
│   ├── system/
│   │   └── ringtone_loop.m4a
│   └── zh/
│       ├── presence/
│       │   └── stage_1.m4a
│       ├── social_pull/
│       │   ├── stage_1.m4a
│       │   ├── stage_2.m4a
│       │   └── stage_3.m4a
│       └── exit_pressure/
│           ├── stage_1.m4a
│           ├── stage_2.m4a
│           └── stage_3.m4a
```

## Audio Script Design Principles

- Scripts are written for speaker playback and may be overheard
- `presence` should sound connected and calm, not escalating
- `socialPull` should build expectation gradually, not sound urgent
- `exitPressure` should tighten direction clearly, without panic or melodrama
- No app-specific language
- No robotic or exaggerated phrasing

## MVP Assets Required

1 ringtone plus 7 scenario audio files:

```text
assets/audio/system/ringtone_loop.m4a
assets/audio/zh/presence/stage_1.m4a
assets/audio/zh/social_pull/stage_1.m4a
assets/audio/zh/social_pull/stage_2.m4a
assets/audio/zh/social_pull/stage_3.m4a
assets/audio/zh/exit_pressure/stage_1.m4a
assets/audio/zh/exit_pressure/stage_2.m4a
assets/audio/zh/exit_pressure/stage_3.m4a
```
