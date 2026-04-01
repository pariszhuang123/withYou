# Content Model

## Purpose
Defines how scenarios map to displayable content and audio assets. v1 is **Chinese only** with **no persona selection** — callers use neutral/common names.

## Scenarios (max 4)

| Enum Value | Label (ZH) | Label (EN) | Caller Name | Description |
|------------|-----------|-----------|-------------|-------------|
| `pickup_expectation` | 接送催促 | Pickup Expectation | 小陈 | "I'm downstairs, are you coming?" |
| `safety_check` | 关心确认 | Safety Check | 阿杰 | "Just checking if you're okay" |
| `casual_exit` | 轻松脱身 | Casual Exit | 小林 | Light excuse to leave |
| `urgent_pullaway` | 稍微紧急 | Urgent Pull-away | 小王 | Something came up, need you now |

Each scenario has:
- A fixed caller name (neutral/common)
- 3 audio files: `stage_1.m4a`, `stage_2.m4a`, `stage_3.m4a`
- Total audio duration per scenario: **8–15 seconds per stage**
- File size: **≤ 900KB per scenario**, **≤ 5MB total**

## Caller Name Rules
- MUST use neutral/common Chinese names (小陈, 阿杰, 小林, 小王)
- MUST NOT use relationship-specific names (老公, 爸爸, 老婆, 妈妈)
- Names must sound plausible as any acquaintance — friend, colleague, neighbor

## Asset Structure
```
assets/
├── audio/
│   └── zh/
│       ├── pickup_expectation/
│       │   ├── stage_1.m4a
│       │   ├── stage_2.m4a
│       │   └── stage_3.m4a
│       ├── safety_check/
│       │   ├── stage_1.m4a
│       │   ├── stage_2.m4a
│       │   └── stage_3.m4a
│       ├── casual_exit/
│       │   ├── stage_1.m4a
│       │   ├── stage_2.m4a
│       │   └── stage_3.m4a
│       └── urgent_pullaway/
│           ├── stage_1.m4a
│           ├── stage_2.m4a
│           └── stage_3.m4a
└── avatars/
    └── default_contact.png
```

## Audio Script Design Principles
Scripts are designed for **speaker playback** — bystanders will overhear them:
- Lines create urgency: "I'm downstairs", "Where are you?", "I've been waiting"
- Tone is caring but insistent — not panicked
- Pacing includes natural pauses for the user to "respond" (say "yes", "I'm coming")
- No app-specific language — sounds like a real person on a real call
- Each stage escalates slightly in concern

## Audio Format
| Property | Value |
|----------|-------|
| Codec | AAC |
| Container | M4A |
| Bitrate | 96–128 kbps |
| Channels | Mono |
| Sample rate | 44.1 kHz |
| Duration | 8–15 seconds per stage |
