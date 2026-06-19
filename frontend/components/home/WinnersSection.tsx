import { HugeiconsIcon } from "@hugeicons/react"
import {
  Award01Icon,
  MedalFirstPlaceIcon,
  MedalSecondPlaceIcon,
  MedalThirdPlaceIcon,
  SquareLock02Icon,
} from "@hugeicons/core-free-icons"

import { Badge } from "@/components/ui/badge"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import { CopyableValue } from "@/components/home/CopyableValue"
import { IconBox, type HugeIcon } from "@/components/home/IconBox"
import { formatE8sToIcp, shortenPrincipal } from "@/lib/lottery/format"
import type { PayoutDetails } from "@/lib/lottery/types"

interface WinnersSectionProps {
  payouts: PayoutDetails | null
  roundId: bigint | null
  visible: boolean
}

const SHARES = ["60%", "25%", "15%"] as const

const WINNER_ICONS: HugeIcon[] = [
  MedalFirstPlaceIcon,
  MedalSecondPlaceIcon,
  MedalThirdPlaceIcon,
]

export function WinnersSection({
  payouts,
  roundId,
  visible,
}: WinnersSectionProps) {
  if (!visible || !payouts) {
    return (
      <Card className="border-border/60 bg-card/80 shadow-sm">
        <CardHeader className="pb-2">
          <div className="flex items-start justify-between gap-3">
            <div className="flex items-center gap-3">
              <IconBox icon={Award01Icon} size="sm" />
              <CardTitle className="text-lg">Winners</CardTitle>
            </div>
            <span className="text-xs text-muted-foreground">
              Drawn when timer ends
            </span>
          </div>
        </CardHeader>
        <CardContent className="flex flex-col items-center justify-center gap-3 py-10 text-center">
          <div className="flex size-12 items-center justify-center rounded-full bg-muted/60 text-muted-foreground">
            <HugeiconsIcon icon={SquareLock02Icon} strokeWidth={2} className="size-6" />
          </div>
          <p className="max-w-md text-sm text-muted-foreground">
            Round is still open — winner cards appear after payouts are recorded.
          </p>
        </CardContent>
      </Card>
    )
  }

  const winners = [
    { label: "Winner 1", share: SHARES[0], entry: payouts.winner1 },
    { label: "Winner 2", share: SHARES[1], entry: payouts.winner2 },
    { label: "Winner 3", share: SHARES[2], entry: payouts.winner3 },
  ]

  return (
    <Card className="border-border/60 bg-card/80 shadow-sm">
      <CardHeader>
        <div className="flex items-start gap-3">
          <IconBox icon={Award01Icon} size="sm" />
          <div className="space-y-1">
            <CardTitle className="text-lg">
              Winners · Round #{roundId?.toString() ?? "—"}
            </CardTitle>
            <CardDescription>
              Prize split 60% / 25% / 15% with on-chain ledger verification.
            </CardDescription>
          </div>
        </div>
      </CardHeader>
      <CardContent className="grid gap-4 lg:grid-cols-3">
        {winners.map((winner, index) => (
          <Card
            key={winner.label}
            size="sm"
            className="border-border/50 bg-gradient-to-b from-muted/30 to-muted/10"
          >
            <CardHeader>
              <div className="flex items-center justify-between gap-2">
                <div className="flex items-center gap-2">
                  <div className="flex size-9 items-center justify-center rounded-lg bg-amber-500/15 text-amber-600 dark:text-amber-400">
                    <HugeiconsIcon
                      icon={WINNER_ICONS[index]}
                      strokeWidth={2}
                      className="size-5"
                    />
                  </div>
                  <CardTitle className="text-base">{winner.label}</CardTitle>
                </div>
                <Badge variant="outline">{winner.share}</Badge>
              </div>
            </CardHeader>
            <CardContent className="space-y-3">
              {winner.entry ? (
                <>
                  <p className="font-mono text-sm">
                    {shortenPrincipal(winner.entry.accountHex, 6)}
                  </p>
                  <p className="text-2xl font-semibold tabular-nums">
                    {formatE8sToIcp(winner.entry.amount)} ICP
                  </p>
                  <CopyableValue
                    label="Winner address"
                    value={winner.entry.accountHex}
                  />
                  <CopyableValue
                    label="Ledger TX"
                    value={winner.entry.txId.toString()}
                  />
                </>
              ) : (
                <p className="text-sm text-muted-foreground">No winner</p>
              )}
            </CardContent>
          </Card>
        ))}
      </CardContent>
    </Card>
  )
}
