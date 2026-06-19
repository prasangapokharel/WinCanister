# Motoko Backend — System Documentation

Reusable architecture, coding flow, and deployment guides for production ICP canisters built with **Motoko 1.7**, **mops**, **enhanced migration**, and **layered design**.

These docs describe **how to build any canister** in this style — not a single product domain.

---

## Documents

| Guide | Purpose |
|-------|---------|
| [code-guide.md](./code-guide.md) | Folder layout, layer rules, request flow, how to add features, migrations, tests |
| [deploy-guide.md](./deploy-guide.md) | Build, local deploy, mainnet install, upgrade, verification, troubleshooting |

---

## Quick mental model

```text
Client / Frontend
       │
       ▼
  main.mo  ──────────── thin actor entrypoint (public API only)
       │
       ▼
  api/v1/*Controller  ─ request handling, caller forwarding
       │
       ▼
  services/*          ─ business rules, workflows, orchestration
       │
       ▼
  repositories/*      ─ data access abstraction
       │
       ▼
  storage/*           ─ stable memory implementation
```

**Golden rule:** Data flows down. Dependencies never flow up.

---

## Toolchain (this repo)

| Tool | Version / note |
|------|----------------|
| Motoko (`moc`) | 1.7.0 via mops |
| `mo:core` | 2.5.0 |
| `mo:test` | 2.1.1 |
| Persistence | Enhanced orthogonal persistence + migration chain |
| Build | `bash scripts/build-lottery.sh` (moc directly — not `dfx build` for production wasm) |
| Tests | `bash scripts/run-tests.sh` → `backend/testing/**/*.test.mo` |

---

## When to read which guide

- **Starting a new canister or feature** → [code-guide.md](./code-guide.md)
- **First deploy or upgrade to IC mainnet** → [deploy-guide.md](./deploy-guide.md)
- **Folder naming only** → [../readme](../readme) (short structure reference)

---

## Checklist before every release

- [ ] All services have tests under `backend/testing/<name>/`
- [ ] `bash scripts/run-tests.sh` passes
- [ ] `bash scripts/build-lottery.sh` produces wasm
- [ ] New persistent fields have a migration file in `src/migrations/`
- [ ] No business logic in `main.mo` or controllers
- [ ] No direct stable memory access outside `storage/`
- [ ] Public API changes are versioned under `api/v1/` (or new `v2/`)
