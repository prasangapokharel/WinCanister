import { getLotteryActor } from "./actor"
import { optPrincipal, unwrapOpt, unwrapResult } from "./format"
import type {
  DepositFeedItem,
  HealthResponse,
  PayoutDetails,
  PayoutEntry,
  PublicCurrentRound,
  PublicStatistics,
  RoundResult,
  WinnerHistoryEntry,
} from "./types"

type RawPayoutEntry = {
  accountHex: string
  amount: bigint
  txId: bigint
  paid: boolean
}

type RawPayoutDetails = {
  roundId: bigint
  winner1: unknown
  winner2: unknown
  winner3: unknown
  treasury: unknown
}

type RawRoundResult = {
  roundId: bigint
  totalPool: bigint
  treasuryFee: bigint
  prizePool: bigint
  status: string
  winner1: unknown
  winner2: unknown
  winner3: unknown
}

type RawWinnerHistoryEntry = {
  roundId: bigint
  winner1: unknown
  winner2: unknown
  winner3: unknown
}

function mapPayoutEntry(value: unknown): PayoutEntry | null {
  const entry = unwrapOpt<RawPayoutEntry>(value)
  if (!entry) {
    return null
  }
  return {
    accountHex: entry.accountHex,
    amount: entry.amount,
    txId: entry.txId,
    paid: entry.paid,
  }
}

export async function fetchCurrentRound(): Promise<PublicCurrentRound | null> {
  const actor = await getLotteryActor()
  const round = unwrapOpt<PublicCurrentRound>(await actor.getCurrentRound())
  if (!round) {
    return null
  }
  return {
    roundId: round.roundId,
    startTime: round.startTime,
    endTime: round.endTime,
    participants: round.participants,
    poolICP: round.poolICP,
    status: round.status,
  }
}

export async function fetchStatistics(): Promise<PublicStatistics> {
  const actor = await getLotteryActor()
  const stats = unwrapResult<PublicStatistics>(await actor.getStatistics())
  return {
    totalRounds: stats.totalRounds,
    totalParticipants: stats.totalParticipants,
    totalPoolCollected: stats.totalPoolCollected,
    totalPaidOut: stats.totalPaidOut,
    totalTreasuryRevenue: stats.totalTreasuryRevenue,
  }
}

export async function fetchRoundHistory(): Promise<bigint[]> {
  const actor = await getLotteryActor()
  return unwrapResult<bigint[]>(await actor.getRoundHistory())
}

export async function fetchRoundResult(roundId: bigint): Promise<RoundResult | null> {
  const actor = await getLotteryActor()
  const result = unwrapOpt<RawRoundResult>(await actor.getRoundResult(roundId))
  if (!result) {
    return null
  }
  return {
    roundId: result.roundId,
    totalPool: result.totalPool,
    treasuryFee: result.treasuryFee,
    prizePool: result.prizePool,
    status: result.status,
    winner1: optPrincipal(result.winner1),
    winner2: optPrincipal(result.winner2),
    winner3: optPrincipal(result.winner3),
  }
}

export async function fetchPayouts(roundId: bigint): Promise<PayoutDetails | null> {
  const actor = await getLotteryActor()
  const payouts = unwrapOpt<RawPayoutDetails>(await actor.getPayouts(roundId))
  if (!payouts) {
    return null
  }
  return {
    roundId: payouts.roundId,
    winner1: mapPayoutEntry(payouts.winner1),
    winner2: mapPayoutEntry(payouts.winner2),
    winner3: mapPayoutEntry(payouts.winner3),
    treasury: mapPayoutEntry(payouts.treasury),
  }
}

export async function fetchWinnerHistory(): Promise<WinnerHistoryEntry[]> {
  const actor = await getLotteryActor()
  const history = unwrapResult<RawWinnerHistoryEntry[]>(
    await actor.getWinnerHistory()
  )
  return history.map((entry) => ({
    roundId: entry.roundId,
    winner1: optPrincipal(entry.winner1),
    winner2: optPrincipal(entry.winner2),
    winner3: optPrincipal(entry.winner3),
  }))
}

export async function fetchHealth(): Promise<HealthResponse> {
  const actor = await getLotteryActor()
  return unwrapResult<HealthResponse>(await actor.health())
}

export async function fetchCanisterIcpBalance(): Promise<bigint> {
  const actor = await getLotteryActor()
  return unwrapResult<bigint>(await actor.getCanisterIcpBalance())
}

export async function fetchUnclaimedIncomingTotal(): Promise<bigint> {
  const actor = await getLotteryActor()
  return unwrapResult<bigint>(await actor.getUnclaimedIncomingTotal())
}

export function buildDepositFeedItem(
  previousParticipants: bigint,
  current: PublicCurrentRound
): DepositFeedItem | null {
  if (current.participants <= previousParticipants) {
    return null
  }
  const delta = current.participants - previousParticipants
  return {
    id: `${current.roundId.toString()}-${current.participants.toString()}-${Date.now()}`,
    label: `${delta.toString()} new ${delta === BigInt(1) ? "entry" : "entries"}`,
    amountIcp: `${delta.toString()} ICP min.`,
    timestamp: Date.now(),
  }
}
