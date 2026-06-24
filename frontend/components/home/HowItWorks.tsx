import { Card, CardContent } from "@/components/ui/card"

const steps = [
  {
    step: "01",
    title: "Deposit ICP",
    description:
      "Send 1 ICP or more to the canister address from any wallet (NNS, Plug, Stoic). Your entry is credited automatically.",
  },
  {
    step: "02",
    title: "24h Round",
    description:
      "Each round runs for 24 hours. The prize pool grows with every deposit. Watch the live countdown and activity feed.",
  },
  {
    step: "03",
    title: "Winners Drawn",
    description:
      "When the timer ends, winners are selected with on-chain randomness. Top 3 split 99% of the pool (60 / 25 / 15).",
  },
]

export function HowItWorks() {
  return (
    <section className="space-y-4">
      <div className="text-center">
        <h2 className="text-xl font-bold tracking-tight sm:text-2xl">
          How It Works
        </h2>
        <p className="mt-1 text-sm text-muted-foreground">
          Simple, transparent, on-chain. Three steps to play.
        </p>
      </div>

      <div className="grid gap-4 sm:grid-cols-3">
        {steps.map((s) => (
          <Card
            key={s.step}
            className="relative border-border/60 bg-card/80 shadow-sm"
          >
            <CardContent className="p-5">
              <span className="text-xs font-bold text-emerald-500">
                {s.step}
              </span>
              <h3 className="mt-2 text-base font-semibold">{s.title}</h3>
              <p className="mt-1 text-sm leading-relaxed text-muted-foreground">
                {s.description}
              </p>
            </CardContent>
          </Card>
        ))}
      </div>

      <div className="flex items-center justify-center gap-2 text-xs text-muted-foreground/70">
        <span className="inline-block size-2 rounded-full bg-emerald-500" />
        Live on Internet Computer Mainnet
      </div>
    </section>
  )
}
