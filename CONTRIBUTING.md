# Contributing to WinCanister

Thank you for helping improve WinCanister! This project is open source and community contributions are encouraged.

## Getting started

1. Fork [prasangapokharel/WinCanister](https://github.com/prasangapokharel/WinCanister)
2. Clone your fork and create a branch from `main`
3. Make your changes
4. Run the checks below before opening a PR

## Development checks

### Frontend (Next.js)

```bash
cd frontend
npm ci
npm run typecheck
npm run lint
npm run build
```

### Motoko canister

If you change `src/`, build locally before submitting:

```bash
DFX_NETWORK=ic bash scripts/build-lottery.sh
```

## Code standards

### Motoko

Follow the layered architecture in the repo:

- Controllers stay thin — no business logic or direct storage access
- Services own business rules
- Repositories own persistence
- Use `Result` types for expected errors; never trap for user-facing failures
- Winner selection must use ICP `raw_rand()` — no predictable seeds

### Frontend

- Keep UI components focused and readable
- Brand name is **WinCanister** (see `frontend/lib/site.ts`)
- Do not commit secrets or `.env.local`

## Pull requests

- Keep PRs focused — one concern per PR when possible
- Describe **what** changed and **why**
- Link related issues if applicable
- Ensure CI passes (GitHub Actions runs on PRs)

## Reporting issues

When filing a bug, include:

- Steps to reproduce
- Expected vs actual behavior
- Network (local / IC mainnet)
- Canister ID if relevant

## License

By contributing, you agree that your contributions will be licensed under the [Apache-2.0 License](LICENSE).
