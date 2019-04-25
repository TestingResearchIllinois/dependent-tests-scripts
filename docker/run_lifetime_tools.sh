#!/usr/bin/env bash

echo "*******************LIFETIME************************"
echo "Starting run_lifetime_tools.sh"

# This script is run inside the Docker image, for single experiment (one project)
# Should only be invoked by the run_project_lifetime.sh script

if [[ $1 == "" ]] || [[ $2 == "" ]] || [[ $3 == "" ]] || [[ $4 == "" ]] || [[ $5 == "" ]]; then
    echo "arg1 - GitHub SLUG"
    echo "arg2 - Module"
    echo "arg3 - Old commit SHA/HEAD"
    echo "arg4 - New commit SHA/HEAD"
    echo "arg5 - Timeout in seconds"
    exit
fi

slug=$1
module=$2
oldcommit=$3
newcommit=$4
timeout=$5

# Run the plugin, get module test times
echo "*******************ACCOMMODATER************************"
echo "Running the lifetime tools for multiple commits"
cd /home/awshi2/${slug}/
git rev-parse HEAD
date

mkdir -p /home/awshi2/data

cd /home/awshi2/dependent-tests-scripts/

set -x

modifiedslug=${slug//\//.}

# Modify the modules-torun.txt to only include the relevant one for the specified module
grep "${modifiedslug}-$(basename ${module})" modules-torun.txt > /tmp/mod
mv /tmp/mod modules-torun.txt

# Go to the lifetime directory and start running 
cd precomputed-lifetime/

# Download the directories corresponding to the old SHA and put them into place
(
    cd /home/awshi2/
    if [[ ${module} == '.' ]]; then
        name=${modifiedslug}
    else
        name=${modifiedslug}-$(basename ${module})
    fi
    wget http://mir.cs.illinois.edu/awshi2/dt-impact/${name}.zip
    unzip ${name}.zip
    owner=$(echo ${slug} | cut -d'/' -f1)
    projname=$(echo ${slug} | cut -d'/' -f2)
    mv ${name}/${projname}-old-* /home/awshi2/${owner}/
    mkdir -p /home/awshi2/data/
    mv ${name}/${name}-results/dt-lists/* /home/awshi2/data/
)

# Actually run the script
timeout ${timeout}s bash /home/awshi2/dependent-tests-scripts/precomputed-lifetime/run-precomputed-lifetime.sh ${slug} ${module} /home/awshi2/dependent-tests-scripts/precomputed-lifetime/projectcommits/${modifiedslug}-$(basename ${module})_commits

# timeout ${timeout}s /home/awshi2/apache-maven/bin/mvn testrunner:testplugin -Ddiagnosis.run_detection=false -Denforcer.skip=true -Drat.skip=true -Dtestplugin.className=edu.illinois.cs.dt.tools.fixer.CleanerFixerPlugin -fn -B -e |& tee fixer.log

# In case of timeout (or other errors...), put the other stuff into the results
if [[ $? != 0 ]]; then
    mkdir timeout-results/
    mv /home/awshi2/data/ timeout-results/
    mv /home/awshi2/prioritization-results/ timeout-results/
    mv /home/awshi2/parallelization-results/ timeout-results/
    mv /home/awshi2/selection-results/ timeout-results/
fi

# Gather the results, put them up top
cd /home/awshi2/dependent-tests-scripts/precomputed-lifetime/
RESULTSDIR=/home/awshi2/output/
mkdir -p ${RESULTSDIR}
for d in $(find -maxdepth 1 -type d -name "*-lifetime"); do mv $d ${RESULTSDIR}/; done
for d in $(find -maxdepth 1 -type d -name "*-results"); do mv $d ${RESULTSDIR}/; done

echo "*******************ACCOMMODATER************************"
echo "Finished run_lifetime_tools.sh"
date

