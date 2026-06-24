"use client"

import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert"
import { Skeleton } from "@/components/ui/skeleton"
import { CountdownTimer } from "@/components/home/CountdownTimer"
import { DashboardHeader } from "@/components/home/DashboardHeader"
import { DepositAddress } from "@/components/home/DepositAddress"
import { LiveDepositsFeed } from "@/components/home/LiveDepositsFeed"
import { RoundHistory } from "@/components/home/RoundHistory"
import { HowItWorks } from "@/components/home/HowItWorks"
import { SiteFooter } from "@/components/home/SiteFooter"
import { StatsGrid } from "@/components/home/StatsGrid"
import { WinnersSection } from "@/components/home/WinnersSection"
import { SITE } from "@/lib/site"
import {
  getCountdown,
  useLotteryDashboard,
} from "@/hooks/use-lottery-dashboard"

export function HomeDashboard() {
  const { data, tick } = useLotteryDashboard()
  const countdown = getCountdown(data.currentRound, tick)

  const displayRoundId =
    data.roundHistory[0] ??
    (data.currentRound && data.currentRound.status !== "OPEN"
      ? data.currentRound.roundId
      : data.currentRound
        ? data.currentRound.roundId - BigInt(1)
        : null)

  const displayRoundKey = displayRoundId?.toString() ?? null
  const displayPayouts = displayRoundKey
    ? (data.payoutsByRound.get(displayRoundKey) ?? null)
    : null

  const showWinners =
    Boolean(displayPayouts) ||
    (data.currentRound?.status !== "OPEN" && data.currentRound !== null)

  return (
    <div className="relative min-h-svh bg-background text-foreground">
      <div
        className="pointer-events-none fixed inset-0 bg-[radial-gradient(ellipse_at_top,_var(--tw-gradient-stops))] from-primary/6 via-background to-background"
        aria-hidden
      />

      <div className="relative mx-auto flex w-full max-w-6xl flex-col gap-5 px-4 py-6 sm:px-6 lg:px-8">
        <DashboardHeader round={data.currentRound} />

        {data.error && (
          <Alert variant="destructive">
            <AlertTitle>Canister connection failed</AlertTitle>
            <AlertDescription>
              {data.error}. Deploy the {SITE.name} canister and set{" "}
              <span className="font-mono">NEXT_PUBLIC_LOTTERY_CANISTER_ID</span>{" "}
              in <span className="font-mono">frontend/.env.local</span>.
            </AlertDescription>
          </Alert>
        )}

        {data.loading ? (
          <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
            {Array.from({ length: 4 }).map((_, index) => (
              <Skeleton key={index} className="h-28 rounded-xl" />
            ))}
          </div>
        ) : (
          <StatsGrid round={data.currentRound} />
        )}

        <CountdownTimer
          round={data.currentRound}
          hours={countdown.hours}
          minutes={countdown.minutes}
          seconds={countdown.seconds}
          milliseconds={countdown.milliseconds}
          progress={countdown.progress}
          done={countdown.done}
        />

        <HowItWorks />

        <div className="grid items-stretch gap-5 lg:grid-cols-2">
          <DepositAddress />
          <LiveDepositsFeed items={data.depositFeed} />
        </div>

        <WinnersSection
          payouts={displayPayouts}
          roundId={displayRoundId}
          visible={showWinners}
        />

        <RoundHistory
          roundIds={data.roundHistory}
          roundResults={data.roundResults}
          payoutsByRound={data.payoutsByRound}
        />
      </div>

      <SiteFooter />
    </div>
  )
}
