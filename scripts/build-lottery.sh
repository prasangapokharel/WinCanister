#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MOC="${MOC:-$(mops toolchain bin moc 2>/dev/null || echo "/home/prasanga/.cache/mops/moc/1.7.0/moc")}"
OUT="${ROOT}/.mops/.build"
IDL_DIR="${ROOT}/.dfx/local/canisters/idl"
NETWORK="${DFX_NETWORK:-ic}"
ICRC1_LEDGER_ID="${ICRC1_LEDGER_ID:-ryjl3-tyaaa-aaaaa-aaaba-cai}"
ICP_INDEX_ID="${ICP_INDEX_ID:-qhbym-qaaaa-aaaaa-aaafq-cai}"

if [ "${NETWORK}" = "local" ]; then
  ICRC1_LEDGER_ID="uxrrr-q7777-77774-qaaaq-cai"
  ICP_INDEX_ID="qhbym-qaaaa-aaaaa-aaafq-cai"
fi

mkdir -p "${OUT}" "${IDL_DIR}"

if [ ! -f "${IDL_DIR}/${ICRC1_LEDGER_ID}.did" ]; then
  if [ "${NETWORK}" = "local" ]; then
    dfx build icrc1_ledger >/dev/null
    cp "${ROOT}/.dfx/local/canisters/icrc1_ledger/service.did" "${IDL_DIR}/${ICRC1_LEDGER_ID}.did"
  else
    dfx canister --network ic metadata "${ICRC1_LEDGER_ID}" candid:service > "${IDL_DIR}/${ICRC1_LEDGER_ID}.did"
  fi
fi

cd "${ROOT}"
PACK_ARGS=()
while read -r flag pkg path; do
  PACK_ARGS+=("${flag}" "${pkg}" "${path}")
done < <("${ROOT}/scripts/packtool.sh")

"${MOC}" -c "${PACK_ARGS[@]}" \
  --package src "${ROOT}/src" \
  "${ROOT}/src/main.mo" \
  -o "${OUT}/lottery.wasm" \
  --idl \
  --enhanced-migration src/migrations \
  --default-persistent-actors \
  --actor-idl "${IDL_DIR}" \
  --actor-alias icrc1_ledger "${ICRC1_LEDGER_ID}" \
  --actor-alias icp_index "${ICP_INDEX_ID}"

echo "Built ${OUT}/lottery.wasm"
