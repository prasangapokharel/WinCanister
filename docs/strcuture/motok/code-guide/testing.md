# Testing

## Layout

```text
backend/testing/           # Local only (gitignored in WinCanister public repo)
├── deposit/DepositTests.test.mo
├── entry/EntryTests.test.mo
├── round/RoundTests.test.mo
├── winner/WinnerTests.test.mo
├── upgrade/UpgradeTests.test.mo
└── failure/FailureTests.test.mo

src/testing/
├── TestHarness.mo         # Wired services + mocks
└── TestPrincipals.mo
```

Run all:

```bash
bash scripts/run-tests.sh
```

## Required scenarios per service

| Scenario | Why |
|----------|-----|
| Happy path | Core behavior works |
| Invalid input | Returns `#err`, no trap |
| Duplicate / idempotency | No double entry / double pay |
| Closed / wrong state | State machine guarded |
| Upgrade persistence | State survives migration |
| External failure | Ledger / index errors handled |

## Harness pattern

`src/testing/TestHarness.mo` builds:

- Isolated or in-memory storage
- Mock ledger / index / randomness
- Same service wiring as production

Tests import harness — **do not** duplicate wiring in every file.

## Example

```motoko
import { suite; test } "mo:test/async";
import { expect } "mo:test";
import TestHarness "mo:src/testing/TestHarness";

suite("Order Tests", func() : async () {
  await test("empty history", func() : async () {
    let harness = TestHarness.create(seed);
    let history = harness.orderService.getHistory(participant);
    expect.nat(history.size()).equal(0);
  });
});
```
