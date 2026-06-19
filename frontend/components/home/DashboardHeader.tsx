import { HugeiconsIcon } from "@hugeicons/react"
import {
  Blockchain01Icon,
  Clock01Icon,
} from "@hugeicons/core-free-icons"

import { Badge } from "@/components/ui/badge"
import { BrandAvatar } from "@/components/home/BrandAvatar"
import { NETWORK_LABEL } from "@/lib/lottery/config"
import { SITE } from "@/lib/site"
import type { PublicCurrentRound } from "@/lib/lottery/types"

interface DashboardHeaderProps {
  round: PublicCurrentRound | null
}

export function DashboardHeader({ round }: DashboardHeaderProps) {
  const isOpen = round?.status === "OPEN"
  const roundId = round ? round.roundId.toString() : "—"

  return (
    <header className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
      <div className="flex items-center gap-4">
        <BrandAvatar size="md" />
        <div>
          <p className="text-[11px] font-semibold uppercase tracking-[0.18em] text-muted-foreground">
            {SITE.tagline}
          </p>
          <h1 className="text-2xl font-bold tracking-tight sm:text-3xl">
            {SITE.name}
          </h1>
          <p className="mt-0.5 text-sm text-muted-foreground">
            {SITE.description}
          </p>
        </div>
      </div>

      <div className="flex flex-wrap items-center gap-2 sm:justify-end">
        <Badge variant="outline" className="gap-1.5 rounded-full px-3 py-1 font-normal">
          <HugeiconsIcon icon={Clock01Icon} strokeWidth={2} className="size-3.5" />
          Round #{roundId}
        </Badge>
        <Badge
          className={`rounded-full px-3 py-1 font-normal ${
            isOpen
              ? "border-0 bg-emerald-500/10 text-emerald-700 dark:text-emerald-400"
              : "border-border bg-muted/50 text-muted-foreground"
          }`}
        >
          {isOpen ? "online" : "offline"}
        </Badge>
        <Badge
          variant="outline"
          className="gap-1.5 rounded-full border-sky-500/30 bg-sky-500/10 px-3 py-1 font-normal text-sky-700 dark:text-sky-400"
        >
          <HugeiconsIcon icon={Blockchain01Icon} strokeWidth={2} className="size-3.5" />
          {NETWORK_LABEL}
        </Badge>
      </div>
    </header>
  )
}
