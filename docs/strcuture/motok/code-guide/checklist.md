# Checklist — Review, Bootstrap & Common Mistakes

## Code review checklist

- [ ] Single responsibility per file
- [ ] No business logic in controllers or `main.mo`
- [ ] No storage access outside repositories
- [ ] Validators on all user input
- [ ] `Result` instead of trap for expected errors
- [ ] Migration for every new persistent field
- [ ] Tests in `backend/testing/<name>/` (local)
- [ ] Naming matches conventions
- [ ] `main.mo` under ~200 lines

## New project bootstrap

1. Copy folder structure (`api`, `services`, `repositories`, `storage`, `migrations`)
2. Copy `mops.toml`, `scripts/build-lottery.sh`, `run-tests.sh`, `packtool.sh`
3. Rename canister in `mops.toml` + `dfx.json`
4. Write `Init.mo` migration matching actor fields
5. Implement `HealthController` + `health` query first
6. Add **one vertical slice** before expanding
7. Add frontend after `health` + one query work locally

## Common mistakes

| Mistake | Fix |
|---------|-----|
| Business logic in controller | Move to service |
| `stable var` with enhanced migration | Use migration chain + `var` without initializer |
| `transient var x : Service` without init | Build on demand |
| `dfx build` for production wasm | Use `scripts/build-lottery.sh` (moc 1.7) |
| Direct `StableMap.put` in service | Go through repository |
| Breaking v1 API | Add `api/v2/`, keep v1 |
| Changing stable Entry/Winner types | Add parallel store + migration |
| No upgrade tests | Add `UpgradeTests.test.mo` |
| Forgot `--wasm-memory-persistence keep` on upgrade | Add flag on `dfx canister install --mode upgrade` |
