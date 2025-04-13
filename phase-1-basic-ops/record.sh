#!/bin/bash

# Usage: ./record.sh loop_1billion

TARGET=$1
LOG_DIR=outputs/logs
RESULT_FILE=results.md

TIME_LOG="$LOG_DIR/${TARGET}_time.log"
PERF_LOG="$LOG_DIR/${TARGET}_perf.log"

if [ ! -f "$TIME_LOG" ] || [ ! -f "$PERF_LOG" ]; then
  echo "❌ 로그 파일이 없습니다: $TIME_LOG 또는 $PERF_LOG"
  exit 1
fi

# Extract time data
USER_TIME=$(grep "User time (seconds):" $TIME_LOG | sed -E 's/.*: ([0-9.]+)$/\1/')
SYS_TIME=$(grep "System time (seconds):" $TIME_LOG | sed -E 's/.*: ([0-9.]+)$/\1/')
WALL_TIME=$(grep "Elapsed (wall clock) time" $TIME_LOG | awk -F': ' '{print $2}')
CPU_PERCENT=$(grep "Percent of CPU this job got:" $TIME_LOG | sed -E 's/.*: ([0-9]+)%$/\1%/')

# Extract perf data
CYCLES=$(grep -E "[0-9,]+ +cycles" $PERF_LOG | awk '{print $1}' | tr -d ,)
INSTRUCTIONS=$(grep -E "[0-9,]+ +instructions" $PERF_LOG | awk '{print $1}' | tr -d ,)
IPC=$(grep "instructions" $PERF_LOG | sed -nE 's/.*# *([0-9.]+) +insn per cycle.*/\1/p')

# Write to results.md
if [ ! -f "$RESULT_FILE" ]; then
  echo "| 실험 이름 | Wall Time | User CPU | System CPU | CPU 사용률 | Instructions | Cycles | IPC |" > $RESULT_FILE
  echo "|------------|-----------|----------|------------|--------------|--------------|--------|-----|" >> $RESULT_FILE
fi

echo "| $TARGET | $WALL_TIME | $USER_TIME | $SYS_TIME | $CPU_PERCENT | $INSTRUCTIONS | $CYCLES | $IPC |" >> $RESULT_FILE

echo "✅ 기록 완료: $RESULT_FILE"

