#!/bin/bash

# Runs commands for "Instructions to setup a subject for test prioritization" section.

set -e

# 1. Find the human-written tests in the old subject.
cd $DT_SUBJ
echo "[DEBUG] Finding human written tests in old subject."
bash "$DT_SCRIPTS/find-test-list.sh" old orig

# 2. Instrument the source and test files.
# java -cp $DT_TOOLS:$DT_LIBS:$DT_CLASS:$DT_TESTS:$JAVA_HOME/jre/lib/*: edu.washington.cs.dt.impact.Main.InstrumentationMain -inputDir $DT_TESTS
echo "[DEBUG] Instrumenting source and test files for old subject."
java -cp $DT_TOOLS:$JAVA_HOME/jre/lib/*: edu.washington.cs.dt.impact.Main.InstrumentationMain -inputDir $DT_TESTS --soot-cp $DT_LIBS:$DT_CLASS:$DT_TESTS:$JAVA_HOME/jre/lib/*
# java -cp $DT_TOOLS:$DT_LIBS:$DT_CLASS:$JAVA_HOME/jre/lib/*: edu.washington.cs.dt.impact.Main.InstrumentationMain -inputDir $DT_CLASS
java -cp $DT_TOOLS:$JAVA_HOME/jre/lib/*: edu.washington.cs.dt.impact.Main.InstrumentationMain -inputDir $DT_CLASS --soot-cp $DT_LIBS:$DT_CLASS:$JAVA_HOME/jre/lib/*

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

# 3. Run the instrumented tests.
echo "[DEBUG] Running instrumented tests."
cd $DT_SUBJ_SRC
java -cp $DT_TOOLS: edu.washington.cs.dt.main.ImpactMain -classpath $DT_LIBS:$DT_SUBJ/sootOutput/: -inputTests $DT_SUBJ/$SUBJ_NAME-orig-order
mv sootTestOutput/ $DT_SUBJ/sootTestOutput-orig
cd $DT_SUBJ
rm -rf sootOutput/

