# Testing Strategy

## Philosophy

Test the contract, not the implementation. This app is safety-critical, so
scenario timing and non-canceling follow-up behavior need explicit coverage.

## Unit Test Focus

### Call Flow

Required cases:

| # | Test Case | Expected Behavior |
|---|-----------|-------------------|
| 1 | Start `presence` flow | Emits `ringing` immediately at Stage 1 |
| 2 | Accept `presence` Stage 1 | Plays audio, then completes with no follow-up |
| 3 | Decline `presence` Stage 1 | Completes immediately |
| 4 | Start `socialPull` flow | Emits `ringing` immediately at Stage 1 |
| 5 | Accept `socialPull` Stage 1 | Schedules Stage 2 in 120-240 seconds |
| 6 | Decline `socialPull` Stage 1 | Still schedules Stage 2 in 120-240 seconds |
| 7 | Miss `socialPull` Stage 2 | Treated as decline and still schedules Stage 3 |
| 8 | Decline `socialPull` Stage 3 | Completes flow |
| 9 | Start `exitPressure` flow | Emits `ringing` immediately at Stage 1 |
| 10 | Accept `exitPressure` Stage 1 | Schedules Stage 2 in 45-90 seconds |
| 11 | Decline `exitPressure` Stage 2 | Still schedules Stage 3 in 90-180 seconds |
| 12 | Resolve `exitPressure` Stage 3 | Completes flow |
| 13 | Invalid follow-up stage for `presence` | Throws argument error |

### Content Resolution

| # | Test Case | Expected Behavior |
|---|-----------|-------------------|
| 14 | `presence` caller name | Returns the fixed name for `presence` |
| 15 | `socialPull` caller name | Returns the fixed name for `socialPull` |
| 16 | `exitPressure` caller name | Returns the fixed name for `exitPressure` |
| 17 | `presence` audio path | Resolves Stage 1 only |
| 18 | `socialPull` audio paths | Resolves Stage 1 to Stage 3 |
| 19 | `exitPressure` audio paths | Resolves Stage 1 to Stage 3 |

### App State

| # | Test Case | Expected Behavior |
|---|-----------|-------------------|
| 20 | Default selected scenario | Defaults to `socialPull` |
| 21 | Scenario selection persists | Updated scenario is returned on next read |
| 22 | Purchase state persists | Purchase flag remains true after record |

## Widget Test Focus

| # | Test | Expected |
|---|------|----------|
| W1 | Scenario selector renders | Shows the currently selected scenario |
| W2 | Scenario options render | Lists `Presence`, `Social Pull`, and `Exit Pressure` |
| W3 | Ringing state UI | Shows accept and decline actions |
| W4 | In-call state UI | Shows active-call presentation only |

### Accessibility and design-system gate

- call actions expose semantics labels and roles
- focus order is deterministic
- reduced motion collapses non-essential animation
- large localized strings and RTL layout keep critical actions visible
- display-only chrome stays out of semantics
- golden coverage exists for critical call states plus disabled, loading, and
  error design-system states

## Integration Test Focus

| # | Test | Expected |
|---|------|----------|
| I1 | Notification payload resume | Cold start resumes the correct scenario and stage |
| I2 | Missed follow-up handling | Missed stage advances according to scenario rules |
| I3 | Final-stage cleanup | Pending notifications are cleared when the flow completes |

## Commands

```bash
flutter pub run tool/quality_gate.dart
```

## Coverage

- Minimum: 80% line coverage
- Target: 90%+ for service-layer logic

## Snapshot suites

- `test/widgets/call_template_goldens_test.dart`
- `test/widgets/design_system_state_goldens_test.dart`
