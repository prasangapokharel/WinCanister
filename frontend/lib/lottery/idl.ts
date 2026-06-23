// Candid passes a runtime IDL namespace; typing it strictly breaks Actor.createActor.
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const idlFactory = ({ IDL }: { IDL: any }) => {
  const WinnerResponse = IDL.Record({
    paid: IDL.Bool,
    participant: IDL.Principal,
    position: IDL.Nat,
    prizeAmount: IDL.Nat,
    roundId: IDL.Nat,
  })

  const WinnerHistoryEntry = IDL.Record({
    roundId: IDL.Nat,
    winner1: IDL.Opt(IDL.Principal),
    winner2: IDL.Opt(IDL.Principal),
    winner3: IDL.Opt(IDL.Principal),
  })

  const PublicStatisticsResponse = IDL.Record({
    totalPaidOut: IDL.Nat,
    totalParticipants: IDL.Nat,
    totalPoolCollected: IDL.Nat,
    totalRounds: IDL.Nat,
    totalTreasuryRevenue: IDL.Nat,
  })

  const PublicCurrentRoundResponse = IDL.Record({
    endTime: IDL.Int,
    participants: IDL.Nat,
    poolICP: IDL.Nat,
    roundId: IDL.Nat,
    startTime: IDL.Int,
    status: IDL.Text,
  })

  const PayoutEntryResponse = IDL.Record({
    amount: IDL.Nat,
    paid: IDL.Bool,
    accountHex: IDL.Text,
    txId: IDL.Nat,
  })

  const PayoutDetailsResponse = IDL.Record({
    roundId: IDL.Nat,
    treasury: IDL.Opt(PayoutEntryResponse),
    winner1: IDL.Opt(PayoutEntryResponse),
    winner2: IDL.Opt(PayoutEntryResponse),
    winner3: IDL.Opt(PayoutEntryResponse),
  })

  const RoundResultResponse = IDL.Record({
    prizePool: IDL.Nat,
    roundId: IDL.Nat,
    status: IDL.Text,
    totalPool: IDL.Nat,
    treasuryFee: IDL.Nat,
    winner1: IDL.Opt(IDL.Principal),
    winner2: IDL.Opt(IDL.Principal),
    winner3: IDL.Opt(IDL.Principal),
  })

  const RecentEntryResponse = IDL.Record({
    accountHex: IDL.Text,
    amountE8s: IDL.Nat,
    timestampNanos: IDL.Int,
  })

  const HealthResponse = IDL.Record({
    status: IDL.Text,
    version: IDL.Text,
  })

  const ResultNat = IDL.Variant({ err: IDL.Text, ok: IDL.Nat })
  const ResultText = IDL.Variant({ err: IDL.Text, ok: IDL.Text })

  return IDL.Service({
    getConfig: IDL.Func(
      [],
      [
        IDL.Record({
          adminPrincipal: IDL.Principal,
          treasuryPrincipal: IDL.Principal,
        }),
      ],
      ["query"]
    ),
    getCurrentRound: IDL.Func(
      [],
      [IDL.Opt(PublicCurrentRoundResponse)],
      ["query"]
    ),
    getStatistics: IDL.Func([], [PublicStatisticsResponse], ["query"]),
    getPayouts: IDL.Func([IDL.Nat], [IDL.Opt(PayoutDetailsResponse)], ["query"]),
    getRoundHistory: IDL.Func([], [IDL.Vec(IDL.Nat)], ["query"]),
    getRoundResult: IDL.Func([IDL.Nat], [IDL.Opt(RoundResultResponse)], ["query"]),
    getRecentEntries: IDL.Func([], [IDL.Vec(RecentEntryResponse)], ["query"]),
    getWinnerHistory: IDL.Func([], [IDL.Vec(WinnerHistoryEntry)], ["query"]),
    getWinnersByRound: IDL.Func([IDL.Nat], [IDL.Vec(WinnerResponse)], ["query"]),
    getTreasuryTotalTransferred: IDL.Func([], [IDL.Nat], ["query"]),
    health: IDL.Func([], [HealthResponse], ["query"]),
    initialize: IDL.Func([], [], []),
    joinRound: IDL.Func([IDL.Nat], [ResultNat], []),
    processIncomingDeposits: IDL.Func([], [IDL.Nat], []),
    getCanisterIcpBalance: IDL.Func([], [IDL.Nat], []),
    getUnclaimedIncomingTotal: IDL.Func([], [IDL.Nat], ["query"]),
    syncDepositWatch: IDL.Func([], [IDL.Nat], []),
    processExpiredRound: IDL.Func([], [ResultText], []),
    updateTreasury: IDL.Func([IDL.Principal], [ResultText], []),
  })
}