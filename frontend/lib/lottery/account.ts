import { AccountIdentifier } from "@icp-sdk/canisters/ledger/icp"
import { Principal } from "@icp-sdk/core/principal"

import { LOTTERY_CANISTER_ID } from "./config"

export function accountIdFromPrincipal(principalText: string): string {
  return AccountIdentifier.fromPrincipal({
    principal: Principal.fromText(principalText),
  }).toHex()
}

export const LOTTERY_ACCOUNT_ID = accountIdFromPrincipal(LOTTERY_CANISTER_ID)

export const LOTTERY_ACCOUNT_DASHBOARD_URL = `https://dashboard.internetcomputer.org/account/${LOTTERY_ACCOUNT_ID}`
