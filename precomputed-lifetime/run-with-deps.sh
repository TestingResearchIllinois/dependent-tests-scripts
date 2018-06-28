#!/usr/bin/env bash

# Usage: bash run-with-deps.sh ORIG_DT_SUBJ
# NOTE: Environment variables should have been set before running this script.

ORIG_DT_SUBJ="$1"

startTime=`date`

# ======================================================

echo "[INFO] Running prioritization-runner script"
bash run-prio-with-deps.sh "$ORIG_DT_SUBJ"

echo "[INFO] Running selection-runner script"
bash run-sele-with-deps.sh "$ORIG_DT_SUBJ"

echo "[INFO] Running parallelization-runner script"
bash run-para-with-deps.sh "$ORIG_DT_SUBJ"

# ======================================================

echo "[INFO] Script has finished running."
echo "[INFO] Start time was ${startTime}"

endTime=`date`
echo "[INFO] End time is ${endTime}"

