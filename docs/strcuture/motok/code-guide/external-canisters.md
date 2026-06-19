# External Canisters & Ledger Clients

## Pattern

Thin client module + injectable port in service.

```motoko
public type LedgerPort = {
  transfer : (Principal, Nat) -> async Result.Result<Nat, Text>;
  transferToAccountHex : (Text, Nat, ?Blob) -> async Result.Result<Nat, Text>;
};

public class Service(ledger : LedgerPort, index : IndexPort, ...) { ... };
```

| File | Role |
|------|------|
| `ledger/LedgerClient.mo` | Production ICP ledger |
| `ledger/IcpIndexClient.mo` | Production index |
| `ledger/MockLedgerClient.mo` | Tests |
| `ledger/MockIndexClient.mo` | Tests |

`main.mo` passes real clients. Tests pass mocks via `TestHarness`.

## Actor aliases (compile-time IDs)

In `mops.toml`:

```toml
[canisters.lottery]
args = [
  "--actor-alias", "icrc1_ledger", "ryjl3-tyaaa-aaaaa-aaaba-cai",
  "--actor-alias", "icp_index", "qhbym-qaaaa-aaaaa-aaafq-cai",
]
```

Build script (`scripts/build-lottery.sh`) also passes `--actor-idl` with fetched `.did` files.

## Mainnet IDs (WinCanister)

| Canister | ID |
|----------|-----|
| ICP Ledger | `ryjl3-tyaaa-aaaaa-aaaba-cai` |
| ICP Index | `qhbym-qaaaa-aaaaa-aaafq-cai` |
| WinCanister | `ulahq-iyaaa-aaaao-bbcoq-cai` |

## Deposit flow (address-based)

1. User sends ICP to canister **account ID** (hex)
2. Timer calls `processIncomingDeposits` every 30s
3. Index returns incoming transfers
4. `DepositService` credits `AddressEntry`, marks tx processed
5. One entry per address per round

Payouts use `transferToAccountHex` back to depositor wallet.
