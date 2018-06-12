#!/usr/bin/env bash

# Usage: run-enhanced.sh [prio|sele|para]
# Should have run setup script before running this script.

source ./constants.sh

startTime=`date`

CLASSPATH=$NEW_DT_LIBS:$NEW_DT_CLASS:$NEW_DT_RANDOOP:$NEW_DT_TESTS:

STAGE=$1

# ======================================================

if [[ "$STAGE" == "prio" ]] || [[ -z "$STAGE" ]]; then
    echo "[INFO] Running prioritization-runner script for $SUBJ_NAME (in $DT_SUBJ)"
    rm -rf $DT_ROOT/${prioDir}
    mkdir $DT_ROOT/${prioDir}
    
    bash ./subj-prio.sh $DT_SUBJ $DT_ROOT $SUBJ_NAME "$SUBJ_NAME_FORMAL" $NEW_DT_SUBJ true false true $CLASSPATH
fi

# ======================================================

if [[ "$STAGE" == "sele" ]] || [[ -z "$STAGE" ]]; then
    echo "[INFO] Running selection-runner script for $SUBJ_NAME (in $DT_SUBJ)"
    rm -rf $DT_ROOT/${seleDir}
    mkdir $DT_ROOT/${seleDir}
    
    bash ./subj-sele.sh $DT_SUBJ $DT_ROOT $SUBJ_NAME "$SUBJ_NAME_FORMAL" $NEW_DT_SUBJ true true $CLASSPATH
fi

# ======================================================

if [[ "$STAGE" == "para" ]] || [[ -z "$STAGE" ]]; then
    echo "[INFO] Running parallelization-runner script for $SUBJ_NAME (in $DT_SUBJ)"
    rm -rf $DT_ROOT/${paraDir}
    mkdir $DT_ROOT/${paraDir}
    
    bash ./subj-para.sh $DT_SUBJ $DT_ROOT $SUBJ_NAME "$SUBJ_NAME_FORMAL" $NEW_DT_SUBJ true false true $CLASSPATH
fi

# ======================================================

# Defined in constants.sh
copy_results "enhanced"

echo "[INFO] Script has finished running."

echo "[INFO] Start time was ${startTime}"
endTime=`date`
echo "[INFO] End time is ${endTime}"

