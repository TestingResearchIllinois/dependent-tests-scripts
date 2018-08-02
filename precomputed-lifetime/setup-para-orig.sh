#!/bin/bash

# Runs commands for "Instructions to setup a subject for test parallelization" section.

set -e

# 1. Get the time each test took to run.
cd $DT_SUBJ_SRC

if [[ ! -e "$DT_SUBJ/$SUBJ_NAME-orig-time.txt" ]]; then
    echo "[DEBUG] Getting time for orig tests."
    java -cp $DT_TOOLS: edu.washington.cs.dt.main.ImpactMain -classpath $DT_LIBS:$DT_CLASS:$DT_TESTS: -inputTests $DT_SUBJ/$SUBJ_NAME-orig-order -getTime > $DT_SUBJ/$SUBJ_NAME-orig-time.txt
fi

