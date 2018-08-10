#!/usr/bin/env bash

# Usage: run-precomputed-dependencies.sh [prio|para]
# Should have run setup script before running this script.

source ./constants.sh

STAGE=""
if [[ ! -z "$1" ]]; then
    STAGE="$1"
fi

startTime=`date`

CLASSPATH=$DT_LIBS:$DT_CLASS:$DT_RANDOOP:$DT_TESTS:

# ======================================================

if [[ "$STAGE" == "prio" ]] || [[ -z "$STAGE" ]]; then
    echo "[INFO] Running prioritization-runner script to generate precomputed dependences for $SUBJ_NAME"
    rm -rf $DT_ROOT/${prioDir}
    mkdir $DT_ROOT/${prioDir}
    
    bash ./subj-prio.sh $DT_SUBJ $DT_ROOT $SUBJ_NAME "$SUBJ_NAME_FORMAL" $DT_SUBJ true true false $CLASSPATH
fi

# ======================================================

if [[ "$STAGE" == "para" ]] || [[ -z "$STAGE" ]]; then
    echo "[INFO] Running parallelization-runner script to generate precomputed dependences for $SUBJ_NAME"
    rm -rf $DT_ROOT/${paraDir}
    mkdir $DT_ROOT/${paraDir}
    
    bash ./subj-para.sh $DT_SUBJ $DT_ROOT $SUBJ_NAME "$SUBJ_NAME_FORMAL" $DT_SUBJ true true false $CLASSPATH
fi

# ======================================================

# Generate dt lists
java -cp $DT_TOOLS: edu.washington.cs.dt.impact.tools.OutputPrecomputedDependences -prioDirectory $PRIO_RESULTS -paraDirectory $PARA_RESULTS -prioOutputDirectory "$DT_DATA/$prioList" -seleOutputDirectory "$DT_DATA/$seleList" -paraOutputDirectory "$DT_DATA/$paraList"

echo "[INFO] Copying dt-lists."
RESULTS_DIR="$DT_SCRIPTS/${SUBJ_NAME}-results/dt-lists/"
mkdir -p "$RESULTS_DIR/$prioList"
mv "$DT_ROOT/data/$prioList/*${SUBJ_NAME_FORMAL}*" "$RESULTS_DIR/$prioList"
mkdir -p "$RESULTS_DIR/$seleList"
mv "$DT_ROOT/data/$seleList/*${SUBJ_NAME_FORMAL}*" "$RESULTS_DIR/$seleList"
mkdir -p "$RESULTS_DIR/$paraList"
mv "$DT_ROOT/data/$paraList/*${SUBJ_NAME_FORMAL}*" "$RESULTS_DIR/$paraList"

# Defined in constants.sh
copy_results "precomputed"

echo "[INFO] Script has finished running."

echo "[INFO] Start time was ${startTime}"
endTime=`date`
echo "[INFO] End time is ${endTime}"

