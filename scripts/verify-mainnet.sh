#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CANISTER_ID="ulahq-iyaaa-aaaao-bbcoq-cai"

cd "${ROOT}"

echo "=== Mainnet verification: ${CANISTER_ID} ==="

echo ""
echo "-- Canister info --"
dfx canister info "${CANISTER_ID}" --network ic 2>&1 || true

echo ""
echo "-- health --"
dfx canister call "${CANISTER_ID}" health --network ic --query 2>&1 || true

echo ""
echo "-- getConfig --"
dfx canister call "${CANISTER_ID}" getConfig --network ic --query 2>&1 || true

echo ""
echo "-- getCurrentRound --"
dfx canister call "${CANISTER_ID}" getCurrentRound --network ic --query 2>&1 || true

echo ""
echo "-- getStatistics --"
dfx canister call "${CANISTER_ID}" getStatistics --network ic --query 2>&1 || true

echo ""
echo "-- Wallet ICP balance --"
dfx ledger account-id --of-principal ni5n2-efxui-dyqdu-2mnpr-atclq-d6snc-zdq5q-u6ibz-ibpkq-brjpj-gqe --network ic 2>&1
ACCOUNT_ID="$(dfx ledger account-id --of-principal ni5n2-efxui-dyqdu-2mnpr-atclq-d6snc-zdq5q-u6ibz-ibpkq-brjpj-gqe --network ic 2>/dev/null)"
dfx ledger balance "${ACCOUNT_ID}" --network ic 2>&1 || true
