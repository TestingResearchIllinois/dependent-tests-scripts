#!/bin/bash

# Runs the enhanced T2 algorithm (prioritization, statement, relative) on kevinsawicki/http-request (M9).
# Usage: bash example.sh

# Clear any existing logs
rm -rf logs/
mkdir logs/

# Clone the firstVers if it doesn't exist
if [ ! -d "firstVers" ]; then
    echo "Cloning firstVers"
    git clone https://github.com/kevinsawicki/http-request.git firstVers  > logs/firstVers-clone-log.txt
    echo "Compiling firstVers"
    cd firstVers/lib/
    git checkout d0ba95cf3c621c74a023887814e8c1f73b5da1b2 > logs/checkout-firstVers.txt
    mvn install dependency:copy-dependencies -DskipTests > logs/install-log-firstVers.txt
    cd ../../
fi

# Clone the secondVers if it doesn't exist
if [ ! -d "secondVers" ]; then
    echo "Cloning secondVers"
    git clone https://github.com/kevinsawicki/http-request.git secondVers > logs/secondVers-clone-log.txt
    echo "Compiling secondVers"
    cd secondVers/lib/
    git checkout ef89ec663e6d192c08b77dd1d9b8649975c1419c > logs/checkout-secondVers.txt
    mvn install dependency:copy-dependencies -DskipTests > logs/install-log-secondVers.txt
    cd ../../
fi

# Clear any existing results
rm -rf lib-results/

echo "Setting up the two versions for regression testing"
bash setup.sh firstVers/lib t2 secondVers/lib > logs/setup.txt
echo "Computing dependencies on the firstVers"
bash compute-deps.sh firstVers/lib t2 secondVers/lib > logs/compute-deps.txt
echo "Running the regression testing algorithm on the secondVers"
bash run.sh firstVers/lib t2 secondVers/lib > logs/run.txt
