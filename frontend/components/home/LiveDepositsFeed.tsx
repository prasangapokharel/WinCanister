import { HugeiconsIcon } from "@hugeicons/react"
import { Activity03Icon, ViewIcon } from "@hugeicons/core-free-icons"

import { Badge } from "@/components/ui/badge"
import { ScrollArea } from "@/components/ui/scroll-area"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { IconBox } from "@/components/home/IconBox"
import { POLL_DEPOSITS_MS } from "@/lib/lottery/config"
import { timeAgo } from "@/lib/lottery/format"
import type { DepositFeedItem } from "@/lib/lottery/types"

interface LiveDepositsFeedProps {
  items: DepositFeedItem[]
}

export function LiveDepositsFeed({ items }: LiveDepositsFeedProps) {
  return (
    <Card className="flex h-full flex-col border-border/60 bg-card/80 shadow-sm">
      <CardHeader className="pb-4">
        <div className="flex items-start justify-between gap-3">
          <div className="flex items-center gap-3">
            <IconBox icon={Activity03Icon} size="sm" />
            <CardTitle className="text-lg">Live activity</CardTitle>
          </div>
          <Badge variant="secondary" className="shrink-0 rounded-full text-[10px] font-normal">
            Polled every {POLL_DEPOSITS_MS / 1000}s
          </Badge>
        </div>
      </CardHeader>
      <CardContent className="flex flex-1 flex-col gap-4 pb-6">
        <ScrollArea className="min-h-[12rem] flex-1 pr-2">
          {items.length === 0 ? (
            <p className="text-sm text-muted-foreground">
              No entries yet this round.
            </p>
          ) : (
            <ul className="space-y-2">
              {items.map((item) => (
                <li
                  key={item.id}
                  className="flex items-center justify-between gap-3 rounded-lg border border-border/50 bg-muted/20 px-3 py-2.5"
                >
                  <Badge
                    variant="outline"
                    className="shrink-0 border-emerald-500/30 bg-emerald-500/10 text-emerald-700 dark:text-emerald-400"
                  >
                    +{item.amountIcp}
                  </Badge>
                  <span className="flex-1 truncate text-sm text-foreground">
                    {item.label}
                  </span>
                  <span className="shrink-0 text-xs text-muted-foreground">
                    {timeAgo(item.timestamp)}
                  </span>
                </li>
              ))}
            </ul>
          )}
        </ScrollArea>
        <div className="flex items-center gap-2 border-t border-border/50 pt-3 text-xs text-muted-foreground">
          <HugeiconsIcon icon={ViewIcon} strokeWidth={2} className="size-3.5" />
          Watching for new entries…
        </div>
      </CardContent>
    </Card>
  )
}
