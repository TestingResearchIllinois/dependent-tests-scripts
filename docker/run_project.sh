#!/bin/bash

cd /home/awshi2/dependent-tests-scripts/

git rev-parse HEAD
date

# This script is run inside the Docker image, for single experiment (one project)
# Should only be invoked by the run_experiment.sh script

if [[ $1 == "" ]] || [[ $2 == "" ]] || [[ $3 == "" ]] || [[ $4 == "" ]] || [[ $5 == "" ]]; then
    echo "arg1 - GitHub SLUG"
    echo "arg2 - Module"
    echo "arg3 - New commit"
    echo "arg4 - Old commit"
    echo "arg5 - Timeout in seconds"
    exit
fi

slug=$1
module=$2
newcommit=$3
oldcommit=$4
timeout=$5

# Setup prolog stuff
/home/awshi2/dependent-tests-scripts/docker/setup

# Set environment up, just in case
source ~/.bashrc

echo "*******************ACCOMMODATER************************"
echo "Running accommodater script"
date
/home/awshi2/dependent-tests-scripts/docker/run_accommodater_tools.sh ${slug} ${module} ${oldcommit} ${newcommit} ${timeout}

echo "*******************ACCOMMODATER************************"
echo "Finished run_project.sh"
date

