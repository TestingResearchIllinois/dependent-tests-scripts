#!/usr/bin/env bash

echo "*******************PRADET************************"
echo "Starting run_pradet_tools.sh"

# This script is run inside the Docker image, for single experiment (one project)
# Should only be invoked by the run_experiment.sh script

if [[ $1 == "" ]] || [[ $2 == "" ]] || [[ $3 == "" ]] || [[ $4 == "" ]] || [[ $5 == "" ]]; then
    echo "arg1 - GitHub SLUG"
    echo "arg2 - Module"
    echo "arg3 - Old commit SHA/HEAD"
    echo "arg4 - New commit SHA/HEAD"
    echo "arg5 - Timeout in seconds"
    echo "arg6 - (Optional) test type"
    echo "arg7 - (Optional) time to leave docker image open. Largely for debugging."
    exit
fi

slug=$1
module=$2
oldcommit=$3
newcommit=$4
timeout=$5
testtype=$6

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

# Modify the modules-torun.txt to only include the relevant one for the specified module
modifiedslug=${slug//\//.}
grep "${modifiedslug}-$(basename ${module})" modules-torun.txt > /tmp/mod
mv /tmp/mod modules-torun.txt

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
