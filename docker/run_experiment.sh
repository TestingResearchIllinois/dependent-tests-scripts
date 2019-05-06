#!/bin/bash

# This script is the entry point script that is run inside of the Docker image
# for running the experiment for a single project

if [[ $1 == "" ]] || [[ $2 == "" ]] || [[ $3 == "" ]] || [[ $4 == "" ]] || [[ $5 == "" ]]; then
    echo "arg1 - GitHub SLUG"
    echo "arg2 - Module"
    echo "arg3 - New SHA"
    echo "arg4 - Old SHA"
    echo "arg5 - Timeout in seconds"
    echo "arg6 - Script to run (Optional)"
    echo "arg7 - Test type (Optional)"
    echo "arg8 - Technique (Optional)"
    echo "arg9 - Time to keep docker image running after script finishes (Optional)"
    exit
fi

# If it's an absolute path, just use it
if [[ "$6" =~ "$/" ]]; then
    script_to_run="$6"
elif [[ -z "$6" ]]; then
    # The default is run_project.sh
    script_to_run="/home/awshi2/dependent-tests-scripts/docker/run_project.sh"
else
    # otherwise, assume it's relative to the docker directory
    script_to_run="/home/awshi2/dependent-tests-scripts/docker/$6"
fi

slug=$1
module=$2
newsha=$3
oldsha=$4
timeout=$5
testtype="$7"
technique="$8"
keepimagetime="$9"

git rev-parse HEAD
date

sudo apt-get install -y zip unzip libxml2-utils

# Update all tooling
su - awshi2 -c "cd /home/awshi2/dependent-tests-scripts/; git pull"

echo "*******************ACCOMMODATER************************"
echo "Running update.sh"
date
su - awshi2 -c "/home/awshi2/dependent-tests-scripts/docker/update.sh"

# Copy the test time log, if it is in the old location. Probably can remove this line if all containers are new.

if [[ -e "/home/awshi2/mvn-test-time.log" ]] && [[ ! -e "/home/awshi2/$slug/mvn-test-time.log" ]]; then
    cp "/home/awshi2/mvn-test-time.log" "/home/awshi2/$slug"
fi

# Start the script using the awshi2 user
su - awshi2 -c "$script_to_run ${slug} ${module} ${newsha} ${oldsha} ${timeout} \"${testtype}\" \"${technique}\" \"${keepimagetime}\""

# Change permissions of results and copy outside the Docker image (assume outside mounted under /Scratch)
modifiedslug=$(echo ${slug} | sed 's;/;.;' | tr '[:upper:]' '[:lower:]')
cp -r /home/awshi2/output/ /Scratch/${modifiedslug}=$(basename ${module})_output/
chown -R $(id -u):$(id -g) /Scratch/${modifiedslug}=$(basename ${module})_output/
chmod -R 777 /Scratch/${modifiedslug}=$(basename ${module})_output/
