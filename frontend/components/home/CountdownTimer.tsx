import { Progress } from "@/components/ui/progress"
import { Card } from "@/components/ui/card"
import type { PublicCurrentRound } from "@/lib/lottery/types"

interface CountdownTimerProps {
  round: PublicCurrentRound | null
  hours: number
  minutes: number
  seconds: number
  milliseconds: number
  progress: number
  done: boolean
}

function pad(value: number, digits = 2) {
  return value.toString().padStart(digits, "0")
}

export function CountdownTimer({
  round,
  hours,
  minutes,
  seconds,
  milliseconds,
  progress,
  done,
}: CountdownTimerProps) {
  const label =
    round?.status === "OPEN"
      ? done
        ? "Round closing — drawing winners"
        : "Time until round closes"
      : "Round in progress"

  return (
    <Card className="overflow-hidden border-border/60 bg-card/80 shadow-sm">
      <div className="px-4 py-8 text-center sm:px-6">
        <p className="text-[11px] font-semibold uppercase tracking-[0.2em] text-muted-foreground">
          {label}
        </p>
        <p className="mt-4 font-mono text-4xl font-bold tracking-widest tabular-nums sm:text-5xl lg:text-6xl">
          <span>{pad(hours)}</span>
          <span className="text-muted-foreground/50">:</span>
          <span>{pad(minutes)}</span>
          <span className="text-muted-foreground/50">:</span>
          <span>{pad(seconds)}</span>
          <span className="text-muted-foreground/50">.</span>
          <span className="text-emerald-600 dark:text-emerald-400">
            {pad(milliseconds, 3)}
          </span>
        </p>
        <div className="mt-4 grid grid-cols-4 gap-2 text-[10px] font-semibold uppercase tracking-wider text-muted-foreground sm:text-xs">
          <span>Hours</span>
          <span>Minutes</span>
          <span>Seconds</span>
          <span className="text-emerald-600/80 dark:text-emerald-400/80">Ms</span>
        </div>
      </div>
      <Progress value={progress} className="h-1.5 rounded-none" />
    </Card>
  )
}
