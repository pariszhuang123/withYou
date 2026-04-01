# Testing Strategy

## Philosophy

> **Test the contract, not the implementation.**
>
> Every test mocks dependencies via their contracts. If a test needs a real database or real audio, it is an integration test.

> **This is a safety-critical app.** People rely on it in real social situations. A flaky test is a potential safety failure.

## Test Structure
```
test/
├── unit/                    # Isolated tests with mocked contracts
│   ├── services/
│   │   ├── call_flow_service_test.dart
│   │   ├── content_resolver_service_test.dart
│   │   └── paywall_service_test.dart
│   ├── repositories/
│   │   └── call_session_repository_test.dart
│   └── blocs/
│       ├── call_flow_bloc_test.dart
│       ├── settings_bloc_test.dart
│       └── paywall_bloc_test.dart
├── integration/             # Tests with real dependencies
│   ├── call_flow_integration_test.dart
│   ├── notification_integration_test.dart
│   └── audio_playback_integration_test.dart
├── widget/                  # Widget render + interaction tests
│   ├── home_screen_test.dart
│   ├── call_screen_test.dart
│   └── settings_screen_test.dart
├── mocks/                   # Shared mock implementations
│   ├── mock_call_flow.dart
│   ├── mock_audio_playback.dart
│   ├── mock_notification.dart
│   ├── mock_repository.dart
│   ├── mock_content_resolver.dart
│   └── mock_paywall.dart
└── fixtures/                # Test data
    └── test_audio.m4a

integration_test/            # Full E2E on-device tests
├── full_flow_test.dart
└── widget_trigger_test.dart
```

## Mock Strategy

All mocks implement contract interfaces using `mocktail`:

```dart
import 'package:mocktail/mocktail.dart';

class MockCallFlow extends Mock implements CallFlowContract {}
class MockAudioPlayback extends Mock implements AudioPlaybackContract {}
class MockNotification extends Mock implements NotificationContract {}
class MockCallSessionRepository extends Mock implements CallSessionRepository {}
class MockContentResolver extends Mock implements ContentResolverContract {}
// Usage: when(() => mockContentResolver.resolveCallerName(scenario))
//        .thenReturn('expectedName');
// No persona or language parameters — resolution is scenario-based only.
class MockPaywall extends Mock implements PaywallContract {}
```

## Critical Test Cases — Call Flow

These are **non-negotiable**. Every single one must pass before any merge.

### Happy Path
| # | Test Case | Expected Behavior |
|---|-----------|-------------------|
| 1 | Start → Accept S1 → Accept S2 → Accept S3 | Full flow completes, session status = completed, completed_call_count incremented |
| 2 | Start flow emits ringing state | flowStateStream emits `ringing` immediately |
| 3 | Accept emits inCall state | flowStateStream emits `inCall` after accept |
| 4 | Audio completion schedules next stage | NotificationContract.scheduleFollowUp called with correct delay |
| 5 | Stage 3 completion emits completed | flowStateStream emits `completed`, no more notifications |

### Decline Path
| # | Test Case | Expected Behavior |
|---|-----------|-------------------|
| 6 | Start → Decline S1 | Flow ends, no S2 scheduled, session status = cancelled |
| 7 | Start → Accept S1 → Decline S2 | S1 audio plays, S2 declined, no S3, session cancelled |
| 8 | Start → Accept S1 → Accept S2 → Decline S3 | S1+S2 play, S3 declined, session cancelled |
| 9 | Decline stops audio immediately | AudioPlaybackContract.stop() called |
| 10 | Decline cancels all pending notifications | NotificationContract.cancelAll() called |
| 11 | Decline emits cancelled state | flowStateStream emits `cancelled` |

### Miss Path
| # | Test Case | Expected Behavior |
|---|-----------|-------------------|
| 12 | Start → Accept S1 → Miss S2 notification | S2 treated as decline, flow ends |
| 13 | Missed stage logs "missed" event | CallSessionRepository.logEvent called with `missed` type |

