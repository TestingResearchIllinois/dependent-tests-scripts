source ./config.sh

compileNewSource

index=0
count=${#experiments[@]}

while [ "$index" -lt "$count" ]; do
  echo -e "Starting experiment: ${experiments[$index]}"
  cd ${newDirectories[$index]}

  for j in "${testTypes[@]}"; do
    echo 'Running prioritization for original order'
    java -Xms1g -Xmx2g -cp ${newExperimentsCPNoDir[$index]} edu.washington.cs.dt.impact.Main.OneConfigurationRunner -technique prioritization -coverage statement -order original -origOrder ${experiments[$index]}-$j-order -testInputDir ${initialDir}/${directories[$index]}/sootTestOutput-$j -filesToDelete ${experiments[$index]}-env-files -project "${experimentsName[$index]}" -testType $j -outputDir ${initialDir}/${paraDir} -timesToRun ${medianTimes} -getCoverage

    runEnhancedParallelizationOneConfigurationRunner ${experiments[$index]} ${newExperimentsCPNoDir[$index]} $j "${experimentsName[$index]}" ${initialDir}/${directories[$index]}/

    clearTemp ${experiments[$index]} $j
  done

  cd ..
  let "index++"
done
