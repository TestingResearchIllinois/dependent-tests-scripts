#!/usr/bin/env bash

# Usage: bash copy-auto-tests.sh AUTO_TEST_LOCATION
# Will copy the auto tests from the AUTO_TEST_LOCATION to DT_RANDOOP/.. and NEW_DT_RANDOOP/..
# AUTO_TEST_LOCATION should be the location of the SOURCE files to copy and use.
# These locations are chosen because DT_RANDOOP and NEW_DT_RANDOOP refer to locations that contain the .class files.
# Then removes tests than do not compile and generates the test order lists.

set -e

AUTO_TEST_LOCATION="$1"

mkdir -p "$DT_RANDOOP"
cp "$AUTO_TEST_LOCATION"/*.java "$DT_RANDOOP/.."

cd "$DT_RANDOOP/.."
echo "[DEBUG] Removing incompatible auto tests."
java -cp $DT_TOOLS: edu.washington.cs.dt.impact.tools.FailedTestRemover $DT_LIBS:$DT_CLASS:$DT_TOOLS: "$DT_RANDOOP"/*.java

#execute the correct javac line depending on situation to compile auto tests
tcount=`ls -1 ErrorTest*.java 2>/dev/null | wc -l`
echo "[DEBUG] Compiling auto tests with new subject."
if [ $tcount != 0 ]; then
    javac -cp $DT_LIBS:$DT_CLASS:$DT_TOOLS: ErrorTest*.java RegressionTest*.java
else
    javac -cp $DT_LIBS:$DT_CLASS:$DT_TOOLS: RegressionTest*.java
fi

mkdir -p bin
mv *.class bin/

# Find the automatically generated tests in the subject.
cd $DT_SUBJ
echo "[DEBUG] Finding auto tests in old subject."
bash "$DT_SCRIPTS/find-test-list.sh" old auto

if [[ "$INSTRMENT" == "true" ]]; then
    echo "[DEBUG] Instrumenting auto tests."
    java -cp $DT_TOOLS:$JAVA_HOME/jre/lib/*: edu.washington.cs.dt.impact.Main.InstrumentationMain --soot-cp $DT_LIBS:$DT_CLASS:$DT_RANDOOP:$JAVA_HOME/jre/lib/*: -inputDir $DT_RANDOOP
    java -cp $DT_TOOLS:$DT_LIBS:$DT_CLASS:$JAVA_HOME/jre/lib/*: edu.washington.cs.dt.impact.Main.InstrumentationMain -inputDir $DT_CLASS --soot-cp $DT_LIBS:$DT_CLASS:$JAVA_HOME/jre/lib/*:

    echo "[DEBUG] Running instrumented auto tests."
    cd $DT_SUBJ_SRC
    java -cp $DT_TOOLS: edu.washington.cs.dt.main.ImpactMain -classpath $DT_LIBS:$DT_SUBJ/sootOutput/: -inputTests $DT_SUBJ/$SUBJ_NAME-auto-order
    mv sootTestOutput/ $DT_SUBJ/sootTestOutput-auto
    cd $DT_SUBJ
    rm -rf sootOutput/
fi

# Now perform (almost) the same process on the new subject.

mkdir -p "$NEW_DT_RANDOOP"
cp "$AUTO_TEST_LOCATION"/*.java "$NEW_DT_RANDOOP/.."

cd "$DT_RANDOOP/.."
echo "[DEBUG] Removing incompatible auto tests."
java -cp $DT_TOOLS: edu.washington.cs.dt.impact.tools.FailedTestRemover $NEW_DT_LIBS:$NEW_DT_CLASS:$DT_TOOLS: "$RANDOOP"/*.java

#execute the correct javac line depending on situation to compile auto tests
tcount=`ls -1 ErrorTest*.java 2>/dev/null | wc -l`
echo "[DEBUG] Compiling auto tests with new subject."
if [ $tcount != 0 ]; then
    javac -cp $NEW_DT_LIBS:$NEW_DT_CLASS:$DT_TOOLS: ErrorTest*.java RegressionTest*.java
else
    javac -cp $NEW_DT_LIBS:$NEW_DT_CLASS:$DT_TOOLS: RegressionTest*.java
fi

mkdir -p bin
mv *.class bin/

# Find the automatically generated tests in the subject.
cd $NEW_DT_SUBJ
echo "[DEBUG] Finding auto tests in new subject."
bash "$DT_SCRIPTS/find-test-list.sh" new auto

