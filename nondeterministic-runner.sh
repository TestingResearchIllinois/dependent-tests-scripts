#!/usr/bin/env bash

# $1 - Optional. Location of the setup script to run.
# $2 - Optional (new or old). Whether to run new or old subject. Defaults to 'old'.
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

source $DT_SCRIPTS/config.sh

startTime=$(date +%s)

version="old"
if [[ ! -z "$2" ]]; then
    version="$2"
fi

testType="orig"
if [[ ! -z "$3" ]]; then
    testType="$3"
fi

numTimesToRun=100

if [[ "$version" == "old" ]]; then
    if [[ "$testType" == "orig" ]]; then
        experimentCP=$DT_TOOLS:$DT_CLASS:$DT_TESTS:$DT_LIBS:
    else
        experimentCP=$DT_TOOLS:$DT_CLASS:$DT_RANDOOP:$DT_LIBS:
    fi
    testOrder=$DT_SUBJ/${SUBJ_NAME}-${testType}-order
else
    if [[ "$testType" == "orig" ]]; then
        experimentCP=$DT_TOOLS:$NEW_DT_CLASS:$NEW_DT_TESTS:$NEW_DT_LIBS:
    else
        experimentCP=$DT_TOOLS:$NEW_DT_CLASS:$NEW_DT_RANDOOP:$NEW_DT_LIBS:
    fi
    testOrder=$NEW_DT_SUBJ/${SUBJ_NAME}-${testType}-order
fi

RESULTS_DIR="$DT_SCRIPTS/${SUBJ_NAME}-results"
NONDETERMINISTIC_FOLDER="$RESULTS_DIR/${SUBJ_NAME}-${version}-${testType}-nondeterministic"

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

echo "[INFO] Results will be written to $RESULTS_DIR/$NONDETERMINISTIC_FOLDER"
echo "[INFO] Running main program."

if [[ "$version" == "new" ]]; then
    cd $NEW_DT_SUBJ_SRC
else
    cd $DT_SUBJ_SRC
fi

java -Xmx8000M -cp $experimentCP: edu.washington.cs.dt.impact.tools.detectors.DetectorMain --mode NONDETERMINISTIC --rounds 1000 --test-order "$testOrder" --output "$NONDETERMINISTIC_FOLDER/dt-lists.txt"

# Make sure we ignore the nondeterministic tests for everything else.
if [[ -e "$RESULTS_DIR/${SUBJ_NAME}-ignore-order" ]]; then
    cat "list.txt" "$RESULTS_DIR/${SUBJ_NAME}-ignore-order" | sort | uniq > temp
    mv temp "$RESULTS_DIR/${SUBJ_NAME}-ignore-order"
else
    cp "list.txt" "$RESULTS_DIR/${SUBJ_NAME}-ignore-order"
fi

echo "[INFO] Finished. Found $(cat nondeterministic-list.txt | wc -l) nondeterministic tests."

