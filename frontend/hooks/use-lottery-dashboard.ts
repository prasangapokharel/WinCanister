"use client"

import { useCallback, useEffect, useRef, useState } from "react"

import {
  buildDepositFeed,
  fetchCurrentRound,
  fetchHealth,
  fetchPayouts,
  fetchRecentEntries,
  fetchRoundHistory,
  fetchRoundResult,
  fetchStatistics,
  fetchWinnerHistory,
} from "@/lib/lottery/api"
import { POLL_POOL_MS, TIMER_TICK_MS } from "@/lib/lottery/config"
import { SITE } from "@/lib/site"
import type {
  DashboardData,
  PayoutDetails,
  PublicCurrentRound,
  RoundResult,
} from "@/lib/lottery/types"

const EMPTY: DashboardData = {
  currentRound: null,
  statistics: null,
  roundHistory: [],
  roundResults: new Map(),
  payoutsByRound: new Map(),
  winnerHistory: [],
  health: null,
  depositFeed: [],
  lastUpdated: null,
  error: null,
  loading: true,
}

export function useLotteryDashboard() {
  const [data, setData] = useState<DashboardData>(EMPTY)
  const [tick, setTick] = useState(0)
  const inFlight = useRef(false)

  const refresh = useCallback(async () => {
    // Skip if a previous poll is still running (avoids stacking requests on
    // slow networks and duplicate canister queries).
    if (inFlight.current) {
      return
    }
    inFlight.current = true
    try {
      const [
        currentRound,
        statistics,
        roundHistory,
        winnerHistory,
        health,
        recentEntries,
      ] = await Promise.all([
        fetchCurrentRound(),
        fetchStatistics(),
        fetchRoundHistory(),
        fetchWinnerHistory(),
        fetchHealth(),
        fetchRecentEntries(),
      ])

      const depositFeed = buildDepositFeed(recentEntries)

      const historyIds = roundHistory.slice(-12).reverse()
      const roundResults = new Map<string, RoundResult>()
      const payoutsByRound = new Map<string, PayoutDetails>()

      await Promise.all(
        historyIds.map(async (roundId) => {
          const key = roundId.toString()
          const [result, payouts] = await Promise.all([
            fetchRoundResult(roundId),
            fetchPayouts(roundId),
          ])
          if (result) {
            roundResults.set(key, result)
          }
          if (payouts) {
            payoutsByRound.set(key, payouts)
          }
        })
      )

      if (currentRound && currentRound.status !== "OPEN") {
        const key = currentRound.roundId.toString()
        const [result, payouts] = await Promise.all([
          fetchRoundResult(currentRound.roundId),
          fetchPayouts(currentRound.roundId),
        ])
        if (result) {
          roundResults.set(key, result)
        }
        if (payouts) {
          payoutsByRound.set(key, payouts)
        }
      }

      setData({
        currentRound,
        statistics,
        roundHistory: historyIds,
        roundResults,
        payoutsByRound,
        winnerHistory,
        health,
        depositFeed,
        lastUpdated: Date.now(),
        error: null,
        loading: false,
      })
    } catch (error) {
      setData((prev) => ({
        ...prev,
        error:
          error instanceof Error
            ? error.message
            : `Failed to connect to ${SITE.name} canister`,
        loading: false,
        lastUpdated: Date.now(),
      }))
    } finally {
      inFlight.current = false
    }
  }, [])

  useEffect(() => {
    void refresh()
    const timer = window.setInterval(() => {
      void refresh()
    }, POLL_POOL_MS)

    return () => window.clearInterval(timer)
  }, [refresh])

  useEffect(() => {
    const timer = window.setInterval(() => {
      setTick((value) => value + 1)
    }, TIMER_TICK_MS)
    return () => window.clearInterval(timer)
  }, [])

  return { data, tick, refresh }
}

export function getCountdown(
  round: PublicCurrentRound | null,
  tick: number
): {
  hours: number
  minutes: number
  seconds: number
  milliseconds: number
  progress: number
  done: boolean
} {
  void tick
  if (!round || round.status !== "OPEN") {
    return {
      hours: 0,
      minutes: 0,
      seconds: 0,
      milliseconds: 0,
      progress: 100,
      done: true,
    }
  }

  const nowNs = BigInt(Date.now()) * BigInt(1_000_000)
  const remainingNs =
    round.endTime > nowNs ? round.endTime - nowNs : BigInt(0)
  const totalNs =
    round.endTime > round.startTime
      ? round.endTime - round.startTime
      : BigInt(86_400_000_000_000)
  const elapsedNs = totalNs > remainingNs ? totalNs - remainingNs : BigInt(0)
  const remainingMs = Number(remainingNs / BigInt(1_000_000))
  const hours = Math.floor(remainingMs / 3_600_000)
  const minutes = Math.floor((remainingMs % 3_600_000) / 60_000)
  const seconds = Math.floor((remainingMs % 60_000) / 1_000)
  const milliseconds = remainingMs % 1_000
  const progress =
    totalNs > BigInt(0)
      ? Math.min(100, Number((elapsedNs * BigInt(100)) / totalNs))
      : 0

  return {
    hours,
    minutes,
    seconds,
    milliseconds,
    progress,
    done: remainingMs <= 0,
  }
}
