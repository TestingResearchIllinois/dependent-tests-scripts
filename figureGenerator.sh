source ./config.sh

#!/bin/bash

function runPrioritization() {
    rm -rf ${priorDir}
    mkdir ${priorDir}

    #./prioritization-runner.sh
    ./enhanced-prioritization-runner.sh
    #./newExperimentsPrioritizationRunner.sh
    #./enhancedNewExpPriorRunner.sh
    #java -cp ${impactJarCP} edu.washington.cs.dt.impact.Main.EnhancedResultsFigureGenerator -directory ${priorDir} -outputDirectory ${priorDir} -allowNegatives
}

function runSelection() {
    rm -rf ${seleDir}
    mkdir ${seleDir}

    ./selection-runner.sh
    #./newExperimentsSelectionRunner.sh
    #java -cp ${impactJarCP} edu.washington.cs.dt.impact.Main.EnhancedResultsFigureGenerator -directory ${seleDir} -outputDirectory ${seleDir} -allowNegatives
}

function runParallelization() {
    rm -rf ${paraDir}
    mkdir ${paraDir}

    #./parallelization-runner.sh
    ./enhanced-parallelization-runner.sh
    #./newExperimentsParallelizationRunner.sh
    #./enhancedNewExpParaRunner.sh
    #java -cp ${impactJarCP} edu.washington.cs.dt.impact.Main.EnhancedResultsFigureGenerator -directory ${paraDir} -outputDirectory ${paraDir} -allowNegatives
}

#echo "Running random-runner script"
#./random-runner.sh
startTime=`date`

echo "Running prioritization-runner script"
#runPrioritization

echo "Running selection-runner script"
#runSelection

echo "Running paralleization-runner script"
#runParallelization

java -cp ${impactJarCP} edu.washington.cs.dt.impact.figure.generator.NumDependentTestsFigureGenerator -priorDirectory ${priorDir} -seleDirectory ${seleDir} -paraDirectory ${paraDir} -outputDirectory ./ -minBoundOrigDTFile scripts/data/ORIG_MIN_DTs.txt -minBoundAutoDTFile scripts/data/AUTO_MIN_DTs.txt

echo "Script has finished running."

echo "Start time was ${startTime}"

endTime=`date`
echo "End time is ${endTime}"

