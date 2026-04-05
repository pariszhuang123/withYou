# Emoji & Language Contract

## Purpose

Keep the app's user-facing state language instantly understandable, believable
in public, and consistent across screens.

This is a supporting product spec. It does not replace the code-backed call-flow
contracts or the internal `Scenario` enum.

## Product Fit

WithYou is designing a believable social layer, not a feature dashboard.

The app already has three internal scenarios:

- `presence`
- `socialPull`
- `exitPressure`

Those internal identifiers remain valid for code, contracts, storage, and
assets.

The user-facing layer must present those scenarios as real social needs rather
than feature styles.

## Core Principle

Everything user-facing should feel like a normal human situation, not an app
mode.

Use this test:

- if it feels like a feature, reject it
- if it feels like a human situation, keep it

## Locked State Mapping

There are exactly three user-facing states.

| Internal Scenario | Locked Emoji | Locked English Label | Intent |
|---|---|---|---|
| `presence` | `👀` | `Stay with me` | calm presence / passive cover |
| `socialPull` | `🕒` | `Ease me out` | believable time-based exit |
| `exitPressure` | `🚪` | `Get me out` | clear leave-now support |

Rules:

- no fourth state
- no decorative alternate state names
- no screen-specific relabeling of these three states
- internal enum names do not need to match the user-facing labels

## Localization Rule

The semantic mapping is locked. Localized wording may vary by language only if
it preserves:

- the same scenario mapping
- the same emotional intensity
- less-than-two-second understanding
- public-glance believability

If a locale has not been explicitly reviewed, prefer the approved English labels
instead of inventing local synonyms ad hoc.

## Emoji Rules

### Approved emojis

- `👀` for `Stay with me`
- `🕒` for `Ease me out`
- `🚪` for `Get me out`

### Placement

- emoji appears before the label
- exactly one emoji per state
- no emoji stacking

### Requirements

Each emoji must:

- be understood in under one second
- point to a real-world concept
- support the scenario even without reading the label
- remain low-drama in public

### Prohibitions

Do not use:

- cute or playful emojis
- melodramatic reaction emojis
- abstract or metaphorical emojis
- aggressive urgency markers as decoration

Examples to avoid:

- `🐱` `🍰` `🎮` `🧸`
- `😂` `😭` `🤯` `😡`
- `❗` `🔥` `💥`
- `🪄`

## Tone Rules

All user-facing state language and microcopy must be:

- human
- calm
- neutral
- discreet
- non-judgmental
- quickly understood

Avoid:

- system terms such as `mode`, `activate`, or `session`
- command-heavy phrasing
- cheerful gimmick copy
- copy that explains the product instead of supporting the moment

## Locked State Labels

Default approved English labels:

- `👀 Stay with me`
- `🕒 Ease me out`
- `🚪 Get me out`

These labels should be used for state selection and any other compact primary
state UI unless a locale-specific equivalent has been reviewed and approved.

## Microcopy Guidance

Short supporting copy should sound like a real person, not an interface.

Good directional examples:

- `What do you need right now?`
- `I'm here.`
- `You’re good.`
- `Might need to go soon.`
- `Hey, are you still around?`
- `I need you for a sec.`
- `Come out real quick.`

Rules:

- short enough to grasp at a glance
- slight natural imperfection is acceptable
- never theatrical or robotic
- should still sound normal if overheard

## Social Believability Test

Every emoji-plus-label pair and every line of supporting copy must pass this
check:

- if someone sees it for one second, does it look normal?

Reject copy that:

- looks staged
- looks like an app feature name
- needs interpretation

Keep copy that:

- reads like a plausible human situation
- does not draw extra attention
- does not expose intent

## Consistency Rule

The same state pairing must stay consistent across:

- home selection UI
- paywall summaries
- notification-related explanation
- widget setup copy
- any future onboarding or settings surfaces

Do not A/B test the core state names or emojis without updating this spec.

## Anti-Drift Clause

Do not introduce:

- style-based names such as `Gentle`, `Steady`, or `Urgent`
- alternative state labels on different screens
- decorative extra emojis
- feature-language wrappers around the three core states

## Review Checklist

Before shipping copy changes, confirm:

- the user can choose a state without reading deeply
- the emoji helps meaning instantly
- the copy sounds human
- the wording feels safe in public
- the wording matches the correct internal scenario

If any answer is no, rewrite before shipping.
