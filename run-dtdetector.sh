#!/usr/bin/env bash

# $1 - Optional. Location of the setup script to run.
# $2 - Optional (new or old). Whether to run new or old subject. Defaults to 'new'.
# $3 - Optional (orig or auto). Whether to run for the auto tests or the orig tests. Defaults to 'orig'.

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

echo "[INFO] Running main program."

ORDER="orig"
if [[ ! -z "$3" ]]; then
    ORDER="$3"
fi

PREFIX="old"
if [[ ! -z "$2" ]]; then
    if [[ "$2" = "new" ]]; then
        PREFIX="new"
    fi
fi

RANDOMIZE_RESULTS="$RESULTS_DIR/${SUBJ_NAME}-${PREFIX}-${ORDER}-randomize"
if [[ "$PREFIX" = "old" ]]; then
    cd $DT_SUBJ_SRC
    java -Xmx8000M -cp $DT_TOOLS:$DT_TESTS:$DT_CLASS:$DT_LIBS:$DT_RANDOOP: edu.washington.cs.dt.impact.tools.detectors.DetectorMain --mode RANDOM --rounds 1000 --test-order "$DT_SUBJ/${SUBJ_NAME}-${ORDER}-order" --output "$RANDOMIZE_RESULTS"
else
    cd $NEW_DT_SUBJ_SRC
    java -Xmx8000M -cp $DT_TOOLS:$NEW_DT_TESTS:$NEW_DT_CLASS:$NEW_DT_LIBS:$NEW_DT_RANDOOP: edu.washington.cs.dt.impact.tools.detectors.DetectorMain --mode RANDOM --rounds 1000 --test-order "$NEW_DT_SUBJ/${SUBJ_NAME}-${ORDER}-order" --output "$RANDOMIZE_RESULTS"
fi

