"use client"

import { useState } from "react"

import { HugeiconsIcon } from "@hugeicons/react"
import { Copy01Icon, CopyCheckIcon, LinkIcon } from "@hugeicons/core-free-icons"

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
  href?: string
  mono?: boolean
  className?: string
}

export function CopyableValue({
  label,
  value,
  href,
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
          {href ? (
            <a
              href={href}
              target="_blank"
              rel="noopener noreferrer"
              className={cn(
                "flex h-9 items-center gap-1.5 rounded-md border bg-muted/40 px-3 text-sm transition-colors hover:bg-muted/60",
                mono && "font-mono text-xs"
              )}
            >
              <HugeiconsIcon icon={LinkIcon} strokeWidth={2} className="size-3.5 shrink-0 text-muted-foreground" />
              {value}
            </a>
          ) : (
            <Input
              readOnly
              value={value}
              className={cn("bg-muted/40", mono && "font-mono text-xs")}
            />
          )}
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
