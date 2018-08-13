#!/usr/bin/env bash

# Usage: bash run-sele-with-deps.sh DT_SUBJ
# NOTE: Environment variables should have been set before running this.
# NOTE: This script cannot be easily replaced the the subj-sele script in the
#       normal scripts directory because of DT_SUBJ.

source ./constants.sh

testTypes=(orig auto)

CLASSPATH=$NEW_DT_LIBS:$NEW_DT_CLASS:$NEW_DT_TESTS:$NEW_DT_RANDOOP:

# Set the pwd dependening on classpath/version
. "$DT_SCRIPTS/set-directory.sh" $DT_SUBJ $NEW_DT_SUBJ $CLASSPATH

mkdir -p "$DT_ROOT/$seleDir"

for k in "${testTypes[@]}"; do
    echo "[INFO] Running selection for $k test type"
    java -cp $DT_TOOLS: edu.washington.cs.dt.impact.runner.OneConfigurationRunner \
        -technique prioritization \
        -coverage statement \
        -order original \
        -origOrder $NEW_DT_SUBJ/$SUBJ_NAME-$k-order \
        -testInputDir $DT_SUBJ/sootTestOutput-$k-selection \
        -filesToDelete $NEW_DT_SUBJ/$SUBJ_NAME-env-files \
        -project "$SUBJ_NAME_FORMAL" \
        -testType $k \
        -outputDir $DT_ROOT/$seleDir \
        -timesToRun $medianTimes \
        -classpath "$CLASSPATH" \
        -getCoverage \
        $postProcessFlag

    for i in "${coverages[@]}"; do
        for j in "${seleOrders[@]}"; do
            # [INFO] Running selection without dependentTestFile
            java -cp $DT_TOOLS: edu.washington.cs.dt.impact.runner.OneConfigurationRunner \
                -technique selection \
                -coverage $i \
                -order $j \
                -origOrder $NEW_DT_SUBJ/$SUBJ_NAME-$k-order \
                -testInputDir $DT_SUBJ/sootTestOutput-$k-selection \
                -filesToDelete $NEW_DT_SUBJ/$SUBJ_NAME-env-files \
                -project "$SUBJ_NAME_FORMAL" \
                -testType $k \
                -oldVersCFG $DT_SUBJ/selectionOutput \
                -newVersCFG $NEW_DT_SUBJ/selectionOutput \
                -getCoverage \
                -outputDir $DT_ROOT/$seleDir \
                -classpath "$CLASSPATH" \
                -timesToRun $medianTimes \
                $postProcessFlag

            # [INFO] Running selection with dependentTestFile
            java -cp $DT_TOOLS: edu.washington.cs.dt.impact.runner.OneConfigurationRunner \
                -technique selection \
                -coverage $i \
                -order $j \
                -origOrder $NEW_DT_SUBJ/$SUBJ_NAME-$k-order \
                -testInputDir $DT_SUBJ/sootTestOutput-$k-selection \
                -filesToDelete $NEW_DT_SUBJ/$SUBJ_NAME-env-files \
                -project "$SUBJ_NAME_FORMAL" \
                -testType $k \
                -oldVersCFG $DT_SUBJ/selectionOutput \
                -newVersCFG $NEW_DT_SUBJ/selectionOutput \
                -getCoverage \
                -outputDir $DT_ROOT/$seleDir \
                -timesToRun $medianTimes \
                -classpath "$CLASSPATH" \
                -dependentTestFile $SELE_DT_LISTS/"selection-$SUBJ_NAME_FORMAL-$k-$i-$j.txt" \
                $postProcessFlag
        done
    done
done

