#!/bin/bash

git rev-parse HEAD

date

# This script is run inside the Docker image, for single experiment (one project)
# Should only be invoked by the run_experiment.sh script

if [[ $1 == "" ]] || [[ $2 == "" ]] || [[ $3 == "" ]]; then
    echo "arg1 - GitHub SLUG"
    echo "arg2 - New commit"
    echo "arg3 - Timeout in seconds"
    exit
fi

slug=$1
commit=$2
timeout=$3

# Setup prolog stuff
/home/awshi2/dependent-tests-scripts/docker/setup

# Set environment up, just in case
source ~/.bashrc

echo "*******************ACCOMMODATER************************"
echo "Running accommodater script"
date
/home/awshi2/dependent-tests-scripts/docker/run_accommdator_tools.sh ${slug} ${commit} ${commit}~10 ${timeout}

echo "*******************ACCOMMODATER************************"
echo "Finished run_project.sh"
date

