# Content Model

## Purpose

Defines how the three scenarios map to caller names, avatars, and audio assets.
v1 remains Chinese audio only with fixed caller identity per scenario.

## Scenarios

| Enum Value | Chinese Label | English Label | Description | Caller Name | Required Audio Files |
|------------|---------------|---------------|-------------|-------------|----------------------|
| `presence` | 陪伴掩护 | Presence | One-call anchor for companionship or passive cover | `Xiao Chen` | `stage_1` |
| `socialPull` | 柔性牵引 | Social Pull | Believable ongoing expectation without urgency | `Xiao Li` | `stage_1`, `stage_2`, `stage_3` |
| `exitPressure` | 快速脱身 | Exit Pressure | Urgent but controlled reason to leave now | `Xiao Zhang` | `stage_1`, `stage_2`, `stage_3` |

## Caller Name Rules

- Must use neutral, common names
- Must not use relationship-specific names
- Must not use generic labels
- Caller names are fixed per scenario

## Asset Structure

```text
assets/
├── audio/
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
└── avatars/
    └── default_contact.png
```

## Audio Script Design Principles

- Scripts are written for speaker playback and may be overheard
- `presence` should sound connected and calm, not escalating
- `socialPull` should build expectation gradually, not sound urgent
- `exitPressure` should tighten direction clearly, without panic or melodrama
- No app-specific language
- No robotic or exaggerated phrasing

## MVP Assets Required

7 audio files plus 1 avatar:

```text
assets/audio/zh/presence/stage_1.m4a
assets/audio/zh/social_pull/stage_1.m4a
assets/audio/zh/social_pull/stage_2.m4a
assets/audio/zh/social_pull/stage_3.m4a
assets/audio/zh/exit_pressure/stage_1.m4a
assets/audio/zh/exit_pressure/stage_2.m4a
assets/audio/zh/exit_pressure/stage_3.m4a
assets/avatars/default_contact.png
```
