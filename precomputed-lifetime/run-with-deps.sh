#!/usr/bin/env bash

# Usage: bash run-with-deps.sh
# NOTE: Environment variables should have been set before running this script.

startTime=`date`

# ======================================================

echo "[INFO] Running prioritization-runner script"
bash run-prio-with-deps.sh

echo "[INFO] Running selection-runner script"
bash run-sele-with-deps.sh

echo "[INFO] Running parallelization-runner script"
bash run-para-with-deps.sh

# ======================================================

echo "[INFO] Script has finished running."
echo "[INFO] Start time was ${startTime}"

endTime=`date`
echo "[INFO] End time is ${endTime}"