### Edge Cases
| # | Test Case | Expected Behavior |
|---|-----------|-------------------|
| 14 | Start flow while another is active | Previous flow cancelled, new flow starts cleanly |
| 15 | Audio playback error during stage | Stage treated as completed, next stage scheduled |
| 16 | Stage timing applies ± 30% randomness | Delay is within expected min/max range |
| 17 | getActiveSession returns current flow | Returns session with status "active" |
| 18 | getActiveSession returns null when idle | No active session |

### Paywall Tests
| # | Test Case | Expected Behavior |
|---|-----------|-------------------|
| 19 | First flow free | shouldShowPaywall() returns false during/after first flow |
| 20 | Paywall after first completed flow | shouldShowPaywall() returns true after completion |
| 21 | Paywall never during active flow | Even if threshold met, returns false while active |
| 22 | Purchase persists | hasPurchased() returns true after recordPurchase() |
| 23 | No paywall after purchase | shouldShowPaywall() returns false after purchase |

### Content Resolution Tests — Scenario-Based
| # | Test Case | Expected Behavior |
|---|-----------|-------------------|
| 24 | pickupExpectation → caller name | resolveCallerName returns neutral name for scenario |
| 25 | safetyCheck → caller name | resolveCallerName returns neutral name for scenario |
| 26 | casualExit → caller name | resolveCallerName returns neutral name for scenario |
| 27 | urgentPullaway → caller name | resolveCallerName returns neutral name for scenario |
| 28 | Each scenario → audio paths | resolveAudioPath returns correct paths for each stage |
| 29 | Avatar resolution | resolveAvatarPath returns default or per-scenario avatar |

### Speaker Tests
| # | Test Case | Expected Behavior |
|---|-----------|-------------------|
| 30 | Audio plays with forceSpeaker=true | Speaker route set before playback starts |
| 31 | Stop called → playback stops | Stream emits idle state |

## Widget Test Cases

### Home Screen
| # | Test | Expected |
|---|------|----------|
| W1 | Renders start button | Button with "Call me now" / "呼叫我" visible |
| W2 | Tap start button triggers flow | CallFlowBloc receives StartFlow event |
| W3 | Scenario selector renders | Dropdown with "Cab" selected |

### Call Screen
| # | Test | Expected |
|---|------|----------|
| W4 | Shows caller name | Correct neutral name for selected scenario |
| W5 | Shows avatar | Correct avatar for selected scenario |
| W6 | Accept button triggers accept | CallFlowBloc receives AcceptStage event |
| W7 | Decline button triggers decline | CallFlowBloc receives DeclineStage event |
| W8 | Ringing state shows accept + decline | Both buttons visible |
| W9 | InCall state shows end call only | Accept/decline replaced with end button |

### Settings Screen
| # | Test | Expected |
|---|------|----------|
| W10 | Scenario options render | All 4 scenarios listed |
| W11 | Selection persists | Changing scenario updates SettingsBloc |

## Integration Test Cases

### Database Integration
| # | Test | Expected |
|---|------|----------|
| I1 | Create session persists | Session retrievable after create |
| I2 | Update stage persists | Stage and status updated in DB |
| I3 | Log event persists | Event retrievable with correct type/timestamp |
| I4 | Completed count accurate | Counts only completed sessions |
| I5 | Active session query | Returns only the active session |

### Full Flow E2E
| # | Test | Expected |
|---|------|----------|
| E1 | Complete user journey | Open → tap → accept S1 → accept S2 → accept S3 → paywall shown |
| E2 | Decline mid-flow | Open → tap → accept S1 → decline S2 → back to home |

## Running Tests

```bash
# All tests
flutter test

# Unit tests only
flutter test test/unit/

# Widget tests only
flutter test test/widget/

# Integration tests only
flutter test test/integration/

# E2E tests (requires device/emulator)
flutter test integration_test/

# With coverage
flutter test --coverage

# Coverage report
genhtml coverage/lcov.info -o coverage/html
```

## Coverage Requirements
- **Minimum: 80% line coverage** (enforced in CI)
- Target: 90%+ for `lib/services/` and `lib/blocs/`
- `lib/database/*.g.dart` (generated) excluded from coverage
