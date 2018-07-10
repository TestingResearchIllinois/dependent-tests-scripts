#!/usr/bin/env bash

# Usage: bash copy-auto-tests.sh AUTO_TEST_LOCATION
# Will copy the auto tests from the AUTO_TEST_LOCATION to DT_RANDOOP/.. and NEW_DT_RANDOOP/..
# AUTO_TEST_LOCATION should be the location of the SOURCE files to copy and use.
# These locations are chosen because DT_RANDOOP and NEW_DT_RANDOOP refer to locations that contain the .class files.
# Then removes tests than do not compile and generates the test order lists.

set -e

AUTO_TEST_LOCATION="$1"

mkdir -p "$NEW_DT_RANDOOP"
cp "$AUTO_TEST_LOCATION"/*.java "$NEW_DT_RANDOOP/.."

cd "$NEW_DT_RANDOOP/.."
echo "[DEBUG] Removing incompatible auto tests."
mkdir -p out/

# TODO: Update randoop so below is no longer necessary (hopefully).
# Don't include randoop.jar because it includes an incompatible version of javaparser.
TOOLS=$(find "$DT_TOOLS_DIR" -name "*.jar" -not -name "randoop.jar")
TOOLS=$(echo $TOOLS | sed -E "s/ /:/g")
java -cp $TOOLS: edu.washington.cs.dt.impact.tools.FailedTestRemover $NEW_DT_LIBS:$NEW_DT_CLASS:$DT_TOOLS: $(ls -1 | grep -E "[0-9]+\.java$")
cp out/*.java .
rm -rf out/

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

