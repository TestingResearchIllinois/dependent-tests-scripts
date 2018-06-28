#!/usr/bin/env bash

# Usage: bash setup-sele.sh
# NOTE: This will only setup selection for the new subject!

set -e

cd $NEW_DT_SUBJ
echo "[DEBUG] Instrumenting the new subject for selection."
java -cp $DT_TOOLS:$JAVA_HOME/jre/lib/*: edu.washington.cs.dt.impact.Main.InstrumentationMain --soot-cp $NEW_DT_LIBS:$NEW_DT_CLASS:$JAVA_HOME/jre/lib/*: -inputDir $NEW_DT_CLASS -technique selection
rm -rf sootOutput/

