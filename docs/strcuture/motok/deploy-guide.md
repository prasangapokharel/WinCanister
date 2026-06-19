# Motoko Deploy Guide — Local, Mainnet & Upgrades

End-to-end guide for building, installing, verifying, and upgrading Motoko canisters that use **moc 1.7**, **enhanced migration**, and **mops**. Generic for any project using this repo's script pattern.

---

## 1. Prerequisites

| Requirement | Check |
|-------------|-------|
| `dfx` installed | `dfx --version` |
| mops + moc 1.7 | `mops toolchain bin moc` or `~/.cache/mops/moc/1.7.0/moc` |
| Identity with ICP (mainnet) | `dfx ledger balance` |
| Controller access to target canister | `dfx canister info <id> --network ic` |

### Important build rule

**Do not use `dfx build <canister>` for production wasm** when enhanced migration is enabled. The bundled dfx moc may be older and lack `--enhanced-migration`.

Always use:

```bash
bash scripts/build-lottery.sh
```

Output: `.mops/.build/<canister>.wasm`

---

## 2. Project config overview

### mops.toml

```toml
[toolchain]
moc = "1.7.0"

[moc]
args = ["--default-persistent-actors"]

[canisters.my_canister]
main = "src/main.mo"
args = ["--actor-alias", "external_canister", "<canister-id>"]

[canisters.my_canister.migrations]
chain = "src/migrations"
```

### dfx.json

```json
{
  "canisters": {
    "my_canister": {
      "main": "src/main.mo",
      "type": "motoko",
      "remote": { "id": { "ic": "<MAINNET_CANISTER_ID>" } }
    }
  },
  "networks": {
    "ic": { "providers": ["https://icp0.io"], "type": "persistent" }
  },
  "defaults": {
    "build": {
      "args": "--default-persistent-actors",
      "packtool": "./scripts/packtool.sh"
    }
  }
}
```

### Canister IDs file

`.dfx/ic/canister_ids.json` — maps logical name → mainnet ID for scripts and frontend.

---

## 3. Build flow

```text
scripts/packtool.sh     → moc package paths (mops sources + core)
        │
        ▼
moc 1.7.0 -c
  --package src ./src
  --enhanced-migration src/migrations
  --default-persistent-actors
  --actor-idl .dfx/local/canisters/idl
  --actor-alias <name> <id>
  -o .mops/.build/my_canister.wasm
  --idl
```

### Commands

```bash
# Build wasm
bash scripts/build-lottery.sh

# Run all tests first
bash scripts/run-tests.sh
```

### Build dependencies (actor IDL)

If your canister calls external canisters (e.g. ICRC ledger), build their `.did` once locally:

```bash
dfx build icrc1_ledger
```

The build script copies the service DID into `.dfx/local/canisters/idl/` for moc `--actor-idl`.

---

## 4. Local development deploy

```bash
# Start local replica
dfx start --background --clean

# Deploy all canisters locally
dfx deploy

# Call initialize (if your actor has one)
dfx canister call my_canister initialize

# Smoke test
dfx canister call my_canister health --query
```

### Local frontend env

```env
NEXT_PUBLIC_MY_CANISTER_ID=<local-id-from-.dfx/local/canister_ids.json>
NEXT_PUBLIC_IC_HOST=http://127.0.0.1:4943
NEXT_PUBLIC_DFX_NETWORK=local
```

For local host, the agent must call `agent.fetchRootKey()` (handled when `IS_LOCAL` is true in frontend config).

---

## 5. Mainnet deploy (fresh canister)

### Phase A — Prepare canister on IC

