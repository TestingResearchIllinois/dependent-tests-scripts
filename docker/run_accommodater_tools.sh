#!/usr/bin/env bash

echo "*******************ACCOMMODATER************************"
echo "Starting run_accommodater_tools.sh"

# This script is run inside the Docker image, for single experiment (one project)
# Should only be invoked by the run_experiment.sh script

if [[ $1 == "" ]] || [[ $2 == "" ]] || [[ $3 == "" ]] || [[ $4 == "" ]] || [[ $5 == "" ]]; then
    echo "arg1 - GitHub SLUG"
    echo "arg2 - Module"
    echo "arg3 - Old commit SHA/HEAD"
    echo "arg4 - New commit SHA/HEAD"
    echo "arg5 - Timeout in seconds"
    echo "arg6 - Technique (Optional)"
    exit
fi

slug=$1
module=$2
oldcommit=$3
newcommit=$4
timeout=$5
technique=$6

# Run the plugin, get module test times
echo "*******************ACCOMMODATER************************"
echo "Running the accommodater tools for one commit"
cd /home/awshi2/${slug}/
git rev-parse HEAD
date

mkdir -p /home/awshi2/data

cd /home/awshi2/dependent-tests-scripts/

set -x

# Modify the modules-torun.txt to only include the relevant one for the specified module
grep "${slug//\//.}-$(basename ${module})" modules-torun.txt > /tmp/mod
mv /tmp/mod modules-torun.txt

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
)

# Actually run the script
timeout ${timeout}s /home/awshi2/dependent-tests-scripts/run-project-w-dir.sh ${slug} ${newcommit} ${oldcommit} ${technique}

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
cd /home/awshi2/dependent-tests-scripts/
RESULTSDIR=/home/awshi2/output/
mkdir -p ${RESULTSDIR}
for d in $(find -maxdepth 1 -type d -name "*-results"); do mv $d ${RESULTSDIR}/; done
cp -r /home/awshi2/${slug}-old-* ${RESULTSDIR}

echo "*******************ACCOMMODATER************************"
echo "Finished run_accommodater_tools.sh"
date

