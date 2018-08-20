#!/usr/bin/env bash

# Usage: bash run-subj-precomputed.sh SETUP_SCRIPT

set -e

if [[ ! -z "$1" ]]; then
    # Generally the setup scripts are written so that they assume you are in a particular directory, so
    # make sure we match that.
    CURRENT=$(pwd)

    SCRIPT_DIR=$(dirname "$1")
    SCRIPT_NAME=$(basename "$1")

    echo "[INFO] Running setup script $SCRIPT_NAME in $SCRIPT_DIR"

    cd $SCRIPT_DIR
    . "$SCRIPT_NAME"

    cd $CURRENT
fi

echo "[INFO] Running subject ${SUBJ_NAME}"

RESULTS_DIR="$DT_SCRIPTS/${SUBJ_NAME}-results"

echo "[INFO] Checking for results directory at $RESULTS_DIR"
# Make the results directory if it doesn't exist (and copy the setup script if applicable)
if [[ ! -d "$RESULTS_DIR" ]]; then
    echo "[INFO] Creating results directory"
    mkdir "$RESULTS_DIR"

    if [[ ! -z "$1" ]]; then
        echo "[INFO] Copying setup script"
        cp "$1" "$RESULTS_DIR"
    fi
fi

echo "[INFO] Running main program"
echo "[INFO] Getting new test lists"
(
    cd $DT_SUBJ

    bash "$DT_SCRIPTS/get-test-order.sh"
    bash "$DT_SCRIPTS/find-test-list.sh" old auto
)

echo "[INFO] Removing old dt lists"
rm -rf "$DT_ROOT/data/prioritization-dt-list/prioritization-$SUBJ_NAME"*
rm -rf "$DT_ROOT/data/selection-dt-list/selection-$SUBJ_NAME"*
rm -rf "$DT_ROOT/data/parallelization-dt-list/parallelization-$SUBJ_NAME"*

if [[ -d "$RESULTS_DIR/precomputed" ]]; then
    echo "[INFO] Removing old results files at $RESULTS_DIR/precomputed"
    rm -rf "$RESULTS_DIR/precomputed"
    rm -rf "$RESULTS_DIR/dt-lists"
fi

# Calculate new precomputed dependencies
echo "[INFO] Computing precomputed dependencies"
bash run-precomputed-dependencies.sh

