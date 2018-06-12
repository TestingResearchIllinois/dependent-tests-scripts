# This file is to share variables and functions. Please do not run this
# file.

# Number of times to run the test order before taking the median
medianTimes=1
# Number of times to randomize the test order when calculating the
# precomputed dependences
randomTimes=100

initialDir=`pwd`

# If you would like to run only a subset of the experiments, you must
# remove experiments starting from the back of the list and not
# leave any gaps. Ex. You can run only Crystal and JFreechart but
# cannot run JFreechart and Jodatime. You can run Crystal, JFreechart
# and Jodatime but cannot run Crystal and Jodatime.
experiments=(crystal jfreechart jodatime synoptic xml_security)
testTypes=(orig auto)
coverages=(statement function)
machines=(2 4 8 16)

experimentsName=("Crystal" "JFreechart" "Joda-Time" "Synoptic" "XML Security")

# Used only by the random runner
doubleNumOfOrigTests=(156 4468 7750 500 216)
numOfOrigTests=(78 2234 3875 118 108)
doubleNumOfAutoTests=(6396 4876 4468 4934 1330)
numOfAutoTests=(3198 2438 2234 2467 665)

# Ordering for the three techniques
priorOrders=(absolute relative)
seleOrders=(original absolute relative)

# Directory to output the results
priorDir=prioritization-results
seleDir=selection-results
paraDir=parallelization-results

# Do not change the values below unless you know specifically what you
# are doing
impactJarCP=impact-tools/impact.jar
testListGenClass=edu.washington.cs.dt.impact.tools.TestListGenerator
crossReferenceClass=edu.washington.cs.dt.impact.tools.CrossReferencer

