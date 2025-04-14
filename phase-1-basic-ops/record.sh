#!/bin/bash

# Usage: ./record.sh <target_binary_name>
# Example: ./record.sh integer_ops

TARGET=$1
BIN=./outputs/$TARGET.out
LOG_DIR=outputs/logs
PERF_LOG="$LOG_DIR/${TARGET}_perf.log"
RESULTS_SCRIPT=./record_table_results.py

mkdir -p "$LOG_DIR"

EVENTS="task-clock,cycles,instructions,cache-misses,stalled-cycles-frontend,stalled-cycles-backend,context-switches,page-faults,branches,branch-misses"

echo "🚀 Running perf stat for $TARGET..."
perf stat -e $EVENTS -o "$PERF_LOG" $BIN

if [ $? -ne 0 ]; then
  echo "❌ Execution failed for $BIN"
  exit 1
fi

# Automatically append to results.md
if [ -f "$RESULTS_SCRIPT" ]; then
  python3 "$RESULTS_SCRIPT" "$PERF_LOG" "$TARGET"
else
  echo "⚠️  Summary script $RESULTS_SCRIPT not found. Skipping results.md update."
fi

echo "✅ Full run for $TARGET completed."

