# Data Model

## Purpose

Defines the current persisted local state. The implementation is JSON-backed
today, even though these fields could later migrate into Drift if the app needs
stronger schema and migration guarantees.

## Current JSON Shape

### `app_state.json`

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `selectedAudioLocaleTag` | `String?` | `null` | Current audio locale |
| `selectedScenario` | `String?` | `null` | Current selected scenario |
| `hasPremiumAccess` | `bool` | `false` | Local premium entitlement flag |

## Rules

- Active flow state is not persisted
- No call history or call logs are persisted
- Pending follow-ups are stored separately from app state
