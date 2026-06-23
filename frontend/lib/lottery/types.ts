export type RoundStatus =
  | "OPEN"
  | "CLOSED"
  | "DRAWING"
  | "PAYING"
  | "ARCHIVING"
  | "COMPLETED"
  | string

export interface PublicCurrentRound {
  roundId: bigint
  startTime: bigint
  endTime: bigint
  participants: bigint
  poolICP: bigint
  status: string
}

export interface PublicStatistics {
  totalRounds: bigint
  totalParticipants: bigint
  totalPoolCollected: bigint
  totalPaidOut: bigint
  totalTreasuryRevenue: bigint
}

export interface PayoutEntry {
  accountHex: string
  amount: bigint
  txId: bigint
  paid: boolean
}

export interface PayoutDetails {
  roundId: bigint
  winner1: PayoutEntry | null
  winner2: PayoutEntry | null
  winner3: PayoutEntry | null
  treasury: PayoutEntry | null
}

export interface RoundResult {
  roundId: bigint
  totalPool: bigint
  treasuryFee: bigint
  prizePool: bigint
  status: string
  winner1: string | null
  winner2: string | null
  winner3: string | null
}

export interface WinnerHistoryEntry {
  roundId: bigint
  winner1: string | null
  winner2: string | null
  winner3: string | null
}

export interface Winner {
  roundId: bigint
  position: bigint
  participant: string
  prizeAmount: bigint
  paid: boolean
}

export interface HealthResponse {
  status: string
  version: string
}

export interface RecentEntry {
  accountHex: string
  amountE8s: bigint
  timestampNanos: bigint
}

export interface DepositFeedItem {
  id: string
  label: string
  amountIcp: string
  // Real deposit time in ms (derived from the ledger timestamp), for "X ago".
  timestamp: number
}

export interface DashboardData {
  currentRound: PublicCurrentRound | null
  statistics: PublicStatistics | null
  roundHistory: bigint[]
  roundResults: Map<string, RoundResult>
  payoutsByRound: Map<string, PayoutDetails>
  winnerHistory: WinnerHistoryEntry[]
  health: HealthResponse | null
  depositFeed: DepositFeedItem[]
  lastUpdated: number | null
  error: string | null
  loading: boolean
}
