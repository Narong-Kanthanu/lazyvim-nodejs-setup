#!/usr/bin/env bash
# Runs all regression checks for the perf/cleanup branch.
#
# Usage:
#   tests/run.sh            # run config + bench
#   tests/run.sh check      # config asserts only
#   tests/run.sh bench      # startup-time benchmark only

set -euo pipefail

cd "$(dirname "$0")/.."

mode="${1:-all}"
fail=0

run_check() {
  echo "==> Running config asserts (tests/check.lua)"
  # Use +luafile so init.lua loads first, then exit on completion via os.exit().
  if nvim --headless +"luafile tests/check.lua"; then
    echo "    config asserts: PASS"
  else
    echo "    config asserts: FAIL"
    fail=1
  fi
}

run_bench() {
  echo ""
  echo "==> Running startup-time benchmark (tests/bench.sh)"
  if bash tests/bench.sh; then
    echo "    bench: PASS"
  else
    echo "    bench: FAIL"
    fail=1
  fi
}

case "$mode" in
  check) run_check ;;
  bench) run_bench ;;
  all)   run_check; run_bench ;;
  *) echo "Usage: $0 [check|bench|all]"; exit 2 ;;
esac

exit "$fail"
