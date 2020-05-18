#!/usr/bin/env bash

echo "*******************PRADET************************"
echo "Starting run_pradet_tools.sh"

# This script is run inside the Docker image, for single experiment (one project)
# Should only be invoked by the run_experiment.sh script

if [[ $1 == "" ]] || [[ $2 == "" ]] || [[ $3 == "" ]] || [[ $4 == "" ]] || [[ $5 == "" ]]; then
    echo "arg1 - GitHub SLUG"
    echo "arg2 - Module"
    echo "arg3 - New commit"
    echo "arg4 - Old commit"
    echo "arg5 - Timeout in seconds"
    echo "arg6 - Test type (Optional)"
    echo "arg7 - Technique (Optional)"
    exit
fi

slug=$1
module=$2
newcommit=$3
oldcommit=$4
timeout=$5


# Run the plugin, get module test times
echo "*******************PRADET************************"
echo "Running the pradet tools for one commit"
cd /home/awshi2/${slug}/
git rev-parse HEAD
date

export PATH=/home/awshi2/apache-maven/bin:${PATH}
cd /home/awshi2/

echo "================ Setting up pradet"
git clone https://github.com/gmu-swe/pradet-replication.git
cd pradet-replication/
./setup-datadep-detector.sh

export BIN=/home/awshi2/pradet-replication/bin
export DATADEP_DETECTOR_HOME=/home/awshi2/pradet-replication/datadep-detector

mkdir -p /home/awshi2/old
cd /home/awshi2/old

echo "================ Setting up old commit"
git clone https://github.com/$slug $slug
cd $slug
git checkout $oldcommit
timeout 1h /home/awshi2/apache-maven/bin/mvn clean install dependency:copy-dependencies -DskipTests -fn -B |& tee /home/awshi2/old/$slug/mvn-install.log

cd $module
echo "================ extract_test_names_from_maven_output.sh"
/home/awshi2/pradet-replication/scripts/extract_test_names_from_maven_output.sh
mv maven_test_execution_order test-execution-order
echo "================ generate_test_order.sh"
/home/awshi2/pradet-replication/scripts/generate_test_order.sh test-execution-order
echo "================ bootstrap_enums.sh"
/home/awshi2/pradet-replication/scripts/bootstrap_enums.sh
echo "================ create_package_filter.sh"
/home/awshi2/pradet-replication/scripts/create_package_filter.sh
echo "================ collect.sh"
/home/awshi2/pradet-replication/scripts/collect.sh
echo "================ refine.sh"
/home/awshi2/pradet-replication/scripts/refine.sh

echo "================ Saving outputs"
RESULTSDIR=/home/awshi2/output/
mkdir -p ${RESULTSDIR}

mv mvn-install.log ${RESULTSDIR}
mv cp.txt ${RESULTSDIR} 
mv deps.csv ${RESULTSDIR}
mv enumerations ${RESULTSDIR}
mv package-filter ${RESULTSDIR}
mv pradet/ ${RESULTSDIR}
mv reference-output.csv* ${RESULTSDIR}
mv refined-deps.csv ${RESULTSDIR}
mv run-order-* ${RESULTSDIR}
mv test-execution-order ${RESULTSDIR}
mv maven_test_execution_order ${RESULTSDIR}

echo "*******************PRADET************************"
echo "Finished run_pradet_tools.sh"
date
