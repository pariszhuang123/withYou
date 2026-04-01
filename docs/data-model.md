# Data Model

## Purpose
Defines the SQLite database schema managed by Drift. All data is local — nothing leaves the device.

## Database: `AppDatabase`
Defined in `lib/database/app_database.dart`. Generated code in `app_database.g.dart`.

## Tables

### `app_state`
Single-row table for global app state.

| Column | Drift Type | Dart Type | Default | Description |
|--------|-----------|-----------|---------|-------------|
| `id` | `IntColumn` | `int` | 1 (fixed) | Always row 1 |
| `completed_call_count` | `IntColumn` | `int` | 0 | Total completed flows |
| `has_seen_paywall` | `BoolColumn` | `bool` | false | Whether paywall was shown |
| `has_purchased_unlock` | `BoolColumn` | `bool` | false | Whether user paid |
| `selected_scenario` | `TextColumn` | `String` | "pickup_expectation" | Current scenario selection |

### `call_sessions`

| Column | Drift Type | Dart Type | Nullable | Description |
|--------|-----------|-----------|----------|-------------|
| `id` | `TextColumn` | `String` | No | UUID, primary key |
| `scenario` | `TextColumn` | `String` | No | e.g. "pickup_expectation" |
| `current_stage` | `IntColumn` | `int` | No | 1, 2, or 3 |
| `status` | `TextColumn` | `String` | No | "active", "completed", "cancelled" |
| `started_at` | `DateTimeColumn` | `DateTime` | No | Session creation timestamp |

### `call_events`

| Column | Drift Type | Dart Type | Nullable | Description |
|--------|-----------|-----------|----------|-------------|
| `id` | `TextColumn` | `String` | No | UUID, primary key |
| `session_id` | `TextColumn` | `String` | No | FK → call_sessions.id |
| `stage` | `IntColumn` | `int` | No | 1, 2, or 3 |
| `event_type` | `TextColumn` | `String` | No | "triggered", "accepted", "declined", "completed", "cancelled" |
| `timestamp` | `DateTimeColumn` | `DateTime` | No | Event timestamp |

## Drift Code Generation
Run after modifying table definitions:
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Rules
- Only ONE session can have status "active" at a time.
- `app_state` always has exactly one row (id=1). Use upsert on initialization.
- All timestamps are UTC.
- UUIDs generated via Dart's `uuid` package.
