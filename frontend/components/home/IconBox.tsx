import { Coins01Icon } from "@hugeicons/core-free-icons"
import { HugeiconsIcon } from "@hugeicons/react"

import { cn } from "@/lib/utils"

export type HugeIcon = typeof Coins01Icon

interface IconBoxProps {
  icon: HugeIcon
  className?: string
  iconClassName?: string
  size?: "sm" | "md"
}

export function IconBox({
  icon,
  className,
  iconClassName,
  size = "md",
}: IconBoxProps) {
  return (
    <div
      className={cn(
        "flex shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary ring-1 ring-primary/10",
        size === "sm" ? "size-9" : "size-10",
        className
      )}
    >
      <HugeiconsIcon
        icon={icon}
        strokeWidth={2}
        className={cn(size === "sm" ? "size-4" : "size-5", iconClassName)}
      />
    </div>
  )
}
