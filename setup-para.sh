#!/bin/bash

# Runs commands for "Instructions to setup a subject for test parallelization" section.

set -e

# 1. Get the time each test took to run.
cd $DT_SUBJ_SRC
echo "[DEBUG] Getting time for auto tests."
echo "[DEBUG] java -cp $DT_TOOLS: edu.washington.cs.dt.impact.Main.RunnerMain -classpath $DT_LIBS:$DT_TOOLS:$DT_CLASS:$DT_RANDOOP: -inputTests $DT_SUBJ/$SUBJ_NAME-auto-order -getTime > $DT_SUBJ/$SUBJ_NAME-auto-time.txt"
java -cp $DT_TOOLS: edu.washington.cs.dt.impact.Main.RunnerMain -classpath $DT_LIBS:$DT_TOOLS:$DT_CLASS:$DT_RANDOOP: -inputTests $DT_SUBJ/$SUBJ_NAME-auto-order -getTime > $DT_SUBJ/$SUBJ_NAME-auto-time.txt
echo "[DEBUG] Getting time for orig tests."
echo "[DEBUG] java -cp $DT_TOOLS: edu.washington.cs.dt.impact.Main.RunnerMain -classpath $DT_LIBS:$DT_TOOLS:$DT_CLASS:$DT_TESTS: -inputTests $DT_SUBJ/$SUBJ_NAME-orig-order -getTime > $DT_SUBJ/$SUBJ_NAME-orig-time.txt"
java -cp $DT_TOOLS: edu.washington.cs.dt.impact.Main.RunnerMain -classpath $DT_LIBS:$DT_TOOLS:$DT_CLASS:$DT_TESTS: -inputTests $DT_SUBJ/$SUBJ_NAME-orig-order -getTime > $DT_SUBJ/$SUBJ_NAME-orig-time.txt

