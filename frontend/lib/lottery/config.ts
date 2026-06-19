export const E8S_PER_ICP = BigInt(100_000_000)

export const IC_HOST =
  process.env.NEXT_PUBLIC_IC_HOST ?? "https://icp0.io"

export const LOTTERY_CANISTER_ID =
  process.env.NEXT_PUBLIC_LOTTERY_CANISTER_ID ??
  "ulahq-iyaaa-aaaao-bbcoq-cai"

export const NETWORK_LABEL =
  process.env.NEXT_PUBLIC_DFX_NETWORK === "local" ? "local" : "mainnet"

export const IS_LOCAL =
  process.env.NEXT_PUBLIC_DFX_NETWORK === "local"

export const POLL_POOL_MS = 5_000
export const POLL_DEPOSITS_MS = 5_000
export const TIMER_TICK_MS = 50
