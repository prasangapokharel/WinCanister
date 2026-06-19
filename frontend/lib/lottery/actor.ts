import { Actor, HttpAgent, type Identity } from "@dfinity/agent"

import { IC_HOST, IS_LOCAL, LOTTERY_CANISTER_ID } from "./config"
import { idlFactory } from "./idl"

type PublicCurrentRound = {
  roundId: bigint
  startTime: bigint
  endTime: bigint
  participants: bigint
  poolICP: bigint
  status: string
}

type PublicStatistics = {
  totalRounds: bigint
  totalParticipants: bigint
  totalPoolCollected: bigint
  totalPaidOut: bigint
  totalTreasuryRevenue: bigint
}

type PayoutDetails = {
  roundId: bigint
  winner1: unknown
  winner2: unknown
  winner3: unknown
  treasury: unknown
}

type RoundResult = {
  roundId: bigint
  totalPool: bigint
  treasuryFee: bigint
  prizePool: bigint
  status: string
  winner1: unknown
  winner2: unknown
  winner3: unknown
}

type WinnerHistoryEntry = {
  roundId: bigint
  winner1: unknown
  winner2: unknown
  winner3: unknown
}

type HealthResponse = {
  status: string
  version: string
}

type ResultNat = { ok: bigint } | { err: string }

export interface LotteryService {
  getCurrentRound: () => Promise<PublicCurrentRound | null | [PublicCurrentRound | null]>
  getStatistics: () => Promise<PublicStatistics | [PublicStatistics]>
  getPayouts: (roundId: bigint) => Promise<PayoutDetails | null | [PayoutDetails | null]>
  getRoundHistory: () => Promise<bigint[] | [bigint[]]>
  getRoundResult: (roundId: bigint) => Promise<RoundResult | null | [RoundResult | null]>
  getWinnerHistory: () => Promise<WinnerHistoryEntry[] | [WinnerHistoryEntry[]]>
  health: () => Promise<HealthResponse | [HealthResponse]>
  claimDeposit: () => Promise<ResultNat | [ResultNat]>
  getCanisterIcpBalance: () => Promise<bigint | [bigint]>
  getUnclaimedIncomingTotal: () => Promise<bigint | [bigint]>
  syncDepositWatch: () => Promise<bigint | [bigint]>
}

let anonymousActorPromise: Promise<LotteryService> | null = null

export function getLotteryActor(): Promise<LotteryService> {
  if (!anonymousActorPromise) {
    anonymousActorPromise = createLotteryActor()
  }
  return anonymousActorPromise
}

export async function getAuthenticatedLotteryActor(
  identity: Identity
): Promise<LotteryService> {
  return createLotteryActor(identity)
}

async function createLotteryActor(identity?: Identity): Promise<LotteryService> {
  const agent = new HttpAgent({ host: IC_HOST, identity })
  if (IS_LOCAL) {
    await agent.fetchRootKey()
  }
  return Actor.createActor<LotteryService>(idlFactory, {
    agent,
    canisterId: LOTTERY_CANISTER_ID,
  })
}

export function resetLotteryActor() {
  anonymousActorPromise = null
}
