# Call Session Repository Contract

| Field | Value |
|---|---|
| Version | `v0.0` |
| Status | `deprecated` |
| Last Updated | `2026-04-02` |
| Generated | `manually curated` |
| ADR | `superseded by app-state and coordinator architecture` |
| Module | `legacy` |
| Source | `none` |

## Purpose

Preserve the historical rationale for removing the old call-session repository
shape from the active architecture.

## Status

This contract is intentionally not implemented in the current architecture.

## Reason

The repo rules require:

- no session history persistence
- no active flow persistence
- only minimal app-state storage for non-sensitive preferences

Call flow is therefore in-memory only, and persistent state is limited to
`AppStateContract` and language-pack metadata, plus pending follow-up
reconciliation state.

## Current Replacements

- `lib/contracts/app/app_state_contract.dart`
- `lib/contracts/call_flow/fake_call_timing_contract.dart`
- `lib/contracts/audio/audio_language_pack_repository_contract.dart`
- `lib/contracts/call_flow/pending_follow_up_repository_contract.dart`
