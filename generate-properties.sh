#!/usr/bin/env bash

# Usage: bash generate-properties.sh SETUP_SCRIPT

# Run the setup script
CURRENT=$(pwd)

SCRIPT_DIR=$(dirname "$1")
SCRIPT_NAME=$(basename "$1")

echo "[INFO] Running setup script $SCRIPT_NAME in $SCRIPT_DIR"

cd $SCRIPT_DIR
. "$SCRIPT_NAME"

cd $CURRENT

DIR="$DT_SCRIPTS/$SUBJ_NAME-results/enhanced"

go() {
    java -cp $DT_TOOLS: edu.washington.cs.dt.impact.tools.GetAllUniqueDTs -prioDirectory $DIR/$1 -paraDirectory temp/ -seleDirectory temp/ -minBoundOrigDTFile orig -minBoundAutoDTFile auto > /dev/null
    origNum=$(cat orig | head -1 | cut -f2 -d"|")
    autoNum=$(cat auto | head -1 | cut -f2 -d"|")

    echo "subject.$2.orig.dts=$origNum"
    echo "subject.$2.auto.dts=$autoNum"

    > orig 
    > auto
}

(
    echo "subject.name=$SUBJ_NAME"
    echo "subject.formal_name=$SUBJ_NAME_FORMAL"
    go prioritization-results prio
    go selection-results sele
    go parallelization-results para
) | tee "$DIR/../subject.properties"

