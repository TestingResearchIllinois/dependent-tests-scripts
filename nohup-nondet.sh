#!/usr/bin/env bash

# Usage: bash nohup-nondet.sh <setup-script-path>

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

echo "[INFO] nohup bash nondeterministic-runner.sh $1 &> \"$DT_SCRIPTS/${SUBJ_NAME}-results/${SUBJ_NAME}-nondeterministic.txt\" &"
nohup bash nondeterministic-runner.sh $1 &> "$DT_SCRIPTS/${SUBJ_NAME}-results/${SUBJ_NAME}-nondeterministic.txt" &

