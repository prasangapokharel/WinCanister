import { HugeiconsIcon } from "@hugeicons/react"
import { GithubIcon } from "@hugeicons/core-free-icons"

import { SITE } from "@/lib/site"

export function SiteFooter() {
  return (
    <footer className="border-t border-border/50 bg-background/80">
      <div className="mx-auto flex w-full max-w-7xl flex-col items-center justify-between gap-3 px-4 py-6 sm:flex-row sm:px-6 lg:px-8">
        <p className="text-sm text-muted-foreground">
          Built by{" "}
          <span className="font-medium text-foreground">{SITE.authorName}</span>
        </p>
        <a
          href={SITE.githubUrl}
          target="_blank"
          rel="noopener noreferrer"
          className="inline-flex items-center gap-2 rounded-full border border-border/60 bg-card/80 px-4 py-2 text-sm font-medium text-foreground transition-colors hover:border-primary/30 hover:bg-primary/5"
        >
          <HugeiconsIcon icon={GithubIcon} strokeWidth={2} className="size-4" />
          @{SITE.githubHandle}
        </a>
      </div>
    </footer>
  )
}
