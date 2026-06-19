# Conventions, Errors, Security & Versioning

## Naming

| Kind | Style | Example |
|------|-------|---------|
| Files | PascalCase | `OrderService.mo` |
| Functions | camelCase verb | `createOrder`, `findById` |
| Variables | camelCase | `currentRoundId` |
| Constants | UPPER_SNAKE | `MIN_ENTRY_AMOUNT` |
| API folder | versioned | `api/v1/` |

## Error handling

Use `Result.Result<T, Text>` for expected failures.

```motoko
// Good
if (amount < MIN_AMOUNT) { return #err("amount_too_low"); };

// Bad — traps on user input
assert(amount >= MIN_AMOUNT);
```

Log meaningful events only: `round_created`, `entry_accepted`, `winners_drawn` — not every read.

## Security checklist

- [ ] Use `msg.caller` — never trust frontend-supplied principals
- [ ] Validate amounts, round state, duplicates in validator + service
- [ ] Admin methods check config principal
- [ ] Randomness: `raw_rand()` only — never time-based seeds
- [ ] Ledger: verify transfer results / block indices
- [ ] Every critical field survives upgrade via migration

## API versioning

Start with `api/v1/` on day one.

When breaking changes are required:

```text
api/v1/   ← keep forever
api/v2/   ← new controllers + DTOs
main.mo   ← expose both
```

Never change existing v1 response shapes in place.
