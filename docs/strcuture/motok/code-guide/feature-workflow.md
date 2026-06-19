# Feature Workflow — Add a New Capability

Example: add `getOrderHistory` to any canister. Follow **every** step in order.

## Step 1 — Model

`src/models/Order.mo`

```motoko
module {
  public type Order = {
    id : Nat;
    buyer : Principal;
    amount : Nat;
    status : { #pending; #paid; #shipped };
  };
};
```

## Step 2 — Storage (new collection)

`src/storage/StableOrderStore.mo` — `Store`, `StableData`, `empty()`, `save`, `findById`.

Register in `StableStorage.mo` if using a central aggregate store.

## Step 3 — Migration (persistent state change)

`src/migrations/20250621_120000_AddOrders.mo`

```motoko
import StableStorage "../storage/StableStorage";

module {
  public func migration(old : { storage : StableStorage.Store }) : { storage : StableStorage.Store } {
    { storage = old.storage };
  };
};
```

**First migration ever** must initialize **all** actor persistent fields:

```motoko
public func migration(_ : {}) : { storage : StableStorage.Store; isInitialized : Bool } {
  { storage = StableStorage.empty(); isInitialized = false };
};
```

## Step 4 — Repository

`src/repositories/OrderRepository.mo` — data access only.

## Step 5 — Service

`src/services/OrderService.mo` — validation, rules, orchestration.

## Step 6 — DTO

`src/dto/OrderHistoryResponse.mo` — public shape ≠ internal model.

## Step 7 — Controller

`src/api/v1/OrderController.mo` — thin, forwards to service.

## Step 8 — Expose in main.mo

```motoko
public shared (msg) func getOrderHistory() : async [OrderHistoryResponse.OrderHistoryEntry] {
  ensureInitialized<system>();
  OrderController.Controller(buildService()).getHistory(msg.caller);
};
```

## Step 9 — Tests

`backend/testing/order/OrderTests.test.mo` (local folder)

```bash
bash scripts/run-tests.sh
```

## Vertical slice rule

Ship **one feature end-to-end** (model → API → test) before adding the next. Do not add storage without migration + test.
