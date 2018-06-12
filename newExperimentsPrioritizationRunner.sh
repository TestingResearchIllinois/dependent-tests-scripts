source ./newExp-config.sh

#compileNewExpSource

index=0
count=${#newExperiments[@]}

while [ "$index" -lt "$count" ]; do
  echo -e "Starting experiment: ${newExperiments[$index]}"
  cd ${newExpDirectories[$index]}

  #instrumentNewExpFiles ${newExpCP[$index]}
  for k in "${newExpTestTypes[@]}"; do
    #echo 'Generating sootTestOutput'
    #java -cp ${newExpSootCP[$index]} edu.washington.cs.dt.main.ImpactMain -inputTests ${newExperiments[$index]}-$k-order
    #mv sootTestOutput sootTestOutput-$k
    #java -cp ${newExpCP[$index]} edu.washington.cs.dt.impact.Main.OneConfigurationRunner -technique prioritization -coverage statement -order original -origOrder ${newExperiments[$index]}-$k-order -testInputDir sootTestOutput-$k -filesToDelete ${newExperiments[$index]}-env-files -project "${newExperimentsName[$index]}" -testType $k -outputDir ${initialDir}/${priorDir} -timesToRun ${medianTimes} -getCoverage

    for i in "${coverages[@]}"; do
      for j in "${priorOrders[@]}"; do
        #echo 'Running prioritization without resolveDependences and with dependentTestFile'
        #java -cp ${newExpCP[$index]} edu.washington.cs.dt.impact.Main.OneConfigurationRunner -technique prioritization -coverage $i -order $j -origOrder ${newExperiments[$index]}-$k-order -testInputDir sootTestOutput-$k -filesToDelete ${newExperiments[$index]}-env-files -getCoverage -project "${newExperimentsName[$index]}" -testType $k -outputDir ${initialDir}/${priorDir} -dependentTestFile ${initialDir}/ -timesToRun ${medianTimes}

        #echo 'Running prioritization without resolveDependences and without dependentTestFile'
        #java -Xms1g -Xmx2g -cp ${newExpCP[$index]} edu.washington.cs.dt.impact.Main.OneConfigurationRunner -technique prioritization -coverage $i -order $j -origOrder ${newExperiments[$index]}-$k-order -testInputDir sootTestOutput-$k -filesToDelete ${newExperiments[$index]}-env-files -getCoverage -project "${newExperimentsName[$index]}" -testType $k -outputDir ${initialDir}/${priorDir} -timesToRun ${medianTimes}

        echo 'Running prioritization with resolveDependences and without dependentTestFile'
        java -cp ${newExpCP[$index]} edu.washington.cs.dt.impact.Main.OneConfigurationRunner -technique prioritization -coverage $i -order $j -origOrder ${newExperiments[$index]}-$k-order -testInputDir sootTestOutput-$k -filesToDelete ${newExperiments[$index]}-env-files -getCoverage -project "${newExperimentsName[$index]}" -testType $k -outputDir ${initialDir}/${priorDir} -timesToRun ${medianTimes} -resolveDependences ${initialDir}/prioritization-dt-list/"prioritization-${newExperimentsName[$index]}-$k-$i-$j.txt"
      done
    done
    clearTemp ${newExperiments[$index]} $k
  done
  clearInstrumentation
  cd ${initialDir}
  let "index++"
done
