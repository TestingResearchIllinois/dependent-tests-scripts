#!/usr/bin/env bash

echo "*******************PRADET************************"
echo "Starting run_pradet_tools.sh"

# This script is run inside the Docker image, for single experiment (one project)
# Should only be invoked by the run_experiment.sh script

if [[ $1 == "" ]] || [[ $2 == "" ]] || [[ $3 == "" ]] || [[ $4 == "" ]]; then
    echo "arg1 - GitHub SLUG"
    echo "arg2 - Old commit SHA/HEAD"
    echo "arg3 - New commit SHA/HEAD"
    echo "arg4 - Timeout in seconds"
    echo "arg5 - (Optional) test type"
    echo "arg6 - (Optional) time to leave docker image open. Largely for debugging."
    exit
fi

slug=$1
oldcommit=$2
newcommit=$3
timeout=$4
testtype=$5

keepimagetime=$6
if [[ -z "$6" ]]; then
    # The default is 0 seconds
    keepimagetime=0
fi

# Run the plugin, get module test times
echo "*******************PRADET************************"
echo "Running the pradet tools for one commit"
cd /home/awshi2/${slug}/
git rev-parse HEAD
date

mkdir -p /home/awshi2/data

cd /home/awshi2/
git clone https://github.com/gmu-swe/pradet-replication.git
cd pradet-replication/
./setup-datadep-detector.sh


cd /home/awshi2/dependent-tests-scripts/

set -x
timeout ${timeout}s /home/awshi2/dependent-tests-scripts/run-project-w-dir.sh ${slug} ${newcommit} ${oldcommit} "pradet"

# Gather the results, put them up top
cd /home/awshi2/dependent-tests-scripts/
RESULTSDIR=/home/awshi2/output/
mkdir -p ${RESULTSDIR}
for d in $(find -maxdepth 1 -type d -name "*-results"); do mv $d ${RESULTSDIR}/; done

echo "*******************PRADET************************"
echo "Finished run_pradet_tools.sh"
date

sleep ${keepimagetime}
