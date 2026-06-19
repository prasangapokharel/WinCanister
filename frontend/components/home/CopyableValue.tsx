"use client"

import { useState } from "react"

import { HugeiconsIcon } from "@hugeicons/react"
import { Copy01Icon, CopyCheckIcon } from "@hugeicons/core-free-icons"

import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip"
import { cn } from "@/lib/utils"

interface CopyableValueProps {
  label: string
  value: string
  mono?: boolean
  className?: string
}

export function CopyableValue({
  label,
  value,
  mono = true,
  className,
}: CopyableValueProps) {
  const [copied, setCopied] = useState(false)

  async function handleCopy() {
    await navigator.clipboard.writeText(value)
    setCopied(true)
    window.setTimeout(() => setCopied(false), 2000)
  }

  return (
    <TooltipProvider>
      <div className={cn("space-y-2", className)}>
        <p className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
          {label}
        </p>
        <div className="flex gap-2">
          <Input
            readOnly
            value={value}
            className={cn("bg-muted/40", mono && "font-mono text-xs")}
          />
          <Tooltip open={copied}>
            <TooltipTrigger asChild>
              <Button type="button" variant="outline" onClick={handleCopy} className="gap-1.5">
                <HugeiconsIcon
                  icon={copied ? CopyCheckIcon : Copy01Icon}
                  strokeWidth={2}
                  className="size-4"
                />
                {copied ? "Copied!" : "Copy"}
              </Button>
            </TooltipTrigger>
            <TooltipContent>Copied to clipboard</TooltipContent>
          </Tooltip>
        </div>
      </div>
    </TooltipProvider>
  )
}
