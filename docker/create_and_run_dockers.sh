#!/bin/bash

if [[ $1 == "" ]] || [[ $2 == "" ]]; then
    echo "arg1 - Path to CSV file with project,sha"
    echo "arg2 - Timeout in seconds"
    echo "arg3 - The script to run (Optional)"
    echo "arg4 - Test type (Optional)"
    echo "arg5 - Technique (Optional)"
    echo "arg6 - Time to keep docker image running after script finishes (Optional)"
    exit
fi

git rev-parse HEAD
date

projfile=$1
timeout=$2
script="$3"
testtype="$4"
technique="$5"
keepimagetime="$6"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

echo "*******************ACCOMMODATER************************"
echo "Making base image"
date

# Create base Docker image if does not exist
docker inspect accommodaterbase:latest > /dev/null 2>&1
if  [ $?  == 1 ]; then
    docker build -t accommodaterbase:latest - < baseDockerfile
fi

echo "*******************ACCOMMODATER************************"
echo "Making tooling image"
date

# Create tooling Docker image if does not exist
docker inspect toolingaccommodaterbase:latest > /dev/null 2>&1
if  [ $?  == 1 ]; then
    docker build -t toolingaccommodaterbase:latest - < toolingDockerfile
fi

# For each project,sha, make a Docker image for it
for line in $(cat ${projfile}); do
    # Create the corresponding Dockerfile
    slug=$(echo ${line} | cut -d',' -f1 | rev | cut -d'/' -f1-2 | rev)
    module=$(echo ${line} | cut -d',' -f2)
    newsha=$(echo ${line} | cut -d',' -f3)
    oldsha=$(echo ${line} | cut -d',' -f4)
    ./create_dockerfile.sh ${slug} ${newsha}

    # Build the Docker image if does not exist
    modifiedslug=$(echo ${slug} | sed 's;/;.;' | tr '[:upper:]' '[:lower:]')
    image=accommodater-${modifiedslug}:latest
    docker inspect ${image} > /dev/null 2>&1
    if [ $? == 1 ]; then
        echo "*******************ACCOMMODATER************************"
        echo "Building docker image for project"
        date
        bash build_docker_image.sh ${image} ${modifiedslug}
    fi

    # Run the Docker image if it exists
    docker inspect ${image} > /dev/null 2>&1
    if [ $? == 1 ]; then
        echo "${image} NOT BUILT PROPERLY, LIKELY TESTS FAILED"
    else
        docker run -t -v ${SCRIPT_DIR}:/Scratch ${image} /bin/bash -x /Scratch/run_experiment.sh ${slug} ${module} ${newsha} ${oldsha} ${timeout} "${script}" "${testtype}" "${technique}" "${keepimagetime}"
     fi
done

