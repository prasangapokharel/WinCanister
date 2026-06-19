# Motoko Code Guide

Architecture and development flow for production ICP canisters (Motoko 1.7, mops, enhanced migration, layered design). Reusable for **any** backend — not tied to one product.

## Read in order

| # | Document | When to read |
|---|----------|--------------|
| 1 | [architecture.md](./architecture.md) | Folder layout, layer rules, request flow |
| 2 | [feature-workflow.md](./feature-workflow.md) | Adding a new feature end-to-end |
| 3 | [main-and-migrations.md](./main-and-migrations.md) | `main.mo`, timers, enhanced migration |
| 4 | [testing.md](./testing.md) | Test layout, harness, required scenarios |
| 5 | [conventions.md](./conventions.md) | Naming, errors, security, API versioning |
| 6 | [external-canisters.md](./external-canisters.md) | Ledger clients, mocks, actor aliases |
| 7 | [checklist.md](./checklist.md) | Code review, bootstrap, common mistakes |

## Golden rule

```text
Controllers → Services → Repositories → Storage
```

Data flows **down**. Dependencies never flow **up**.

## Related

- [../deploy-guide/README.md](../deploy-guide/README.md) — build & ship
- [../README.md](../README.md) — motok docs index
- [../../readme](../../readme) — short folder tree
