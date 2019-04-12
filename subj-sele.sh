# Usage: subj-sele.sh $DT_SUBJ $DT_ROOT $SUBJ_NAME $SUBJ_NAME_FORMAL $NEW_DT_SUBJ true true ...
# Usage: subj-sele.sh $DT_SUBJ $DT_ROOT $SUBJ_NAME $SUBJ_NAME_FORMAL $NEW_DT_SUBJ false true $DT_TOOLS $DT_LIBS $DT_CLASS $DT_RANDOOP $DT_TESTS

source ./constants.sh

DT_SUBJ=$1
DT_ROOT=$2
SUBJ_NAME=$3
SUBJ_NAME_FORMAL=$4
NEW_DT_SUBJ=$5

PRESET_CP=$6
if [ "$PRESET_CP" = "true" ]; then
  CLASSPATH=$8
else
  DT_TOOLS=$8
  DT_LIBS=$9
  DT_CLASS=${10}
  DT_RANDOOP=${11}
  DT_TESTS=${12}

  CLASSPATH=$DT_LIBS:$DT_CLASS:$DT_RANDOOP:$DT_TESTS:$DT_TOOLS
fi

GEN_ENHANCED_RESULTS=$7

if ! bash check-compiled.sh $CLASSPATH; then
    exit 1
fi

# Set the pwd dependening on classpath/version
. set-directory.sh $DT_SUBJ $NEW_DT_SUBJ $CLASSPATH

for p in "${postProcessFlags[@]}"; do

    for k in "${testTypes[@]}"; do

      if [ "$GEN_ENHANCED_RESULTS" = "true" ]; then
        echo "[INFO] Running prioritization for ${testTypes[@]} test type"
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
          $p
      fi

      for i in "${coverages[@]}"; do
        for j in "${seleOrders[@]}"; do

          if [ "$GEN_ENHANCED_RESULTS" = "true" ]; then
            # [INFO] Running selection without resolveDependences and with dependentTestFile
            echo "[DEBUG] java -cp $DT_TOOLS: edu.washington.cs.dt.impact.runner.OneConfigurationRunner \
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
              $p"
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
              $p
          fi

          # [INFO] Running selection without resolveDependences and without dependentTestFile
          echo "[DEBUG] java -cp $DT_TOOLS: edu.washington.cs.dt.impact.runner.OneConfigurationRunner \
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
            $p"
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
            $p
        done
      done
    done
done
