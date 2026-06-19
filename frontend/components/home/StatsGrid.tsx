import {
  Coins01Icon,
  UserGroupIcon,
  PercentCircleIcon,
  GiftIcon,
} from "@hugeicons/core-free-icons"
import { HugeiconsIcon } from "@hugeicons/react"

import { Card, CardContent } from "@/components/ui/card"
import { type HugeIcon } from "@/components/home/IconBox"
import { formatE8sToIcp } from "@/lib/lottery/format"
import type { PublicCurrentRound } from "@/lib/lottery/types"
import { cn } from "@/lib/utils"

interface StatsGridProps {
  round: PublicCurrentRound | null
}

export function StatsGrid({ round }: StatsGridProps) {
  const pool = round?.poolICP ?? BigInt(0)
  const participants = round?.participants ?? BigInt(0)
  const treasury = pool / BigInt(100)
  const prizePool = pool - treasury

  const cards: {
    label: string
    value: string
    note: string
    icon: HugeIcon
    highlight?: boolean
  }[] = [
    {
      label: "Total Pool",
      value: `${formatE8sToIcp(pool)} ICP`,
      note: "Live balance",
      icon: Coins01Icon,
    },
    {
      label: "Participants",
      value: participants.toString(),
      note: "Unique wallets",
      icon: UserGroupIcon,
    },
    {
      label: "Treasury Fee",
      value: `${formatE8sToIcp(treasury)} ICP`,
      note: "1% protocol fee",
      icon: PercentCircleIcon,
    },
    {
      label: "Prize Pool",
      value: `${formatE8sToIcp(prizePool)} ICP`,
      note: "99% to winners",
      icon: GiftIcon,
      highlight: true,
    },
  ]

  return (
    <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
      {cards.map((card) => (
        <Card
          key={card.label}
          className={cn(
            "relative overflow-hidden border-border/60 bg-card/80 shadow-sm",
            card.highlight && "ring-1 ring-emerald-500/20"
          )}
        >
          {card.highlight && (
            <div
              className="absolute inset-y-0 right-0 w-1 bg-emerald-500"
              aria-hidden
            />
          )}
          <CardContent className="p-5">
            <div className="flex items-start justify-between gap-2">
              <p className="text-[11px] font-semibold uppercase tracking-wider text-muted-foreground">
                {card.label}
              </p>
              <HugeiconsIcon
                icon={card.icon}
                strokeWidth={2}
                className="size-4 shrink-0 text-muted-foreground/70"
              />
            </div>
            <p
              className={cn(
                "mt-2 text-3xl font-bold tabular-nums tracking-tight",
                card.highlight && "text-emerald-600 dark:text-emerald-400"
              )}
            >
              {card.value}
            </p>
            <p className="mt-1 text-xs text-muted-foreground">{card.note}</p>
          </CardContent>
        </Card>
      ))}
    </div>
  )
}
