# Data Model

## Purpose

Defines the minimal SQLite schema managed by Drift. Only app preferences and purchase state are persisted. No session history and no call logs.

## Tables

### `app_state`

| Column | Drift Type | Dart Type | Default | Description |
|--------|-----------|-----------|---------|-------------|
| `id` | `IntColumn` | `int` | `1` | Singleton row key |
| `selected_scenario` | `TextColumn` | `String` | `"socialPull"` | Current scenario |
| `has_purchased` | `BoolColumn` | `bool` | `false` | One-time purchase flag |
| `completed_flow_count` | `IntColumn` | `int` | `0` | Total completed flows |
| `emergency_bypass_last_used` | `DateTimeColumn` | `DateTime?` | `null` | Last emergency bypass use |

## Rules

- `app_state` always has exactly one row
- Active flow state is not persisted
- All timestamps are UTC