directories=(crystalvc jfreechart-1.0.15 jodatime-b609d7d66d dynoptic xml-security-orig-v1)
# Not compatible with httpcore
fixerCP=(../fixer-libs/*:lib/* ../fixer-libs/*:lib/* ../fixer-libs/*:resources/:lib/* ../fixer-libs/*:../synoptic/lib/*:../synoptic/bin/:../daikonizer/bin/ ../fixer-libs/*:../xml-security-commons/bin/:data/:../xml-security-commons/libs/*)
experimentsCP=(impact-tools/*:bin/:lib/* impact-tools/*:bin/:lib/* impact-tools/*:bin/:resources/:lib/* impact-tools/*:bin/:../synoptic/lib/*:../synoptic/bin/:../daikonizer/bin/ impact-tools/*:bin/:../xml-security-commons/bin/:data/:../xml-security-commons/libs/*)
experimentsCPWithDirectory=(crystalvc/impact-tools/*:crystalvc/bin/:crystalvc/lib/* jfreechart-1.0.15/impact-tools/*:jfreechart-1.0.15/bin/:jfreechart-1.0.15/lib/* jodatime-b609d7d66d/impact-tools/*:jodatime-b609d7d66d/bin/:jodatime-b609d7d66d/resources/:jodatime-b609d7d66d/lib/* dynoptic/impact-tools/*:dynoptic/bin/:synoptic/lib/*:synoptic/bin/:daikonizer/bin/ xml-security-orig-v1/impact-tools/*:xml-security-orig-v1/bin/:xml-security-commons/bin/:data/:xml-security-commons/libs/*)
sootCP=(impact-tools/*:sootOutput/:lib/* impact-tools/*:sootOutput/:lib/* impact-tools/*:sootOutput/:resources/:lib/* impact-tools/*:sootOutput/:../synoptic/lib/*:../synoptic/bin/:../daikonizer/bin/ impact-tools/*:sootOutput/:../xml-security-commons/bin/:data/:../xml-security-commons/libs/*)

newDirectories=(crystal jfreechart-1.0.16 jodatime-d6791cb5f9 dynoptic-ea407ba0a750 xml-security-1_2_0)
newExperimentsCP=(/home/user/dependent-tests-impact/experiments/impact-tools/*:crystal/bin/:crystal/libs/lib/* /home/user/dependent-tests-impact/experiments/impact-tools/*:jfreechart-1.0.16/bin/:jfreechart-1.0.16/lib/* /home/user/dependent-tests-impact/experiments/impact-tools/*:jodatime-d6791cb5f9/bin/:jodatime-d6791cb5f9/resources/:jodatime-d6791cb5f9/lib/* /home/user/dependent-tests-impact/experiments/impact-tools/*:dynoptic-ea407ba0a750/bin/:synoptic/lib/*:synoptic-ea407ba0a750/bin/:daikonizer-ea407ba0a750/bin/ /home/user/dependent-tests-impact/experiments/impact-tools/*:xml-security-1_2_0/bin/:xml-security-commons/bin/:xml-security-1_2_0/data/:xml-security-commons/libs/*)
instrumentNewExperimentsCP=(/home/user/dependent-tests-impact/experiments/impact-tools/*:bin/:libs/lib/* /home/user/dependent-tests-impact/experiments/impact-tools/*:bin/:lib/* /home/user/dependent-tests-impact/experiments/impact-tools/*:bin/:resources/:lib/* /home/user/dependent-tests-impact/experiments/impact-tools/*:bin/:../synoptic/lib/*:../synoptic-ea407ba0a750/bin/:../daikonizer-ea407ba0a750/bin/ /home/user/dependent-tests-impact/experiments/impact-tools/*:bin/:../xml-security-commons/bin/:data/:../xml-security-commons/libs/*)
fixerNewExperimentsCP=(impact-tools/*:libs/lib/* impact-tools/*:lib/* impact-tools/*:resources/:lib/* impact-tools/*:../synoptic/lib/*:../synoptic-ea407ba0a750/bin/:../daikonizer-ea407ba0a750/bin/ impact-tools/*:../xml-security-commons/bin/:data/:../xml-security-commons/libs/*)

newExperimentsCPNoDir=(/home/user/dependent-tests-impact/experiments/impact-tools/*:bin/:libs/lib/* /home/user/dependent-tests-impact/experiments/impact-tools/*:bin/:lib/* /home/user/dependent-tests-impact/experiments/impact-tools/*:bin/:resources/:lib/* /home/user/dependent-tests-impact/experiments/impact-tools/*:bin/:../synoptic/lib/*:../synoptic-ea407ba0a750/bin/:../daikonizer-ea407ba0a750/bin/ /home/user/dependent-tests-impact/experiments/impact-tools/*:bin/:../xml-security-commons/bin/:data/:../xml-security-commons/libs/*)

compileCP=(bin/:lib/* impact-tools/*:bin/:lib/* bin/:resources/:lib/* bin/:../synoptic/lib/*:../synoptic/bin/:../daikonizer/bin/ bin/:../xml-security-commons/bin/:data/:../xml-security-commons/libs/*)
newCompileCP=(bin/:lib/* impact-tools/*:bin/:lib/* bin/:resources/:lib/* bin/:../synoptic/lib/*:../synoptic/bin/:../daikonizer/bin/ bin/:../xml-security-commons/bin/:data/:../xml-security-commons/libs/*)

function clearTemp() {
#  rm -rf sootTestOutput
  rm -rf tmpfile.txt
  rm -rf tmptestfiles.txt
  rm -rf dtFixerOutput
}

function clearInstrumentation() {
  rm -rf sootOutput
  rm -rf variableToType.dat
}

function clearSelectionTemp() {
  rm -rf $1/sootOutput
  rm -rf $1/sootTestOutput
  rm -rf $1/tmpfile.txt
#  rm -rf $1/selectionOutput
  rm -rf $1/tmptestfiles.txt
  rm -rf $2/sootOutput
#  rm -rf $2/selectionOutput
  rm -rf $2/tmpfile.txt
  rm -rf $2/tmptestfiles.txt
}

function clearProjectFiles() {
  rm -rf ./'2013-08-28T20-44-41.156-0700'
  rm -rf ./'hi!'
  rm -rf ./'-1 ms'
  rm -rf ./'0 ms'
  rm -rf ./'1 ms'
  rm -rf ./'10 ms'
  rm -rf ./'100 ms'
  rm -rf ./'382707 hours 44 min'
  rm -rf ./'testDataFile\testSave.xml'
  rm -rf ./'test.dot'
  rm -rf ./'test2.dot'
  rm -rf ./'4444444444  4 444444444444 444444444444444444444'
  rm -rf tmpfile.txt
  rm -rf tmptestfiles.txt
}

function instrumentFiles() {
  echo 'Instrumenting files'
  java -cp $1 edu.washington.cs.dt.impact.Main.InstrumentationMain -inputDir bin
}

function fixerInstrumentFiles() {
  echo 'Enhanced instrumenting files'
  # Enable the following command to take an output argument
  java -Xms1g -Xmx2g -cp $1:bin/ edu.washington.cs.dt.fixer.Main.InstrumentationMain -inputDir bin -cpDir bin -f n
  # Enable the following command to output to a particular directory
  java -Xms1g -Xmx2g -cp $1:bin/ edu.washington.cs.dt.fixer.Main.InstrumentationMain -inputDir bin -cpDir bin  -parsedStaticFields variableToType.dat -f c

  mv sootOutput dtFixerOutput
  java -cp $1:dtFixerOutput edu.washington.cs.dt.impact.Main.InstrumentationMain -inputDir dtFixerOutput
}

function compileNewSource() {
  index=0
  count=${#experiments[@]}
  while [ "$index" -lt "$count" ]; do
    echo ""
    echo -e "Compiling new experiment: ${experiments[$index]} in ${newDirectories[$index]}/"
    cd ${newDirectories[$index]}
    ant
    let "index++"
    cd ..
  done
}

function compileSource() {
  index=0
  count=${#experiments[@]}
  while [ "$index" -lt "$count" ]; do
    echo ""
    echo -e "Compiling experiment: ${experiments[$index]} in ${directories[$index]}/"
    cd ${directories[$index]}
    ant
    let "index++"
    cd ..
  done
}

function runParallelizationOneConfigurationRunner() {
  #java -cp $2 edu.washington.cs.dt.main.ImpactMain -inputTests $1-$3-order -getTime > $1-$3-time.txt
  for k in "${machines[@]}"; do
    #echo 'Running parallelization without resolveDependences and without dependentTestFile for time order'
    #java -cp $2 edu.washington.cs.dt.impact.Main.OneConfigurationRunner -technique parallelization -order time -timeOrder $5/$1-$3-time.txt -origOrder $1-$3-order -testInputDir $5/sootTestOutput-$3 -filesToDelete $1-env-files -numOfMachines $k -project "$4" -testType $3 -timesToRun ${medianTimes} -outputDir ${initialDir}/${paraDir}
    #echo 'Running parallelization without resolveDependences and without dependentTestFile for original order'
    #java -cp $2 edu.washington.cs.dt.impact.Main.OneConfigurationRunner -technique parallelization -order original -origOrder $1-$3-order -testInputDir $5/sootTestOutput-$3 -filesToDelete $1-env-files -project "$4" -testType $3 -numOfMachines $k -outputDir ${initialDir}/${paraDir} -timesToRun ${medianTimes}

    echo 'Running parallelization with resolveDependences and without dependentTestFile for original order'
    java -cp $2 edu.washington.cs.dt.impact.runner.OneConfigurationRunner -technique parallelization -order original -origOrder $1-$3-order -testInputDir $5/sootTestOutput-$3 -filesToDelete $1-env-files -project "$4" -testType $3 -numOfMachines $k -outputDir ${initialDir}/${paraDir} -timesToRun ${medianTimes} -resolveDependences ${initialDir}/parallelization-dt-list/"parallelization-$4-$3-$k-original.txt"
    echo 'Running parallelization with resolveDependences and without dependentTestFile for time order'
    java -cp $2 edu.washington.cs.dt.impact.runner.OneConfigurationRunner -technique parallelization -order time -timeOrder $5/$1-$3-time.txt -origOrder $1-$3-order -testInputDir $5/sootTestOutput-$3 -filesToDelete $1-env-files -numOfMachines $k -project "$4" -testType $3 -timesToRun ${medianTimes} -outputDir ${initialDir}/${paraDir} -resolveDependences ${initialDir}/parallelization-dt-list/"parallelization-$4-$3-$k-time.txt"
  done
}


function runEnhancedParallelizationOneConfigurationRunner() {
  #java -cp $2 edu.washington.cs.dt.main.ImpactMain -inputTests $1-$3-order -getTime > $1-$3-time.txt
  for k in "${machines[@]}"; do
    echo 'Running parallelization without resolveDependences and with dependentTestFile for time order'
    java -cp $2 edu.washington.cs.dt.impact.runner.OneConfigurationRunner -technique parallelization -order time -timeOrder $5/$1-$3-time.txt -origOrder $1-$3-order -testInputDir $5/sootTestOutput-$3 -filesToDelete $1-env-files -numOfMachines $k -project "$4" -testType $3 -timesToRun ${medianTimes} -outputDir ${initialDir}/${paraDir} -dependentTestFile ${initialDir}/parallelization-dt-list/"parallelization-$4-$3-$k-time.txt"
    echo 'Running parallelization without resolveDependences and with dependentTestFile for original order'
    java -cp $2 edu.washington.cs.dt.impact.runner.OneConfigurationRunner -technique parallelization -order original -origOrder $1-$3-order -testInputDir $5/sootTestOutput-$3 -filesToDelete $1-env-files -project "$4" -testType $3 -numOfMachines $k -outputDir ${initialDir}/${paraDir} -timesToRun ${medianTimes} -dependentTestFile ${initialDir}/parallelization-dt-list/"parallelization-$4-$3-$k-original.txt"

    echo 'Running parallelization without resolveDependences and without dependentTestFile for time order'
    java -cp $2 edu.washington.cs.dt.impact.runner.OneConfigurationRunner -technique parallelization -order time -timeOrder $5/$1-$3-time.txt -origOrder $1-$3-order -testInputDir $5/sootTestOutput-$3 -filesToDelete $1-env-files -numOfMachines $k -project "$4" -testType $3 -timesToRun ${medianTimes} -outputDir ${initialDir}/${paraDir}
    echo 'Running parallelization without resolveDependences and without dependentTestFile for original order'
    java -cp $2 edu.washington.cs.dt.impact.runner.OneConfigurationRunner -technique parallelization -order original -origOrder $1-$3-order -testInputDir $5/sootTestOutput-$3 -filesToDelete $1-env-files -project "$4" -testType $3 -numOfMachines $k -outputDir ${initialDir}/${paraDir} -timesToRun ${medianTimes}

    #echo 'Running parallelization with resolveDependences and with dependentTestFile for time order'
    #java -cp $2 edu.washington.cs.dt.impact.Main.OneConfigurationRunner -technique parallelization -order time -timeOrder $5/$1-$3-time.txt -origOrder $1-$3-order -testInputDir $5/sootTestOutput-$3 -filesToDelete $1-env-files -numOfMachines $k -project "$4" -testType $3 -timesToRun ${medianTimes} -outputDir ${initialDir}/${paraDir} -dependentTestFile ${initialDir}/parallelization-dt-list/"parallelization-$4-$3-$k-time.txt" -resolveDependences ${initialDir}/parallelization-dt-list/"parallelization-$4-$3-$k-time.txt"
    #echo 'Running parallelization with resolveDependences and with dependentTestFile for original order'
    #java -cp $2 edu.washington.cs.dt.impact.Main.OneConfigurationRunner -technique parallelization -order original -origOrder $1-$3-order -testInputDir $5/sootTestOutput-$3 -filesToDelete $1-env-files -project "$4" -testType $3 -numOfMachines $k -outputDir ${initialDir}/${paraDir} -timesToRun ${medianTimes} -dependentTestFile ${initialDir}/parallelization-dt-list/"parallelization-$4-$3-$k-original.txt" -resolveDependences ${initialDir}/parallelization-dt-list/"parallelization-$4-$3-$k-original.txt"
  done
}
