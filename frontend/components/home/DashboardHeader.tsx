import { Badge } from "@/components/ui/badge"
import { BrandAvatar } from "@/components/home/BrandAvatar"
import { ThemeToggle } from "@/components/home/ThemeToggle"
import { NETWORK_LABEL } from "@/lib/lottery/config"
import { SITE } from "@/lib/site"
import type { PublicCurrentRound } from "@/lib/lottery/types"

interface DashboardHeaderProps {
  round: PublicCurrentRound | null
}

const badgeClass = "rounded-full px-3 py-1 font-normal"

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

      <div className="flex flex-wrap items-end gap-2 sm:justify-end">
        <Badge variant="outline" className={badgeClass}>
          Round #{roundId}
        </Badge>
        <Badge variant="outline" className={badgeClass}>
          <span className={`mr-1.5 inline-block size-2 rounded-full ${isOpen ? "bg-emerald-500" : "bg-muted-foreground/50"}`} />
          {isOpen ? "online" : "offline"}
        </Badge>
        <div className="flex flex-col items-center gap-1">
          <ThemeToggle />
          <Badge variant="outline" className={badgeClass}>
            {NETWORK_LABEL}
          </Badge>
        </div>
      </div>
    </header>
  )
}
