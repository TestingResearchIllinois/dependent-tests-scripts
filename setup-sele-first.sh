#!/usr/bin/env bash

# Runs commands for "Instructions to setup a subject for test selection" section.

set -e

# 1. Generate the static information needed by test selection for the old version of the subject.
cd $DT_SUBJ
echo "[DEBUG] Instrumenting subject for selection (\$DT_TESTS)."
java -cp $DT_TOOLS:$JAVA_HOME/jre/lib/*: edu.washington.cs.dt.impact.Main.InstrumentationMain -inputDir $DT_TESTS --soot-cp $DT_LIBS:$DT_CLASS:$DT_TESTS:$JAVA_HOME/jre/lib/*: -technique selection
echo "[DEBUG] Instrumenting subject for selection (\$DT_RANDOOP)."
java -cp $DT_TOOLS:$JAVA_HOME/jre/lib/*: edu.washington.cs.dt.impact.Main.InstrumentationMain -inputDir $DT_RANDOOP --soot-cp $DT_LIBS:$DT_CLASS:$DT_RANDOOP:$JAVA_HOME/jre/lib/*: -technique selection
echo "[DEBUG] Instrumenting subject for selection (\$DT_CLASS)."
java -cp $DT_TOOLS:$JAVA_HOME/jre/lib/*: edu.washington.cs.dt.impact.Main.InstrumentationMain -inputDir $DT_CLASS --soot-cp $DT_LIBS:$DT_CLASS:$JAVA_HOME/jre/lib/*: -technique selection

# Copy over any resource files from the classes/ and test-classes/ directories (e.g. configuration files).
# Make sure we don't copy any .class files though.
cd classes/
find . -iname "*.class" -printf "%P\n" > ../exclude-list.txt
cd ..
rsync -av classes/ sootOutput/ --exclude-from=exclude-list.txt

cd test-classes/
find . -name "*.class" -printf "%P\n" > ../exclude-list.txt
cd ..
rsync -av test-classes/ sootOutput/ --exclude-from=exclude-list.txt

# 2. Run the instrumented tests.
cd $DT_SUBJ_SRC
echo "[DEBUG] Running the instrumented auto tests."
java -cp $DT_TOOLS: edu.washington.cs.dt.main.ImpactMain -classpath $DT_LIBS:$DT_SUBJ/sootOutput/: -inputTests $DT_SUBJ/$SUBJ_NAME-auto-order
mv sootTestOutput/ $DT_SUBJ/sootTestOutput-auto-selection
echo "[DEBUG] Running the instrumented human-written tests."
java -cp $DT_TOOLS: edu.washington.cs.dt.main.ImpactMain -classpath $DT_LIBS:$DT_SUBJ/sootOutput/: -inputTests $DT_SUBJ/$SUBJ_NAME-orig-order
mv sootTestOutput/ $DT_SUBJ/sootTestOutput-orig-selection

cd $DT_SUBJ
rm -rf sootOutput/

