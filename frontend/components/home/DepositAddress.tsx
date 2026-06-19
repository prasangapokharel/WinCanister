"use client"

import Image from "next/image"
import Link from "next/link"
import { useState } from "react"

import { HugeiconsIcon } from "@hugeicons/react"
import {
  Copy01Icon,
  CopyCheckIcon,
  LinkSquare02Icon,
  QrCodeIcon,
} from "@hugeicons/core-free-icons"

import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { IconBox } from "@/components/home/IconBox"
import {
  LOTTERY_ACCOUNT_DASHBOARD_URL,
  LOTTERY_ACCOUNT_ID,
} from "@/lib/lottery/account"
import { E8S_PER_ICP } from "@/lib/lottery/config"
import { formatE8sToIcp } from "@/lib/lottery/format"

export function DepositAddress() {
  const [copied, setCopied] = useState(false)

  const qrUrl = `https://api.qrserver.com/v1/create-qr-code/?size=280x280&data=${encodeURIComponent(
    LOTTERY_ACCOUNT_ID
  )}`

  async function handleCopy() {
    await navigator.clipboard.writeText(LOTTERY_ACCOUNT_ID)
    setCopied(true)
    window.setTimeout(() => setCopied(false), 2000)
  }

  return (
    <Card className="flex h-full flex-col border-border/60 bg-card/80 shadow-sm">
      <CardHeader className="pb-4">
        <div className="flex items-center gap-3">
          <IconBox icon={QrCodeIcon} size="sm" />
          <CardTitle className="text-lg">Deposit</CardTitle>
        </div>
      </CardHeader>
      <CardContent className="flex flex-1 flex-col gap-4 pb-6">
        <div className="flex flex-1 flex-col gap-5 sm:flex-row sm:items-start">
          <div className="mx-auto shrink-0 overflow-hidden rounded-xl border bg-white p-2.5 shadow-sm sm:mx-0">
            <Image
              src={qrUrl}
              alt="Deposit address QR code"
              width={200}
              height={200}
              unoptimized
              priority
              className="size-44 sm:size-48"
            />
          </div>

          <div className="flex min-w-0 flex-1 flex-col gap-3">
            <div className="rounded-lg border bg-muted/40 px-3 py-3">
              <p className="break-all font-mono text-[11px] leading-relaxed text-foreground sm:text-xs">
                {LOTTERY_ACCOUNT_ID}
              </p>
            </div>
            <Button
              type="button"
              variant="outline"
              className="w-full gap-2"
              onClick={() => void handleCopy()}
            >
              <HugeiconsIcon
                icon={copied ? CopyCheckIcon : Copy01Icon}
                strokeWidth={2}
                className="size-4"
              />
              {copied ? "Copied!" : "Copy address"}
            </Button>
            <p className="text-xs leading-relaxed text-muted-foreground">
              Send {formatE8sToIcp(E8S_PER_ICP)} ICP or more from NNS, Plug, or
              any ICP wallet. Entry added automatically.
            </p>
          </div>
        </div>

        <Link
          href={LOTTERY_ACCOUNT_DASHBOARD_URL}
          target="_blank"
          rel="noopener noreferrer"
          className="mt-auto inline-flex items-center gap-1.5 text-xs font-medium text-primary hover:underline"
        >
          <HugeiconsIcon icon={LinkSquare02Icon} strokeWidth={2} className="size-3.5" />
          View on ICP Dashboard
        </Link>
      </CardContent>
    </Card>
  )
}
