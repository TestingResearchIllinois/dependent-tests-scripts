source ./newExp-config.sh

#compileNewExpSource

index=0
count=${#newExperiments[@]}

while [ "$index" -lt "$count" ]; do
  echo -e "Starting experiment: ${newExperiments[$index]}"
  cd ${newExpDirectories[$index]}

  for j in "${newExpTestTypes[@]}"; do
    #echo 'Running prioritization for original order'
    #java -Xms1g -Xmx2g -cp ${newExpCP[$index]} edu.washington.cs.dt.impact.Main.OneConfigurationRunner -technique prioritization -coverage statement -order original -origOrder ${newExperiments[$index]}-$j-order -testInputDir sootTestOutput-$j -filesToDelete ${newExperiments[$index]}-env-files -project "${newExperimentsName[$index]}" -testType $j -outputDir ${initialDir}/${paraDir} -timesToRun ${medianTimes} -getCoverage

    runNewExpParallelizationOneConfigurationRunner ${newExperiments[$index]} ${newExpCP[$index]} $j "${newExperimentsName[$index]}" ${initialDir}/${newExpDirectories[$index]}/
    clearTemp ${newExperiments[$index]} $j
  done

  cd ${initialDir}
  let "index++"
done
