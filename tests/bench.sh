#!/usr/bin/env bash
# Startup-time regression check.
#
# Runs `nvim --startuptime` a few times and fails if the median exceeds the
# threshold. Adjust thresholds if you change the config materially.

set -euo pipefail

THRESHOLD_EMPTY_MS="${THRESHOLD_EMPTY_MS:-60}"   # nvim +q
THRESHOLD_FILE_MS="${THRESHOLD_FILE_MS:-150}"    # nvim file +q
RUNS="${RUNS:-3}"
TARGET_FILE="${TARGET_FILE:-lua/config/lazy.lua}"

median() {
  printf '%s\n' "$@" | sort -n | awk '
    { a[NR] = $1 }
    END {
      n = NR
      if (n % 2) print a[(n+1)/2]
      else print (a[n/2] + a[n/2+1]) / 2
    }
  '
}

measure() {
  local extra="${1:-}"
  local times=()
  for _ in $(seq 1 "$RUNS"); do
    local log
    log=$(mktemp)
    if [[ -n "$extra" ]]; then
      nvim --startuptime "$log" +q "$extra" >/dev/null 2>&1
    else
      nvim --startuptime "$log" +q >/dev/null 2>&1
    fi
    local total
    total=$(awk '/--- NVIM STARTED ---/ { print $1; exit }' "$log")
    times+=("$total")
    rm -f "$log"
  done
  median "${times[@]}"
}

echo "Measuring nvim startup ($RUNS runs each)..."

empty_med=$(measure)
file_med=$(measure "$TARGET_FILE")

printf "  nvim +q             median: %s ms (threshold %s ms)\n" "$empty_med" "$THRESHOLD_EMPTY_MS"
printf "  nvim %s +q  median: %s ms (threshold %s ms)\n" "$TARGET_FILE" "$file_med" "$THRESHOLD_FILE_MS"

fail=0
awk -v v="$empty_med" -v t="$THRESHOLD_EMPTY_MS" 'BEGIN { exit (v+0 > t+0) ? 1 : 0 }' || {
  echo "FAIL: empty startup ${empty_med}ms exceeds ${THRESHOLD_EMPTY_MS}ms"
  fail=1
}
awk -v v="$file_med" -v t="$THRESHOLD_FILE_MS" 'BEGIN { exit (v+0 > t+0) ? 1 : 0 }' || {
  echo "FAIL: file startup ${file_med}ms exceeds ${THRESHOLD_FILE_MS}ms"
  fail=1
}

exit "$fail"
