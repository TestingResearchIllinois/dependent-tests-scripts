source ./config.sh

newExperiments=(ambari-server zeppelin-zengine zeppelin-server)
newExpTestTypes=(orig auto)

newExpDirectories=(ambari/ambari-server/target zeppelin/zeppelin-zengine/target zeppelin/zeppelin-server/target)
#newExpCompileDirectories=(ambari)
newExpCP=(${initialDir}/impact-tools/*:classes/:test-classes/:dependency/*:randoop/bin/:/usr/lib/jvm/java-7-oracle/jre/lib/*: ${initialDir}/impact-tools/*:classes/:test-classes/:dependency/*:randoop/bin/:/usr/lib/jvm/java-7-oracle/jre/lib/*: ${initialDir}/impact-tools/*:classes/:test-classes/:dependency/*:randoop/bin/:/usr/lib/jvm/java-7-oracle/jre/lib/*:)
#newExpSootCP=(${initialDir}/impact-tools/*:sootOutput/:dependency/*:/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.121-2.6.8.0.el7_3.x86_64/jre/lib/*:)

newExperimentsName=("Ambari-Server" "Zeppelin-Zengine" "Zeppelin-Server")

nextExpDirectories=(ambari-new/ambari-server/target zeppelin-zengine-new/zeppelin-zengine/target zeppelin-new/zeppelin-server/target)
nextExpCP=(${initialDir}/impact-tools/*:${initialDir}/ambari-new/ambari-server/target/classes/:${initialDir}/ambari-new/ambari-server/target/test-classes/:${initialDir}/ambari-new/ambari-server/target/dependency/*:${initialDir}/ambari-new/ambari-server/target/randoop/bin/:/usr/lib/jvm/java-7-oracle/jre/lib/*: ${initialDir}/impact-tools/*:${initialDir}/zeppelin-zengine-new/zeppelin-zengine/target/classes/:${initialDir}/zeppelin-zengine-new/zeppelin-zengine/target/test-classes/:${initialDir}/zeppelin-zengine-new/zeppelin-zengine/target/dependency/*:${initialDir}/zeppelin-zengine-new/zeppelin-zengine/target/randoop/bin/:/usr/lib/jvm/java-7-oracle/jre/lib/*: ${initialDir}/impact-tools/*:${initialDir}/zeppelin-new/zeppelin-server/target/classes/:${initialDir}/zeppelin-new/zeppelin-server/target/test-classes/:${initialDir}/zeppelin-new/zeppelin-server/target/dependency/*:${initialDir}/zeppelin-new/zeppelin-server/target/randoop/bin/:/usr/lib/jvm/java-7-oracle/jre/lib/*:)

function compileNewExpSource() {
  index=0
  count=${#newExperiments[@]}
  while [ "$index" -lt "$count" ]; do
    echo ""
    echo -e "Compiling experiment: ${newExperiments[$index]} in ${newExpCompileDirectories[$index]}/"
    cd ${newExpCompileDirectories[$index]}
    mvn compile
    mvn test-compile
    mvn install -fn -DskipTests dependency:copy-dependencies
    let "index++"
    cd ..
  done
}

function instrumentNewExpFiles() {
  echo 'Instrumenting new experiment files'
  java -cp $1 edu.washington.cs.dt.impact.Main.InstrumentationMain -inputDir classes
  java -cp $1 edu.washington.cs.dt.impact.Main.InstrumentationMain -inputDir test-classes
}

function runNewExpParallelizationOneConfigurationRunner() {
  #echo "Getting time for tests."
  #java -cp $2 edu.washington.cs.dt.main.ImpactMain -inputTests $1-$3-order -getTime > $1-$3-time.txt
  for k in "${machines[@]}"; do
    #echo 'Running parallelization without resolveDependences and without dependentTestFile for time order'
    #java -Xms1g -Xmx2g -cp $2 edu.washington.cs.dt.impact.Main.OneConfigurationRunner -technique parallelization -order time -timeOrder $5/$1-$3-time.txt -origOrder $1-$3-order -testInputDir $5/sootTestOutput-$3 -filesToDelete $1-env-files -numOfMachines $k -project "$4" -testType $3 -timesToRun ${medianTimes} -outputDir ${initialDir}/${paraDir}
    #echo 'Running parallelization without resolveDependences and without dependentTestFile for original order'
    #java -Xms1g -Xmx2g -cp $2 edu.washington.cs.dt.impact.Main.OneConfigurationRunner -technique parallelization -order original -origOrder $1-$3-order -testInputDir $5/sootTestOutput-$3 -filesToDelete $1-env-files -project "$4" -testType $3 -numOfMachines $k -outputDir ${initialDir}/${paraDir} -timesToRun ${medianTimes}

    echo 'Running parallelization with resolveDependences and without dependentTestFile for original order'
    java -cp $2 edu.washington.cs.dt.impact.Main.OneConfigurationRunner -technique parallelization -order original -origOrder $1-$3-order -testInputDir $5/sootTestOutput-$3 -filesToDelete $1-env-files -project "$4" -testType $3 -numOfMachines $k -outputDir ${initialDir}/${paraDir} -timesToRun ${medianTimes} -resolveDependences ${initialDir}/parallelization-dt-list/"parallelization-$4-$3-$k-original.txt"
    echo 'Running parallelization with resolveDependences and without dependentTestFile for time order'
    java -cp $2 edu.washington.cs.dt.impact.Main.OneConfigurationRunner -technique parallelization -order time -timeOrder $5/$1-$3-time.txt -origOrder $1-$3-order -testInputDir $5/sootTestOutput-$3 -filesToDelete $1-env-files -numOfMachines $k -project "$4" -testType $3 -timesToRun ${medianTimes} -outputDir ${initialDir}/${paraDir} -resolveDependences ${initialDir}/parallelization-dt-list/"parallelization-$4-$3-$k-time.txt"
  done
}

function runEnhancedNewExpParallelizationOneConfigurationRunner() {
  for k in "${machines[@]}"; do
    echo 'Running parallelization without resolveDependences and with dependentTestFile for time order'
    java -Xms1g -Xmx2g -cp $2 edu.washington.cs.dt.impact.Main.OneConfigurationRunner -technique parallelization -order time -timeOrder $5/$1-$3-time.txt -origOrder $1-$3-order -testInputDir $5/sootTestOutput-$3 -filesToDelete $1-env-files -numOfMachines $k -project "$4" -testType $3 -timesToRun ${medianTimes} -outputDir ${initialDir}/${paraDir} -dependentTestFile ${initialDir}/parallelization-dt-list/"parallelization-$4-$3-$k-time.txt"
    echo 'Running parallelization without resolveDependences and with dependentTestFile for original order'
    java -Xms1g -Xmx2g -cp $2 edu.washington.cs.dt.impact.Main.OneConfigurationRunner -technique parallelization -order original -origOrder $1-$3-order -testInputDir $5/sootTestOutput-$3 -filesToDelete $1-env-files -project "$4" -testType $3 -numOfMachines $k -outputDir ${initialDir}/${paraDir} -timesToRun ${medianTimes} -dependentTestFile ${initialDir}/parallelization-dt-list/"parallelization-$4-$3-$k-original.txt"

    echo 'Running parallelization without resolveDependences and without dependentTestFile for time order'
    java -Xms1g -Xmx2g -cp $2 edu.washington.cs.dt.impact.Main.OneConfigurationRunner -technique parallelization -order time -timeOrder $5/$1-$3-time.txt -origOrder $1-$3-order -testInputDir $5/sootTestOutput-$3 -filesToDelete $1-env-files -numOfMachines $k -project "$4" -testType $3 -timesToRun ${medianTimes} -outputDir ${initialDir}/${paraDir}
    echo 'Running parallelization without resolveDependences and without dependentTestFile for original order'
    java -Xms1g -Xmx2g -cp $2 edu.washington.cs.dt.impact.Main.OneConfigurationRunner -technique parallelization -order original -origOrder $1-$3-order -testInputDir $5/sootTestOutput-$3 -filesToDelete $1-env-files -project "$4" -testType $3 -numOfMachines $k -outputDir ${initialDir}/${paraDir} -timesToRun ${medianTimes}
  done
}
