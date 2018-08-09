source ./config.sh

function fixerInstrumentSelectionFiles() {
  cd $1
  echo 'Enhanced instrumenting new subject'
  # Enable the following command to take an output argument
  java -cp $2:bin/ edu.washington.cs.dt.fixer.Main.InstrumentationMain -inputDir bin -cpDir bin
  # Enable the following command to output to a particular directory
  java -cp $2:bin/ edu.washington.cs.dt.fixer.Main.InstrumentationMain -inputDir bin -cpDir bin  -parsedStaticFields variableToType.dat

  mv sootOutput dtFixerOutput
  java -cp $2:dtFixerOutput edu.washington.cs.dt.impact.Main.InstrumentationMain -inputDir dtFixerOutput -technique selection

  cd ../$3
  echo 'Enhanced instrumenting old subject'
  # Enable the following command to take an output argument
  java -cp $4:bin/ edu.washington.cs.dt.fixer.Main.InstrumentationMain -inputDir bin -cpDir bin
  # Enable the following command to output to a particular directory
  java -cp $4:bin/ edu.washington.cs.dt.fixer.Main.InstrumentationMain -inputDir bin -cpDir bin  -parsedStaticFields variableToType.dat

  mv sootOutput dtFixerOutput
  java -cp $4:dtFixerOutput edu.washington.cs.dt.impact.Main.InstrumentationMain -inputDir dtFixerOutput -technique selection

  echo 'Generating sootTestOutput on old subject'
  java -cp $5 edu.washington.cs.dt.main.ImpactMain -inputTests ../$1/$6
  cd ..
}

function instrumentSelectionFiles() {
  cd $1
  echo 'Enhanced instrumenting new subject'
  java -cp $2 edu.washington.cs.dt.impact.Main.InstrumentationMain -inputDir bin -technique selection

  cd ../$3
  echo 'Enhanced instrumenting old subject'
  java -cp $4 edu.washington.cs.dt.impact.Main.InstrumentationMain -inputDir bin -technique selection

  echo 'Generating sootTestOutput on old subject'
  java -cp $5 edu.washington.cs.dt.main.ImpactMain -inputTests ../$1/$6
  mv sootTestOutput sootTestOutput-$7-selection
  cd ..
}

compileSource
compileNewSource

index=0
count=${#experiments[@]}

while [ "$index" -lt "$count" ]; do
  echo -e "Starting experiment: ${experiments[$index]}"

  for k in "${testTypes[@]}"; do
    #instrumentSelectionFiles ${newDirectories[$index]} ${instrumentNewExperimentsCP[$index]} ${directories[$index]} ${experimentsCP[$index]} ${sootCP[$index]} ${experiments[$index]}-$k-order $k
    #fixerInstrumentSelectionFiles ${newDirectories[$index]} ${fixerNewExperimentsCP[$index]} ${directories[$index]} ${fixerCP[$index]} ${sootCP[$index]} ${experiments[$index]}-$k-order

    echo 'Running prioritization for original order'
    java -Xms1g -Xmx2g -cp ${newExperimentsCP[$index]} edu.washington.cs.dt.impact.Main.OneConfigurationRunner -technique prioritization -coverage statement -order original -origOrder ${newDirectories[$index]}/${experiments[$index]}-$k-order -testInputDir ${directories[$index]}/sootTestOutput-$k-selection -filesToDelete ${newDirectories[$index]}/${experiments[$index]}-env-files -project "${experimentsName[$index]}" -testType $k -outputDir ${initialDir}/${seleDir} -timesToRun ${medianTimes} -getCoverage

    for i in "${coverages[@]}"; do
      for j in "${seleOrders[@]}"; do
        echo 'Running selection without resolveDependences and with dependentTestFile'
        java -Xms1g -Xmx2g -cp ${newExperimentsCP[$index]} edu.washington.cs.dt.impact.Main.OneConfigurationRunner -technique selection -coverage $i -order $j -origOrder ${newDirectories[$index]}/${experiments[$index]}-$k-order -testInputDir ${directories[$index]}/sootTestOutput-$k-selection -filesToDelete ${newDirectories[$index]}/${experiments[$index]}-env-files -project "${experimentsName[$index]}" -testType $k -oldVersCFG ${directories[$index]}/selectionOutput -newVersCFG ${newDirectories[$index]}/selectionOutput -getCoverage -outputDir ${initialDir}/${seleDir} -timesToRun ${medianTimes} -dependentTestFile ${initialDir}/selection-dt-list/"selection-${experimentsName[$index]}-$k-$i-$j.txt"

        echo 'Running selection without resolveDependences and without dependentTestFile'
        java -Xms1g -Xmx2g -cp ${newExperimentsCP[$index]} edu.washington.cs.dt.impact.Main.OneConfigurationRunner -technique selection -coverage $i -order $j -origOrder ${newDirectories[$index]}/${experiments[$index]}-$k-order -testInputDir ${directories[$index]}/sootTestOutput-$k-selection -filesToDelete ${newDirectories[$index]}/${experiments[$index]}-env-files -project "${experimentsName[$index]}" -testType $k -oldVersCFG ${directories[$index]}/selectionOutput -newVersCFG ${newDirectories[$index]}/selectionOutput -getCoverage -outputDir ${initialDir}/${seleDir} -timesToRun ${medianTimes}

        #echo 'Running selection with resolveDependences and without dependentTestFile'
        #java -Xms1g -Xmx2g -cp ${newExperimentsCP[$index]} edu.washington.cs.dt.impact.Main.OneConfigurationRunner -technique selection -coverage $i -order $j -origOrder ${newDirectories[$index]}/${experiments[$index]}-$k-order -testInputDir ${directories[$index]}/sootTestOutput-$k-selection -filesToDelete ${newDirectories[$index]}/${experiments[$index]}-env-files -project "${experimentsName[$index]}" -testType $k -oldVersCFG ${directories[$index]}/selectionOutput -newVersCFG ${newDirectories[$index]}/selectionOutput -getCoverage -outputDir ${initialDir}/${seleDir} -timesToRun ${medianTimes} -resolveDependences
      done
    done
    clearSelectionTemp ${directories[$index]} ${newDirectories[$index]}
  done

  let "index++"
done
