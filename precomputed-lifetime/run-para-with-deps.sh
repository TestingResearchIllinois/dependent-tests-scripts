source ./constants.sh

testTypes=(orig auto)
paraOrders=(original time)

CLASSPATH=$NEW_DT_LIBS:$NEW_DT_CLASS:$NEW_DT_TESTS:$NEW_DT_RANDOOP:

# Set the pwd dependening on classpath/version
. "$DT_SCRIPTS/set-directory.sh" $DT_SUBJ $NEW_DT_SUBJ $CLASSPATH

rm -rf "$DT_ROOT/$paraDir"
mkdir -p $DT_ROOT/$paraDir

for j in "${testTypes[@]}"; do
    echo "[INFO] Running parallelizaiton for $j test type"
    java -cp $DT_TOOLS: edu.washington.cs.dt.impact.runner.OneConfigurationRunner \
        -technique prioritization \
        -coverage statement \
        -order original \
        -origOrder $NEW_DT_SUBJ/$SUBJ_NAME-$j-order \
        -testInputDir $DT_SUBJ/sootTestOutput-$j \
        -filesToDelete $NEW_DT_SUBJ/$SUBJ_NAME-env-files \
        -project "$SUBJ_NAME_FORMAL" \
        -testType $j \
        -outputDir $DT_ROOT/$paraDir \
        -timesToRun $medianTimes \
        -getCoverage \
        -classpath "$CLASSPATH" \
        $postProcessFlag

    for k in "${machines[@]}"; do
        for order in "${paraOrders[@]}"; do
            timeFlag=""
            if [[ "$order" == "time" ]]; then
                timeFlag="-timeOrder $DT_SUBJ/$SUBJ_NAME-$j-time.txt"
            fi

            # [INFO] Running parallelization and without dependentTestFile for time order
            echo "[DEBUG] java -cp $DT_TOOLS: edu.washington.cs.dt.impact.runner.OneConfigurationRunner \
                -technique parallelization \
                -order $order \
                $timeFlag \
                -origOrder $NEW_DT_SUBJ/$SUBJ_NAME-$j-order \
                -testInputDir $DT_SUBJ/sootTestOutput-$j \
                -filesToDelete $NEW_DT_SUBJ/$SUBJ_NAME-env-files \
                -numOfMachines $k \
                -project "$SUBJ_NAME_FORMAL" \
                -testType $j \
                -timesToRun $medianTimes \
                -outputDir $DT_ROOT/$paraDir \
                -classpath \"$CLASSPATH\" \
                $postProcessFlag"
            java -cp $DT_TOOLS: edu.washington.cs.dt.impact.runner.OneConfigurationRunner \
                -technique parallelization \
                -order $order \
                $timeFlag \
                -origOrder $NEW_DT_SUBJ/$SUBJ_NAME-$j-order \
                -testInputDir $DT_SUBJ/sootTestOutput-$j \
                -filesToDelete $NEW_DT_SUBJ/$SUBJ_NAME-env-files \
                -numOfMachines $k \
                -project "$SUBJ_NAME_FORMAL" \
                -testType $j \
                -timesToRun $medianTimes \
                -outputDir $DT_ROOT/$paraDir \
                -classpath "$CLASSPATH" \
                $postProcessFlag

            # Run with dependentTestFile
            echo "[DEBUG] java -cp $DT_TOOLS: edu.washington.cs.dt.impact.runner.OneConfigurationRunner \
                -technique parallelization \
                -order $order \
                $timeFlag \
                -origOrder $NEW_DT_SUBJ/$SUBJ_NAME-$j-order \
                -testInputDir $DT_SUBJ/sootTestOutput-$j \
                -filesToDelete $NEW_DT_SUBJ/$SUBJ_NAME-env-files \
                -numOfMachines $k \
                -project "$SUBJ_NAME_FORMAL" \
                -testType $j \
                -timesToRun $medianTimes \
                -outputDir $DT_ROOT/$paraDir \
                -classpath $CLASSPATH \
                -dependentTestFile $PARA_DT_LISTS/\"parallelization-$SUBJ_NAME_FORMAL-$j-$k-$order.txt\" \
                $postProcessFlag"
            java -cp $DT_TOOLS: edu.washington.cs.dt.impact.runner.OneConfigurationRunner \
                -technique parallelization \
                -order $order \
                $timeFlag \
                -origOrder $NEW_DT_SUBJ/$SUBJ_NAME-$j-order \
                -testInputDir $DT_SUBJ/sootTestOutput-$j \
                -filesToDelete $NEW_DT_SUBJ/$SUBJ_NAME-env-files \
                -numOfMachines $k \
                -project "$SUBJ_NAME_FORMAL" \
                -testType $j \
                -timesToRun $medianTimes \
                -outputDir $DT_ROOT/$paraDir \
                -classpath "$CLASSPATH" \
                -dependentTestFile $PARA_DT_LISTS/"parallelization-$SUBJ_NAME_FORMAL-$j-$k-$order.txt"
                $postProcessFlag
        done
    done

    clearTemp
done
