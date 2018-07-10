source ./constants.sh

testTypes=(orig auto)

CLASSPATH=$NEW_DT_LIBS:$NEW_DT_CLASS:$NEW_DT_TESTS:$NEW_DT_RANDOOP:

# Set the pwd dependening on classpath/version
. "$DT_SCRIPTS/set-directory.sh" $DT_SUBJ $NEW_DT_SUBJ $CLASSPATH

mkdir -p $DT_ROOT/$prioDir

for k in "${testTypes[@]}"; do
    echo "[INFO] Running prioritization for $k test type"
    echo "$(pwd)"
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
      $postProcessFlag

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
                $postProcessFlag"
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
                $postProcessFlag

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
                -dependentTestFile $PRIO_DT_LISTS/\"prioritization-$SUBJ_NAME_FORMAL-$k-$i-$j.txt\""
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
                -dependentTestFile $PRIO_DT_LISTS/"prioritization-$SUBJ_NAME_FORMAL-$k-$i-$j.txt" \
                $postProcessFlag
        done
    done
done

