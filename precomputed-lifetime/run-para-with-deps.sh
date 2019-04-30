source ./constants.sh

CLASSPATH=$NEW_DT_LIBS:$NEW_DT_CLASS:$NEW_DT_TESTS:$NEW_DT_RANDOOP:$DT_TOOLS:

# Set the pwd dependening on classpath/version
. "$DT_SCRIPTS/set-directory.sh" $DT_SUBJ $NEW_DT_SUBJ $CLASSPATH

mkdir -p $DT_ROOT/$paraDir

testTypes=($1)
echo "Test types set to $testTypes"

for post in "${postProcessFlags[@]}"; do
    if [ "$post" = "" ]; then
        p=false
    else
        p=true
    fi

    for j in "${testTypes[@]}"; do
        echo "[INFO] Running parallelizaiton for $j test type"
        echo "Para $j start time is $(date)"

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
                    $post"
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
                    $post

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
                    -dependentTestFile $PARA_DT_LISTS/\"parallelization-$SUBJ_NAME_FORMAL-$j-$k-$order-$p.txt\" \
                    $post"
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
                    -dependentTestFile $PARA_DT_LISTS/"parallelization-$SUBJ_NAME_FORMAL-$j-$k-$order-$p.txt" \
                    $post
            done
        done

        clearTemp
        echo "Para $j end time is $(date)"
    done
done
