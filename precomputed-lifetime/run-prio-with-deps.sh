source ./constants.sh

CLASSPATH=$NEW_DT_LIBS:$NEW_DT_CLASS:$NEW_DT_TESTS:$NEW_DT_RANDOOP:$DT_TOOLS:

# Set the pwd dependening on classpath/version
. "$DT_SCRIPTS/set-directory.sh" $DT_SUBJ $NEW_DT_SUBJ $CLASSPATH

mkdir -p "$DT_ROOT/$prioDir"

testTypes=($1)
echo "Test types set to $testTypes"

for post in "${postProcessFlags[@]}"; do
    if [ "$post" = "" ]; then
        p=false
    else
        p=true
    fi

    for k in "${testTypes[@]}"; do
        echo "[INFO] Running prioritization for $k test type"
        echo "$(pwd)"
        echo "Prio $k start time is $(date)"
        java -cp $DT_TOOLS:: edu.washington.cs.dt.impact.runner.OneConfigurationRunner \
          -technique prioritization \
          -coverage statement \
          -order original \
          -origOrder $NEW_DT_SUBJ/$SUBJ_NAME-$k-order \
          -testInputDir $DT_SUBJ/sootTestOutput-$k \
          -filesToDelete $NEW_DT_SUBJ/$SUBJ_NAME-env-files \
          -project "$SUBJ_NAME_FORMAL" \
          -testType $k \
          -outputDir $DT_ROOT/$prioDir \
          -timesToRun $medianTimes \
          -classpath "$CLASSPATH" \
          -getCoverage \
          $post

        for i in "${coverages[@]}"; do
            for j in "${priorOrders[@]}"; do
                # Running prioritization without dependentTestFile
                echo "[DEBUG] java -cp $DT_TOOLS: edu.washington.cs.dt.impact.runner.OneConfigurationRunner \
                    -technique prioritization \
                    -coverage $i \
                    -order $j \
                    -origOrder $NEW_DT_SUBJ/$SUBJ_NAME-$k-order \
                    -testInputDir $DT_SUBJ/sootTestOutput-$k \
                    -filesToDelete $NEW_DT_SUBJ/$SUBJ_NAME-env-files \
                    -getCoverage \
                    -project "$SUBJ_NAME_FORMAL" \
                    -testType $k \
                    -outputDir $DT_ROOT/$prioDir \
                    -timesToRun $medianTimes \
                    -classpath \"$CLASSPATH\" \
                    $post"
                java -cp $DT_TOOLS: edu.washington.cs.dt.impact.runner.OneConfigurationRunner \
                    -technique prioritization \
                    -coverage $i \
                    -order $j \
                    -origOrder $NEW_DT_SUBJ/$SUBJ_NAME-$k-order \
                    -testInputDir $DT_SUBJ/sootTestOutput-$k \
                    -filesToDelete $NEW_DT_SUBJ/$SUBJ_NAME-env-files \
                    -getCoverage \
                    -project "$SUBJ_NAME_FORMAL" \
                    -testType $k \
                    -outputDir $DT_ROOT/$prioDir \
                    -timesToRun $medianTimes \
                    -classpath "$CLASSPATH" \
                    $post

                # Running prioritizaiton with dependentTestFile
                echo "[DEBUG] java -cp $DT_TOOLS: edu.washington.cs.dt.impact.runner.OneConfigurationRunner \
                    -technique prioritization \
                    -coverage $i \
                    -order $j \
                    -origOrder $NEW_DT_SUBJ/$SUBJ_NAME-$k-order \
                    -testInputDir $DT_SUBJ/sootTestOutput-$k \
                    -filesToDelete $NEW_DT_SUBJ/$SUBJ_NAME-env-files \
                    -getCoverage \
                    -project "$SUBJ_NAME_FORMAL" \
                    -testType $k \
                    -outputDir $DT_ROOT/$prioDir \
                    -timesToRun $medianTimes \
                    -classpath \"$CLASSPATH\" \
                    -dependentTestFile $PRIO_DT_LISTS/\"prioritization-$SUBJ_NAME_FORMAL-$k-$i-$j-$p.txt\" \
                    -resolveDependences $PRIO_DT_LISTS/\"prioritization-$SUBJ_NAME_FORMAL-$k-$i-$j-$p.txt\" \
                    -$post"
                java -cp $DT_TOOLS: edu.washington.cs.dt.impact.runner.OneConfigurationRunner \
                    -technique prioritization \
                    -coverage $i \
                    -order $j \
                    -origOrder $NEW_DT_SUBJ/$SUBJ_NAME-$k-order \
                    -testInputDir $DT_SUBJ/sootTestOutput-$k \
                    -filesToDelete $NEW_DT_SUBJ/$SUBJ_NAME-env-files \
                    -getCoverage \
                    -project "$SUBJ_NAME_FORMAL" \
                    -testType $k \
                    -outputDir $DT_ROOT/$prioDir \
                    -timesToRun $medianTimes \
                    -classpath "$CLASSPATH" \
                    -dependentTestFile $PRIO_DT_LISTS/"prioritization-$SUBJ_NAME_FORMAL-$k-$i-$j-$p.txt" \
                    -resolveDependences $PRIO_DT_LISTS/"prioritization-$SUBJ_NAME_FORMAL-$k-$i-$j-$p.txt" \
                    $post
            done
        done
        echo "Prio $k end time is $(date)"
    done
done
