import { ShieldBlockchainIcon } from "@hugeicons/core-free-icons"

import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import { CopyableValue } from "@/components/home/CopyableValue"
import { IconBox } from "@/components/home/IconBox"
import { formatE8sToIcp } from "@/lib/lottery/format"
import type { PayoutDetails, PublicStatistics } from "@/lib/lottery/types"

interface TransparencyPanelProps {
  statistics: PublicStatistics | null
  payouts: PayoutDetails | null
  roundId: bigint | null
}

export function TransparencyPanel({
  statistics,
  payouts,
  roundId,
}: TransparencyPanelProps) {
  const rows = payouts
    ? [
        { role: "Winner 1", entry: payouts.winner1 },
        { role: "Winner 2", entry: payouts.winner2 },
        { role: "Winner 3", entry: payouts.winner3 },
        { role: "Treasury", entry: payouts.treasury },
      ]
    : []

  return (
    <Card className="border-border/60 bg-card/70 shadow-sm">
      <CardHeader>
        <div className="flex items-start gap-3">
          <IconBox icon={ShieldBlockchainIcon} />
          <div className="space-y-1">
            <CardTitle>Transparency</CardTitle>
            <CardDescription>
              Public ledger-verifiable totals and transaction IDs.
            </CardDescription>
          </div>
        </div>
      </CardHeader>
      <CardContent className="space-y-6">
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          <Metric
            label="Total collected"
            value={
              statistics
                ? `${formatE8sToIcp(statistics.totalPoolCollected)} ICP`
                : "—"
            }
          />
          <Metric
            label="Total paid out"
            value={
              statistics
                ? `${formatE8sToIcp(statistics.totalPaidOut)} ICP`
                : "—"
            }
          />
          <Metric
            label="Treasury revenue"
            value={
              statistics
                ? `${formatE8sToIcp(statistics.totalTreasuryRevenue)} ICP`
                : "—"
            }
          />
          <Metric
            label="Total rounds"
            value={statistics?.totalRounds.toString() ?? "—"}
          />
        </div>

        {payouts && roundId ? (
          <div className="space-y-4">
            <p className="text-sm font-medium">
              Round #{roundId.toString()} payouts
            </p>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Role</TableHead>
                  <TableHead>Amount</TableHead>
                  <TableHead>TX ID</TableHead>
                  <TableHead>Paid</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {rows.map((row) => (
                  <TableRow key={row.role}>
                    <TableCell>{row.role}</TableCell>
                    <TableCell>
                      {row.entry
                        ? `${formatE8sToIcp(row.entry.amount)} ICP`
                        : "—"}
                    </TableCell>
                    <TableCell className="font-mono text-xs">
                      {row.entry?.txId.toString() ?? "—"}
                    </TableCell>
                    <TableCell>
                      {row.entry?.paid ? "Yes" : "No"}
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>

            <div className="grid gap-4 lg:grid-cols-2">
              {rows
                .filter((row) => row.entry)
                .map((row) => (
                  <CopyableValue
                    key={row.role}
                    label={`${row.role} ledger TX`}
                    value={row.entry!.txId.toString()}
                  />
                ))}
            </div>
          </div>
        ) : (
          <p className="text-sm text-muted-foreground">
            Payout details will appear after the first completed round.
          </p>
        )}
      </CardContent>
    </Card>
  )
}

function Metric({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-xl border border-border/50 bg-muted/20 p-4">
      <p className="text-xs uppercase tracking-wide text-muted-foreground">
        {label}
      </p>
      <p className="mt-1 text-lg font-semibold tabular-nums">{value}</p>
    </div>
  )
}
