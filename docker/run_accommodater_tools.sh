#!/usr/bin/env bash

echo "*******************ACCOMMODATER************************"
echo "Starting run_accommodater_tools.sh"

# This script is run inside the Docker image, for single experiment (one project)
# Should only be invoked by the run_experiment.sh script

if [[ $1 == "" ]] || [[ $2 == "" ]] || [[ $3 == "" ]] || [[ $4 == "" ]]; then
    echo "arg1 - GitHub SLUG"
    echo "arg2 - Old commit SHA/HEAD"
    echo "arg3 - New commit SHA/HEAD"
    echo "arg4 - Timeout in seconds"
    exit
fi

slug=$1
oldcommit=$2
newcommit=$3
timeout=$4

# Run the plugin, get module test times
echo "*******************ACCOMMODATER************************"
echo "Running the accommodater tools for one commit"
cd /home/awshi2/${slug}/
git rev-parse HEAD
date

cd /home/awshi2/dependent-tests-scripts/

timeout ${timeout}s /home/awshi2/dependent-tests-scripts/run-project-w-dir.sh /home/awshi2/${slug} ${newcommit} ${oldcommit}

# timeout ${timeout}s /home/awshi2/apache-maven/bin/mvn testrunner:testplugin -Ddiagnosis.run_detection=false -Denforcer.skip=true -Drat.skip=true -Dtestplugin.className=edu.illinois.cs.dt.tools.fixer.CleanerFixerPlugin -fn -B -e |& tee fixer.log

# Gather the results, put them up top
cd /home/awshi2/dependent-tests-scripts/
RESULTSDIR=/home/awshi2/output/
mkdir -p ${RESULTSDIR}
for d in $(find -maxdepth 1 -type d -name "*-results"); do mv $d ${RESULTSDIR}/; done

echo "*******************ACCOMMODATER************************"
echo "Finished run_accommodater_tools.sh"
date

