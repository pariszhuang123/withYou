# Documentation Guide

## Purpose

Make the repo documentation navigable by separating active code contracts from
supporting specifications and deprecated records.

## Read Order

1. Read [system/architecture.md](system/architecture.md) for layers, DI, and
   storage strategy.
2. Read [system/contract-structure.md](system/contract-structure.md) for
   contract placement, module barrels, and doc mapping.
3. Read the specific active contract under `docs/contracts/{module}/` before
   changing a service, repository, bloc, or platform bridge.
4. Read the relevant supporting spec if the change touches UI, testing, CI, or
   content/data shape.
5. Read `docs/legacy/` only when you are replacing or auditing superseded
   architecture.

## Layout

| Folder | Purpose |
|---|---|
| `docs/contracts/` | Active code-backed contracts only |
| `docs/system/` | Repo-wide architecture and contract-structure rules |
| `docs/models/` | Content and persistence models |
| `docs/ui/` | Design system and UI rules |
| `docs/quality/` | Testing strategy and CI/CD |
| `docs/legacy/` | Deprecated or historical architecture notes |

## Rules

- Anything under `docs/contracts/` must map to a real contract in
  `lib/contracts/{module}/`.
- Supporting specs do not define a Dart interface directly.
- Legacy docs must not be treated as active contracts.
