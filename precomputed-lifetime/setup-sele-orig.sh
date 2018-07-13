#!/bin/bash

# Runs commands for "Instructions to setup a subject for test selection" section.

set -e

# 3. Generate the static information needed by test selection for the new version of the subject.
cd $NEW_DT_SUBJ
echo "[DEBUG] Instrumenting the new subject for selection."
java -cp $DT_TOOLS:$JAVA_HOME/jre/lib/*: edu.washington.cs.dt.impact.Main.InstrumentationMain --soot-cp $NEW_DT_LIBS:$NEW_DT_CLASS:$JAVA_HOME/jre/lib/*: -inputDir $NEW_DT_CLASS -technique selection --java-version 1.8
rm -rf sootOutput/

