#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MOC="${MOC:-$(mops toolchain bin moc 2>/dev/null || echo "/home/prasanga/.cache/mops/moc/1.7.0/moc")}"

cd "${ROOT}"
FAILED=0
PASSED=0

PACK_ARGS=()
while read -r flag pkg path; do
  PACK_ARGS+=("${flag}" "${pkg}" "${path}")
done < <("${ROOT}/scripts/packtool.sh")

while IFS= read -r -d '' test_file; do
  echo "Running ${test_file}..."
  output=$("${MOC}" -r "${PACK_ARGS[@]}" \
    --package src "${ROOT}/src" \
    "${test_file}" 2>&1) || true
  echo "${output}"
  if echo "${output}" | grep -qE 'execution error|type error \[|FAIL '; then
    FAILED=$((FAILED + 1))
    echo "FAIL ${test_file}"
  elif echo "${output}" | grep -q 'mops:.*:end '; then
    PASSED=$((PASSED + 1))
    echo "PASS ${test_file}"
  else
    FAILED=$((FAILED + 1))
    echo "FAIL ${test_file}"
  fi
done < <(find "${ROOT}/backend/testing" -name '*.test.mo' -print0)

echo "=================================================="
echo "Passed: ${PASSED}, Failed: ${FAILED}"
if [ "${FAILED}" -gt 0 ]; then
  exit 1
fi
