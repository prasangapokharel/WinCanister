# WinCanister

**Decentralized 24-hour ICP lottery on the Internet Computer.**

WinCanister runs transparent daily rounds on-chain: users deposit ICP to a canister account ID, entries are credited automatically, and winners are drawn with ICP-native randomness when the timer ends. The protocol keeps **1% treasury** and pays **99%** to the top three winners (60% / 25% / 15%).

[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)

## Live

| | |
|---|---|
| **Dashboard** | [WinCanister frontend](https://github.com/prasangapokharel/WinCanister) *(deploy your own or use hosted URL)* |
| **Canister** | `ulahq-iyaaa-aaaao-bbcoq-cai` |
| **Network** | IC Mainnet |

## Features

- **Address-based deposits** — send ICP from any wallet (NNS, Plug, etc.); no wallet connect required on the UI
- **Automatic entry crediting** — canister polls the ICP index for incoming transfers
- **24h rounds** — live countdown, pool stats, and activity feed
- **Verifiable payouts** — winner addresses and ledger transaction IDs recorded on-chain
- **Upgrade-safe** — stable memory migrations for rounds, entries, winners, and treasury

## Architecture

```
Controllers → Services → Repositories → Storage
```

| Layer | Responsibility |
|---|---|
| `src/api/v1/` | Thin HTTP/Candid endpoints |
| `src/services/` | Business logic (entries, draws, deposits, payouts) |
| `src/repositories/` | Data access |
| `src/storage/` | Stable memory |
| `frontend/` | Next.js dashboard |

## Prerequisites

- [dfx](https://internetcomputer.org/docs/current/developer-docs/setup/install) ≥ 0.24
- [mops](https://mops.one/) + Motoko 1.7
- Node.js 20+

## Quick start

### 1. Clone and install

```bash
git clone git@github.com:prasangapokharel/WinCanister.git
cd WinCanister

# Frontend
cd frontend && npm ci && cp .env.example .env.local && cd ..
```

### 2. Build canister wasm

```bash
DFX_NETWORK=ic bash scripts/build-lottery.sh
```

### 3. Run frontend locally

```bash
cd frontend
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

## Frontend scripts

```bash
cd frontend
npm run dev        # development server
npm run build      # production build
npm run typecheck  # TypeScript check
npm run lint       # ESLint
```

## Mainnet deploy

```bash
DFX_NETWORK=ic bash scripts/build-lottery.sh

dfx canister install <CANISTER_ID> --network ic \
  --wasm .mops/.build/lottery.wasm --mode upgrade --wasm-memory-persistence keep

dfx canister call <CANISTER_ID> processIncomingDeposits --network ic
```

See `scripts/deploy-mainnet.sh` and `scripts/verify-mainnet.sh` for helper flows.

## Configuration

| Variable | Description |
|---|---|
| `NEXT_PUBLIC_LOTTERY_CANISTER_ID` | Lottery canister principal |
| `NEXT_PUBLIC_DFX_NETWORK` | Set to `local` for local replica |
| `NEXT_PUBLIC_IC_HOST` | IC HTTP endpoint (default `https://icp0.io`) |

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

1. Fork the repo
2. Create a feature branch (`git checkout -b feat/my-change`)
3. Run tests and frontend checks
4. Open a PR with a clear description

## Project structure

```
WinCanister/
├── src/                 # Motoko canister source
├── frontend/            # Next.js dashboard
├── scripts/             # Build, test, deploy helpers
├── dfx.json
└── mops.toml
```

## License

Apache-2.0 — see [LICENSE](LICENSE).

## Author

Built by [Prasanga Rman Pokharel](https://github.com/prasangapokharel)
