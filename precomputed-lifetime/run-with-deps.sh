#!/usr/bin/env bash

# Usage: bash run-with-deps.sh [TECHNIQUES]
# NOTE: Environment variables should have been set before running this script.
# TECHNIQUES: techniques to use (e.g., "prio-sele-para" or "para" or "sele-prio"). Optional. If not provided, then will use all techniques

. "$DT_SCRIPTS/constants.sh"

startTime=`date`

TECHNIQUES="$1"

if [[ -z "$TECHNIQUES" ]]; then
    TECHNIQUES="prio-para-sele"
fi

# ======================================================

rm -rf "$DT_ROOT/$prioDir"
if [[ "$TECHNIQUES" =~ "prio" ]]; then
    echo "[INFO] Running prioritization-runner script"
    echo "Prio start time is $(date)"
    bash run-prio-with-deps.sh
    echo "Prio end time is $(date)"
fi

rm -rf "$DT_ROOT/$seleDir"
if [[ "$TECHNIQUES" =~ "sele" ]]; then
    echo "[INFO] Running selection-runner script"
    echo "Sele start time is $(date)"
    bash run-sele-with-deps.sh
    echo "Sele end time is $(date)"
fi

rm -rf "$DT_ROOT/$paraDir"
if [[ "$TECHNIQUES" =~ "para" ]]; then
    echo "[INFO] Running parallelization-runner script"
    echo "Para start time is $(date)"
    bash run-para-with-deps.sh
    echo "Para end time is $(date)"
fi

# ======================================================

echo "[INFO] Script has finished running."
echo "[INFO] Start time was ${startTime}"

endTime=`date`
echo "[INFO] End time is ${endTime}"

