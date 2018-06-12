source ./constants.sh

testTypes=(orig)

CLASSPATH=$NEW_DT_LIBS:$NEW_DT_CLASS:$NEW_DT_TESTS:

# Set the pwd dependening on classpath/version
. "$DT_SCRIPTS/set-directory.sh" $DT_SUBJ $NEW_DT_SUBJ $CLASSPATH

mkdir -p $DT_ROOT/$paraDir

for j in "${testTypes[@]}"; do
    for k in "${machines[@]}"; do
        # Run for para-orig.
        echo "[DEBUG] java -cp $DT_TOOLS: edu.washington.cs.dt.impact.runner.OneConfigurationRunner \
            -technique parallelization \
            -order original \
            -origOrder $NEW_DT_SUBJ/$SUBJ_NAME-$j-order \
            -testInputDir $DT_SUBJ/sootTestOutput-$j \
            -filesToDelete $NEW_DT_SUBJ/$SUBJ_NAME-env-files \
            -project "$SUBJ_NAME_FORMAL" \
            -testType $j \
            -numOfMachines $k \
            -outputDir $DT_ROOT/$paraDir \
            -timesToRun $medianTimes \
            -classpath \"$CLASSPATH\" \
            -dependentTestFile $PARA_DT_LISTS/\"parallelization-$SUBJ_NAME_FORMAL-$j-$k-original.txt\""
        java -cp $DT_TOOLS: edu.washington.cs.dt.impact.runner.OneConfigurationRunner \
            -technique parallelization \
            -order original \
            -origOrder $NEW_DT_SUBJ/$SUBJ_NAME-$j-order \
            -testInputDir $DT_SUBJ/sootTestOutput-$j \
            -filesToDelete $NEW_DT_SUBJ/$SUBJ_NAME-env-files \
            -project "$SUBJ_NAME_FORMAL" \
            -testType $j \
            -numOfMachines $k \
            -outputDir $DT_ROOT/$paraDir \
            -timesToRun $medianTimes \
            -classpath "$CLASSPATH" \
            -dependentTestFile $PARA_DT_LISTS/"parallelization-$SUBJ_NAME_FORMAL-$j-$k-original.txt"

        # Run it for para-time.
        echo "[DEBUG] java -cp $DT_TOOLS: edu.washington.cs.dt.impact.runner.OneConfigurationRunner \
            -technique parallelization \
            -order time \
            -timeOrder $DT_SUBJ/$SUBJ_NAME-$j-time.txt \
            -origOrder $NEW_DT_SUBJ/$SUBJ_NAME-$j-order \
            -testInputDir $DT_SUBJ/sootTestOutput-$j \
            -filesToDelete $NEW_DT_SUBJ/$SUBJ_NAME-env-files \
            -numOfMachines $k \
            -project "$SUBJ_NAME_FORMAL" \
            -testType $j \
            -timesToRun $medianTimes \
            -outputDir $DT_ROOT/$paraDir \
            -classpath $CLASSPATH \
            -dependentTestFile $PARA_DT_LISTS/\"parallelization-$SUBJ_NAME_FORMAL-$j-$k-time.txt\""
        java -cp $DT_TOOLS: edu.washington.cs.dt.impact.runner.OneConfigurationRunner \
            -technique parallelization \
            -order time \
            -timeOrder $DT_SUBJ/$SUBJ_NAME-$j-time.txt \
            -origOrder $NEW_DT_SUBJ/$SUBJ_NAME-$j-order \
            -testInputDir $DT_SUBJ/sootTestOutput-$j \
            -filesToDelete $NEW_DT_SUBJ/$SUBJ_NAME-env-files \
            -numOfMachines $k \
            -project "$SUBJ_NAME_FORMAL" \
            -testType $j \
            -timesToRun $medianTimes \
            -outputDir $DT_ROOT/$paraDir \
            -classpath "$CLASSPATH" \
            -dependentTestFile $PARA_DT_LISTS/"parallelization-$SUBJ_NAME_FORMAL-$j-$k-time.txt"
    done

    clearTemp
done
