import { E8S_PER_ICP } from "./config"

export function formatE8sToIcp(amount: bigint, digits = 4): string {
  const whole = amount / E8S_PER_ICP
  const fraction = amount % E8S_PER_ICP
  if (fraction === BigInt(0)) {
    return `${whole.toString()}`
  }
  const fracStr = fraction
    .toString()
    .padStart(8, "0")
    .slice(0, digits)
    .replace(/0+$/, "")
  return fracStr.length > 0 ? `${whole}.${fracStr}` : `${whole}`
}

export function shortenPrincipal(value: string, chars = 4): string {
  if (value.length <= chars * 2 + 3) {
    return value
  }
  return `${value.slice(0, chars)}...${value.slice(-chars)}`
}

/** Agent v3 returns a value directly; older agents wrapped it in a one-tuple. */
export function unwrapResult<T>(result: unknown): T {
  if (Array.isArray(result) && result.length === 1) {
    return result[0] as T
  }
  return result as T
}

export function unwrapOpt<T>(result: unknown): T | null {
  if (result === null || result === undefined) {
    return null
  }
  if (!Array.isArray(result)) {
    return result as T
  }
  if (result.length === 0) {
    return null
  }
  if (result.length === 1) {
    const inner = result[0]
    return inner === null || inner === undefined ? null : (inner as T)
  }
  return result as T
}

export function optText(value: unknown): string | null {
  if (value === null || value === undefined) {
    return null
  }
  if (Array.isArray(value)) {
    return value.length > 0 ? String(value[0]) : null
  }
  return String(value)
}

export function principalToText(value: unknown): string {
  if (typeof value === "string") {
    return value
  }
  if (
    value &&
    typeof value === "object" &&
    "toText" in value &&
    typeof (value as { toText: () => string }).toText === "function"
  ) {
    return (value as { toText: () => string }).toText()
  }
  return String(value)
}

export function optPrincipal(value: unknown): string | null {
  if (value === null || value === undefined) {
    return null
  }
  if (Array.isArray(value)) {
    return value.length > 0 ? principalToText(value[0]) : null
  }
  return principalToText(value)
}

export function timeAgo(timestampMs: number): string {
  const seconds = Math.floor((Date.now() - timestampMs) / 1000)
  if (seconds < 5) return "just now"
  if (seconds < 60) return `${seconds}s ago`
  const minutes = Math.floor(seconds / 60)
  if (minutes < 60) return `${minutes}m ago`
  const hours = Math.floor(minutes / 60)
  return `${hours}h ago`
}

export function nsToMs(ns: bigint): number {
  return Number(ns / BigInt(1_000_000))
}

export function nowNs(): bigint {
  return BigInt(Date.now()) * BigInt(1_000_000)
}

export function statusBadgeVariant(
  status: string
): "default" | "secondary" | "outline" | "destructive" {
  switch (status.toUpperCase()) {
    case "OPEN":
      return "default"
    case "CLOSED":
    case "DRAWING":
    case "PAYING":
      return "secondary"
    case "COMPLETED":
      return "outline"
    default:
      return "outline"
  }
}
