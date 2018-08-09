source ./newExp-config.sh

function instrumentNewSelectionFiles() {
  cd ${initialDir}/$1
  echo 'Enhanced instrumenting new subject'
  /usr/lib/jvm/java-7-oracle/jre/bin/java -cp $2 edu.washington.cs.dt.impact.Main.InstrumentationMain -inputDir classes -technique selection
  /usr/lib/jvm/java-7-oracle/jre/bin/java -cp $2 edu.washington.cs.dt.impact.Main.InstrumentationMain -inputDir test-classes -technique selection
  /usr/lib/jvm/java-7-oracle/jre/bin/java -cp $2 edu.washington.cs.dt.impact.Main.InstrumentationMain -inputDir randoop/bin/ -technique selection

  cd ${initialDir}/$3

  echo 'Enhanced instrumenting old subject'
  /usr/lib/jvm/java-7-oracle/jre/bin/java -cp $4 edu.washington.cs.dt.impact.Main.InstrumentationMain -inputDir classes -technique selection
  /usr/lib/jvm/java-7-oracle/jre/bin/java -cp $4 edu.washington.cs.dt.impact.Main.InstrumentationMain -inputDir test-classes -technique selection
  /usr/lib/jvm/java-7-oracle/jre/bin/java -cp $4 edu.washington.cs.dt.impact.Main.InstrumentationMain -inputDir randoop/bin/ -technique selection
  cd ${initialDir}
}

#compileSource
#compileNewSource

index=0
count=${#newExperiments[@]}

while [ "$index" -lt "$count" ]; do
  echo -e "Starting experiment: ${newExperiments[$index]}"

  #instrumentNewSelectionFiles ${nextExpDirectories[$index]} ${newExpCP[$index]} ${newExpDirectories[$index]} ${newExpCP[$index]}

  for k in "${newExpTestTypes[@]}"; do

    #cd ${initialDir}/${newExpDirectories[$index]}
    #echo 'Generating sootTestOutput on old subject'
    #java -cp ${newExpSootCP[$index]} edu.washington.cs.dt.main.ImpactMain -inputTests ${initialDir}/${nextExpDirectories[$index]}/${newExperiments[$index]}-$k-order
    #mv sootTestOutput sootTestOutput-$k-selection
    #cd ${initialDir}

    echo 'Running prioritization for original order'
    java -Xms1g -Xmx2g -cp ${nextExpCP[$index]} edu.washington.cs.dt.impact.Main.OneConfigurationRunner -technique prioritization -coverage statement -order original -origOrder ${nextExpDirectories[$index]}/${newExperiments[$index]}-$k-order -testInputDir ${newExpDirectories[$index]}/sootTestOutput-$k-selection -filesToDelete ${nextExpDirectories[$index]}/${newExperiments[$index]}-env-files -project "${newExperimentsName[$index]}" -testType $k -outputDir ${initialDir}/${seleDir} -timesToRun ${medianTimes} -getCoverage

    for i in "${coverages[@]}"; do
      for j in "${seleOrders[@]}"; do
        echo 'Running selection without resolveDependences and with dependentTestFile'
        java -Xms1g -Xmx2g -cp ${nextExpCP[$index]} edu.washington.cs.dt.impact.Main.OneConfigurationRunner -technique selection -coverage $i -order $j -origOrder ${nextExpDirectories[$index]}/${newExperiments[$index]}-$k-order -testInputDir ${newExpDirectories[$index]}/sootTestOutput-$k-selection -filesToDelete ${nextExpDirectories[$index]}/${newExperiments[$index]}-env-files -project "${newExperimentsName[$index]}" -testType $k -oldVersCFG ${newExpDirectories[$index]}/selectionOutput -newVersCFG ${nextExpDirectories[$index]}/selectionOutput -getCoverage -outputDir ${initialDir}/${seleDir} -timesToRun ${medianTimes} -dependentTestFile ${initialDir}/selection-dt-list/"selection-${experimentsName[$index]}-$k-$i-$j.txt"

        echo 'Running selection without resolveDependences and without dependentTestFile'
        java -Xms1g -Xmx2g -cp ${nextExpCP[$index]} edu.washington.cs.dt.impact.Main.OneConfigurationRunner -technique selection -coverage $i -order $j -origOrder ${nextExpDirectories[$index]}/${newExperiments[$index]}-$k-order -testInputDir ${newExpDirectories[$index]}/sootTestOutput-$k-selection -filesToDelete ${nextExpDirectories[$index]}/${newExperiments[$index]}-env-files -project "${newExperimentsName[$index]}" -testType $k -oldVersCFG ${newExpDirectories[$index]}/selectionOutput -newVersCFG ${nextExpDirectories[$index]}/selectionOutput -getCoverage -outputDir ${initialDir}/${seleDir} -timesToRun ${medianTimes}

        #echo 'Running selection with resolveDependences and without dependentTestFile'
        #java -Xms1g -Xmx2g -cp ${nextExpCP[$index]} edu.washington.cs.dt.impact.Main.OneConfigurationRunner -technique selection -coverage $i -order $j -origOrder ${nextExpDirectories[$index]}/${newExperiments[$index]}-$k-order -testInputDir ${newExpDirectories[$index]}/sootTestOutput-$k-selection -filesToDelete ${nextExpDirectories[$index]}/${newExperiments[$index]}-env-files -project "${newExperimentsName[$index]}" -testType $k -oldVersCFG ${newExpDirectories[$index]}/selectionOutput -newVersCFG ${nextExpDirectories[$index]}/selectionOutput -getCoverage -outputDir ${initialDir}/${seleDir} -timesToRun ${medianTimes} -resolveDependences ${initialDir}/selection-dt-list/"selection-${experimentsName[$index]}-$k-$i-$j.txt"
      done
    done
    #clearSelectionTemp ${newExpDirectories[$index]} ${nextExpDirectories[$index]}
  done

  let "index++"
done
