# Pending Follow Up Repository Contract

| Field | Value |
|---|---|
| Version | `v0.1` |
| Status | `active` |
| Last Updated | `2026-04-02` |
| Generated | `manually curated` |
| ADR | `none` |
| Module | `call_flow` |
| Source | `lib/contracts/call_flow/pending_follow_up_repository_contract.dart` |

## Purpose

Persist pending follow-up metadata so the coordinator can reconcile scheduled,
tapped, missed, and cancelled stages after app restart.

## Contract Interface

```dart
abstract class PendingFollowUpRepositoryContract {
  Future<List<PendingFollowUp>> getAllPendingFollowUps();
  Future<void> savePendingFollowUp(PendingFollowUp pendingFollowUp);
  Future<void> deletePendingFollowUp({
    required String sessionId,
    required int stage,
  });
  Future<void> deleteBySession(String sessionId);
}
```

## Rules

- stores pending follow-up metadata only
- does not persist full active call state
- does not store session history or user-identifiable data

## Implementation

- `lib/repositories/pending_follow_up_repository.dart`

## Tests

- `test/unit/repositories/pending_follow_up_repository_test.dart`
