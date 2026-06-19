import Image from "next/image"

import { cn } from "@/lib/utils"
import { SITE } from "@/lib/site"

interface BrandAvatarProps {
  size?: "sm" | "md" | "lg"
  className?: string
}

const sizes = {
  sm: { box: "size-10", img: 28 },
  md: { box: "size-12", img: 36 },
  lg: { box: "size-16", img: 48 },
} as const

export function BrandAvatar({ size = "md", className }: BrandAvatarProps) {
  const { box, img } = sizes[size]

  return (
    <div
      className={cn(
        "relative flex shrink-0 items-center justify-center overflow-hidden rounded-full border border-border/60 bg-gradient-to-br from-primary/15 via-card to-card p-1.5 shadow-sm ring-1 ring-primary/10",
        box,
        className
      )}
    >
      <Image
        src="/images/logo/icp.png"
        alt={SITE.name}
        width={img}
        height={img}
        className="object-contain"
        priority
      />
    </div>
  )
}
