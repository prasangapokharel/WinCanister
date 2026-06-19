#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CANISTER_ID="ulahq-iyaaa-aaaao-bbcoq-cai"
WASM="${ROOT}/.mops/.build/lottery.wasm"
DEPLOY_IDENTITY="${DEPLOY_IDENTITY:-}"

cd "${ROOT}"

echo "==> Building lottery wasm"
bash "${ROOT}/scripts/build-lottery.sh"

if [ -n "${DEPLOY_IDENTITY}" ]; then
  echo "==> Using identity: ${DEPLOY_IDENTITY}"
  dfx identity use "${DEPLOY_IDENTITY}"
fi

CALLER="$(dfx identity get-principal)"
echo "==> Caller principal: ${CALLER}"
echo "==> Target canister: ${CANISTER_ID}"

CONTROLLERS="$(dfx canister info "${CANISTER_ID}" --network ic 2>/dev/null | grep '^Controllers:' || true)"
echo "==> ${CONTROLLERS:-Controllers: unknown}"

if ! echo "${CONTROLLERS}" | grep -q "${CALLER}"; then
  echo ""
  echo "ERROR: Your dfx identity is NOT a controller of ${CANISTER_ID}."
  echo ""
  echo "Fix (one-time, in wallet.ic0.app):"
  echo "  1. Open canister 'lottery' → Add Controller"
  echo "  2. Paste this principal:"
  echo "     ${CALLER}"
  echo "  3. Re-run: bash scripts/deploy-mainnet.sh"
  echo ""
  echo "Or import your Internet Identity principal into dfx:"
  echo "  ni5n2-efxui-dyqdu-2mnpr-atclq-d6snc-zdq5q-u6ibz-ibpkq-brjpj-gqe"
  exit 1
fi

echo "==> Installing wasm..."
dfx canister install "${CANISTER_ID}" \
  --network ic \
  --wasm "${WASM}" \
  --argument '()' \
  --mode install

echo "==> Initializing..."
dfx canister call "${CANISTER_ID}" initialize --network ic

echo "==> getConfig"
dfx canister call "${CANISTER_ID}" getConfig --network ic --query

echo "==> getCurrentRound"
dfx canister call "${CANISTER_ID}" getCurrentRound --network ic --query

echo "==> health"
dfx canister call "${CANISTER_ID}" health --network ic --query

echo ""
echo "SUCCESS: Lottery live at ${CANISTER_ID}"
