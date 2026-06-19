"use client"

import { useState } from "react"

import { Clock02Icon } from "@hugeicons/core-free-icons"

import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { CopyableValue } from "@/components/home/CopyableValue"
import { IconBox } from "@/components/home/IconBox"
import { formatE8sToIcp, shortenPrincipal } from "@/lib/lottery/format"
import type { PayoutDetails, RoundResult } from "@/lib/lottery/types"

interface RoundHistoryProps {
  roundIds: bigint[]
  roundResults: Map<string, RoundResult>
  payoutsByRound: Map<string, PayoutDetails>
}

export function RoundHistory({
  roundIds,
  roundResults,
  payoutsByRound,
}: RoundHistoryProps) {
  const [selectedRound, setSelectedRound] = useState<string | null>(null)
  const selectedResult = selectedRound
    ? roundResults.get(selectedRound) ?? null
    : null
  const selectedPayouts = selectedRound
    ? payoutsByRound.get(selectedRound) ?? null
    : null

  return (
    <>
      <Card className="border-border/60 bg-card/70 shadow-sm">
        <CardHeader>
          <div className="flex items-start gap-3">
            <IconBox icon={Clock02Icon} />
            <div className="space-y-1">
              <CardTitle>Round History</CardTitle>
              <CardDescription>
                Previous rounds with expandable details and payout verification.
              </CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          {roundIds.length === 0 ? (
            <p className="text-sm text-muted-foreground">
              No completed rounds yet.
            </p>
          ) : (
            <Accordion type="single" collapsible className="border-none">
              {roundIds.map((roundId) => {
                const key = roundId.toString()
                const result = roundResults.get(key)
                return (
                  <AccordionItem key={key} value={key}>
                    <AccordionTrigger className="px-4 hover:no-underline">
                      <div className="flex w-full items-center justify-between gap-3 pr-2">
                        <span className="font-medium">Round #{key}</span>
                        <div className="flex items-center gap-2">
                          {result ? (
                            <>
                              <Badge variant="outline">
                                {formatE8sToIcp(result.totalPool)} ICP
                              </Badge>
                              <Badge variant="secondary">
                                {result.status}
                              </Badge>
                            </>
                          ) : (
                            <Badge variant="outline">Loading…</Badge>
                          )}
                        </div>
                      </div>
                    </AccordionTrigger>
                    <AccordionContent className="px-4 pb-4">
                      {result ? (
                        <div className="space-y-3 rounded-xl border bg-muted/20 p-4 text-sm">
                          <Row
                            label="Pool"
                            value={`${formatE8sToIcp(result.totalPool)} ICP`}
                          />
                          <Row
                            label="Treasury"
                            value={`${formatE8sToIcp(result.treasuryFee)} ICP`}
                          />
                          <Row
                            label="Prize pool"
                            value={`${formatE8sToIcp(result.prizePool)} ICP`}
                          />
                          <Row
                            label="Winner 1"
                            value={
                              result.winner1
                                ? shortenPrincipal(result.winner1, 6)
                                : "—"
                            }
                          />
                          <Button
                            type="button"
                            variant="outline"
                            size="sm"
                            onClick={() => setSelectedRound(key)}
                          >
                            View payout TX IDs
                          </Button>
                        </div>
                      ) : (
                        <p className="text-sm text-muted-foreground">
                          Round data unavailable.
                        </p>
                      )}
                    </AccordionContent>
                  </AccordionItem>
                )
              })}
            </Accordion>
          )}
        </CardContent>
      </Card>

      <Dialog
        open={selectedRound !== null}
        onOpenChange={(open) => !open && setSelectedRound(null)}
      >
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle>Round #{selectedRound} payouts</DialogTitle>
            <DialogDescription>
              Copy ledger transaction IDs to verify on the ICP ledger.
            </DialogDescription>
          </DialogHeader>
          {selectedResult && (
            <div className="space-y-2 text-sm">
              <Row
                label="Total pool"
                value={`${formatE8sToIcp(selectedResult.totalPool)} ICP`}
              />
              <Row
                label="Treasury fee"
                value={`${formatE8sToIcp(selectedResult.treasuryFee)} ICP`}
              />
            </div>
          )}
          {selectedPayouts ? (
            <div className="grid gap-4">
              {[
                { label: "Winner 1 TX", entry: selectedPayouts.winner1 },
                { label: "Winner 2 TX", entry: selectedPayouts.winner2 },
                { label: "Winner 3 TX", entry: selectedPayouts.winner3 },
                { label: "Treasury TX", entry: selectedPayouts.treasury },
              ].map(
                (item) =>
                  item.entry && (
                    <CopyableValue
                      key={item.label}
                      label={item.label}
                      value={item.entry.txId.toString()}
                    />
                  )
              )}
            </div>
          ) : (
            <p className="text-sm text-muted-foreground">
              No payout records for this round.
            </p>
          )}
        </DialogContent>
      </Dialog>
    </>
  )
}

function Row({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex items-center justify-between gap-4">
      <span className="text-muted-foreground">{label}</span>
      <span className="font-mono text-xs sm:text-sm">{value}</span>
    </div>
  )
}
