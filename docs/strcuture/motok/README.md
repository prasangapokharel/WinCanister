# Motoko Backend — System Documentation

Reusable architecture, coding flow, and deployment guides for production ICP canisters built with **Motoko 1.7**, **mops**, **enhanced migration**, and **layered design**.

These docs describe **how to build any canister** in this style — not a single product domain.

---

## Documentation index

### Code guide — how to write backend

| Doc | Topic |
|-----|-------|
| [code-guide/README.md](./code-guide/README.md) | Index & reading order |
| [architecture.md](./code-guide/architecture.md) | Folder layout, layers, request flow |
| [feature-workflow.md](./code-guide/feature-workflow.md) | Add a feature step-by-step |
| [main-and-migrations.md](./code-guide/main-and-migrations.md) | `main.mo`, timers, migrations |
| [testing.md](./code-guide/testing.md) | Tests, harness, scenarios |
| [conventions.md](./code-guide/conventions.md) | Naming, errors, security, versioning |
| [external-canisters.md](./code-guide/external-canisters.md) | Ledger, index, mocks |
| [checklist.md](./code-guide/checklist.md) | Review, bootstrap, mistakes |

### Deploy guide — how to ship

| Doc | Topic |
|-----|-------|
| [deploy-guide/README.md](./deploy-guide/README.md) | Index & quick commands |
| [prerequisites.md](./deploy-guide/prerequisites.md) | Tools, identity, build rule |
| [build.md](./deploy-guide/build.md) | `build-lottery.sh`, wasm output |
| [local-deploy.md](./deploy-guide/local-deploy.md) | Local replica |
| [mainnet-fresh.md](./deploy-guide/mainnet-fresh.md) | First IC install |
| [mainnet-upgrade.md](./deploy-guide/mainnet-upgrade.md) | Upgrade + memory persistence |
| [frontend-connection.md](./deploy-guide/frontend-connection.md) | Env, agent v3, Vercel |
| [scripts-reference.md](./deploy-guide/scripts-reference.md) | All scripts |
| [troubleshooting.md](./deploy-guide/troubleshooting.md) | Errors & fixes |
| [release-checklist.md](./deploy-guide/release-checklist.md) | Pre-ship checklist |

---

## Quick mental model

```text
Client / Frontend
       │
       ▼
  main.mo  ──────────── thin actor entrypoint
       │
       ▼
  api/v1/*Controller  ─ request handling
       │
       ▼
  services/*          ─ business rules
       │
       ▼
  repositories/*      ─ data access
       │
       ▼
  storage/*           ─ stable memory
```

**Golden rule:** Data flows down. Dependencies never flow up.

---

## Toolchain (this repo)

| Tool | Version / note |
|------|----------------|
| Motoko (`moc`) | 1.7.0 via mops |
| `mo:core` | 2.5.0 |
| `mo:test` | 2.1.1 |
| Build | `DFX_NETWORK=ic bash scripts/build-lottery.sh` |
| Tests | `bash scripts/run-tests.sh` (local `backend/testing/`) |
| Mainnet canister | `ulahq-iyaaa-aaaao-bbcoq-cai` |
| Live dashboard | https://win-canister.vercel.app |

---

## When to read which guide

| Goal | Start here |
|------|------------|
| New feature | [code-guide/feature-workflow.md](./code-guide/feature-workflow.md) |
| Migration / upgrade issue | [code-guide/main-and-migrations.md](./code-guide/main-and-migrations.md) |
| First mainnet deploy | [deploy-guide/mainnet-fresh.md](./deploy-guide/mainnet-fresh.md) |
| Upgrade existing canister | [deploy-guide/mainnet-upgrade.md](./deploy-guide/mainnet-upgrade.md) |
| Vercel / frontend 404 | [deploy-guide/troubleshooting.md](./deploy-guide/troubleshooting.md) |
| Short folder tree | [../readme](../readme) |

---

## Pre-release checklist

- [ ] `bash scripts/run-tests.sh` passes (local)
- [ ] `DFX_NETWORK=ic bash scripts/build-lottery.sh` succeeds
- [ ] Migration added for new persistent fields
- [ ] No business logic in `main.mo` or controllers
- [ ] No direct stable memory outside `storage/`
- [ ] API changes versioned under `api/v1/`
- [ ] Frontend IDL synced if API changed
