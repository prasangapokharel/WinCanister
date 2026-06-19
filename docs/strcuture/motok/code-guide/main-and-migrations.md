# main.mo & Enhanced Migration

## Persistent actor fields

```motoko
actor MyCanister {
  var storage : StableStorage.Store;   // NO initializer
  var isInitialized : Bool;            // NO initializer
};
```

**Never use** `preupgrade` / `postupgrade` / `stable` with enhanced migration.

**Never:** `transient var service : Service;` without initializer — traps on install.

## Wiring pattern

```motoko
func buildService() : MyService.Service {
  MyService.Service(
    OrderRepository.Repository(storage.orders),
    ConfigRepository.Repository(storage.config),
  );
};

func ensureInitialized<system>() {
  if (not isInitialized) {
    buildService().initialize();
    scheduleTimers<system>();
    isInitialized := true;
  };
};

public shared (msg) func doAction(input : Nat) : async Result.Result<Nat, Text> {
  ensureInitialized<system>();
  await MyController.Controller(buildService()).doAction(msg.caller, input);
};
```

## Timers

Only `<system>` functions may start timers. Call from `ensureInitialized<system>()`.

WinCanister example:

- Deposit watch: every **30s** → `processIncomingDeposits`
- Round check: every **60s** → `processExpiredRound`

## mops.toml config

```toml
[moc]
args = ["--default-persistent-actors"]

[canisters.lottery]
main = "src/main.mo"

[canisters.lottery.migrations]
chain = "src/migrations"
```

## Migration rules

| In input and output | Transform field |
| Output only | Add field |
| Input only | Remove field |
| In neither | Unchanged |

Files run in **lexicographic order** — prefix `YYYYMMDD_HHMMSS_`.

| Event | Behavior |
|-------|----------|
| Fresh install | All migrations run |
| Upgrade | Only **new** migrations run |
| Failed migration | Upgrade aborted, old wasm kept |

Verify: `mops check --fix`

## Breaking stable types

Do **not** change existing `Entry` / `Winner` model shapes in place. Add parallel stores (e.g. `addressEntries`) + migration instead.
