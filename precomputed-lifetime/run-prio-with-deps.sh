source ./constants.sh

testTypes=(orig)

CLASSPATH=$NEW_DT_LIBS:$NEW_DT_CLASS:$NEW_DT_TESTS:

# Set the pwd dependening on classpath/version
. "$DT_SCRIPTS/set-directory.sh" $DT_SUBJ $NEW_DT_SUBJ $CLASSPATH

mkdir -p $DT_ROOT/$prioDir

for k in "${testTypes[@]}"; do
    for i in "${coverages[@]}"; do
        for j in "${priorOrders[@]}"; do
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
              -dependentTestFile $PRIO_DT_LISTS/"prioritization-$SUBJ_NAME_FORMAL-$k-$i-$j.txt"
        done
    done
done