1. Create empty canister in [wallet.ic0.app](https://wallet.ic0.app) or via `dfx ledger create-canister`
2. Fund with cycles (install + future upgrades)
3. Note the canister ID (e.g. `xxxx-xxxxx-...-cai`)
4. Update:
   - `dfx.json` → `remote.id.ic`
   - `.dfx/ic/canister_ids.json`
   - deploy script `CANISTER_ID`
   - frontend `.env.local`

### Phase B — Controller access

Your `dfx identity` principal **must be a controller** of the target canister.

```bash
dfx identity get-principal
dfx canister info <CANISTER_ID> --network ic
```

If not listed → wallet.ic0.app → Canister → **Add Controller** → paste principal.

You can add a temporary deploy identity and remove it after install.

### Phase C — Install wasm

```bash
bash scripts/deploy-mainnet.sh
```

What the script does:

```text
1. bash scripts/build-lottery.sh
2. Verify caller is controller
3. dfx canister install <id> --network ic --wasm .mops/.build/*.wasm --mode install
4. dfx canister call <id> initialize
5. Query health + config smoke tests
```

### Phase D — Verify

```bash
bash scripts/verify-mainnet.sh
```

Expected:

- `Module hash:` is not `None`
- `health` returns `{ status = "healthy"; version = "..." }`
- Core query endpoints respond without trap

---

## 6. Mainnet upgrade (existing wasm)

When code changes but canister ID stays the same:

### Before upgrade

1. Add new migration file in `src/migrations/` if persistent fields changed
2. Run tests: `bash scripts/run-tests.sh`
3. Build: `bash scripts/build-lottery.sh`
4. Test migration chain: `mops check --fix` (recommended)

### Upgrade command

```bash
dfx canister install <CANISTER_ID> \
  --network ic \
  --wasm .mops/.build/my_canister.wasm \
  --mode upgrade
```

Enhanced migration runs only **new** migration files since last deploy.

### After upgrade

```bash
bash scripts/verify-mainnet.sh
# Manually test critical flows (create, pay, query history)
```

**If migration traps:** canister stays on previous wasm. Fix migration, rebuild, retry.

---

## 7. Deploy decision tree

```text
                    ┌─────────────────┐
                    │  Code changed?  │
                    └────────┬────────┘
                             │
              ┌──────────────┴──────────────┐
              ▼                             ▼
      Persistent fields changed?      Logic-only change
              │                             │
              ▼                             ▼
      Add migration file              Rebuild wasm
              │                             │
              └──────────────┬──────────────┘
                             ▼
                    bash scripts/run-tests.sh
                             │
                             ▼
                    bash scripts/build-lottery.sh
                             │
              ┌──────────────┴──────────────┐
              ▼                             ▼
      Module hash = None?            Module hash exists?
      (fresh canister)               (upgrade)
              │                             │
              ▼                             ▼
      --mode install                --mode upgrade
      + initialize()                (no re-init)
```

---

## 8. Frontend connection (any project)

### Environment variables

```env
NEXT_PUBLIC_<NAME>_CANISTER_ID=<mainnet-or-local-id>
NEXT_PUBLIC_IC_HOST=https://icp0.io
NEXT_PUBLIC_DFX_NETWORK=ic
```

### Agent v3 return values

`@dfinity/agent` v3 returns Candid values **directly**, not wrapped in `[value]`.

Use unwrap helpers:

```typescript
export function unwrapResult<T>(result: unknown): T {
  if (Array.isArray(result) && result.length === 1) {
    return result[0] as T
  }
  return result as T
}

export function unwrapOpt<T>(result: unknown): T | null {
  if (result === null || result === undefined) return null
  if (!Array.isArray(result)) return result as T
  if (result.length === 0) return null
  if (result.length === 1) {
    const inner = result[0]
    return inner === null || inner === undefined ? null : (inner as T)
  }
  return result as T
}
```

**Wrong:** `const [health] = await actor.health()` → `is not iterable`

**Right:** `const health = unwrapResult(await actor.health())`

### IDL file

Keep `frontend/lib/<project>/idl.ts` in sync with deployed candid (from build `--idl` output or `dfx generate`).

---

## 9. Scripts reference

| Script | Purpose |
|--------|---------|
| `scripts/build-lottery.sh` | moc 1.7 wasm + candid |
| `scripts/run-tests.sh` | All `backend/testing/**/*.test.mo` |
| `scripts/deploy-mainnet.sh` | Install + initialize on IC |
| `scripts/verify-mainnet.sh` | Post-deploy health queries |
| `scripts/packtool.sh` | mops sources for moc `-p` flags |

### Customize for a new project

1. Rename `lottery` → your canister name in build output path
2. Set `CANISTER_ID` in deploy/verify scripts
3. Update smoke-test queries in deploy script to match your API

---

## 10. Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `IC0512` not a controller | dfx identity not in controller list | Add principal in wallet.ic0.app |
| `missing initializer _` on install | `transient var` without initializer in enhanced migration actor | Build services on demand; don't leave uninitialized transient class fields |
| `dfx build` migration errors | dfx moc too old | Use `scripts/build-lottery.sh` with moc 1.7 |
| `Module hash: None` | Wasm never installed | Run `dfx canister install` |
| Frontend `is not iterable` | Agent v3 unwrapping | Use `unwrapResult` / `unwrapOpt` |
| Upgrade reverts | Migration trap | Check migration input/output types match chain |
| Candid mismatch | Stale IDL | Regenerate from wasm build `--idl` |
| Local agent rejects cert | Missing root key | `agent.fetchRootKey()` on local |

---

## 11. Security after deploy

1. **Remove temporary deploy controller** from wallet if you added one only for install
2. Keep **one primary controller** (your Internet Identity principal)
3. Never commit `.env` secrets or pem files
4. Verify treasury/admin principals in `getConfig` after first deploy
5. Monitor cycles: `dfx canister status <id> --network ic`

---

## 12. Release checklist

```text
[ ] Tests pass (bash scripts/run-tests.sh)
[ ] Wasm builds (bash scripts/build-lottery.sh)
[ ] Migration chain valid (mops check --fix)
[ ] Controller principal confirmed
[ ] Cycles sufficient on canister
[ ] Install or upgrade executed
[ ] initialize() called (fresh install only)
[ ] verify script passes
[ ] Frontend .env.local points to correct canister
[ ] Frontend health + one write path tested
[ ] Temporary controllers removed
```

---

## 13. Typical session (mainnet first deploy)

```bash
cd /path/to/project

# 1. Quality gate
bash scripts/run-tests.sh

# 2. Build
bash scripts/build-lottery.sh

# 3. Confirm identity + controllers
dfx identity get-principal
dfx canister info <CANISTER_ID> --network ic

# 4. Deploy
bash scripts/deploy-mainnet.sh

# 5. Verify
bash scripts/verify-mainnet.sh

# 6. Frontend
cd frontend && npm run dev
# Open http://localhost:3000 — health should show synced
```

---

## Related

- [code-guide.md](./code-guide.md) — how to structure and write code
- [README.md](./README.md) — documentation index
