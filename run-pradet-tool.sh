#!/usr/bin/env bash

# Usage: run-precomputed-dependencies.sh [prio|para]
# Should have run setup script before running this script.

source ./constants.sh

STAGE=""
if [[ ! -z "$1" ]]; then
    STAGE="$1"
fi

startTime=`date`

CLASSPATH=$DT_LIBS:$DT_CLASS:$DT_RANDOOP:$DT_TESTS:

cd $DT_SUBJ_SRC

export BIN=/home/awshi2/pradet-replication/bin
export DATADEP_DETECTOR_HOME=/home/awshi2/pradet-replication/datadep-detector

export PATH=/home/awshi2/apache-maven/bin:${PATH}
echo "PATH: $PATH"

bash /home/awshi2/pradet-replication/scripts/generate_test_order.sh target/test-execution-order

# Gather data about enumerations used in the test subject
bash /home/awshi2/pradet-replication/scripts/bootstrap_enums.sh

# Create the white list package to instrument the test subject code
bash /home/awshi2/pradet-replication/scripts/create_package_filter.sh

# Finally start the collection
bash /home/awshi2/pradet-replication/scripts/collect.sh

bash /home/awshi2/pradet-replication/scripts/refine.sh

# Temp fix to save pradet results; Removve when ConvertPradetDeps is completed
mkdir -p "$DT_DATA/$prioList"
cp refined-deps.csv "$DT_DATA/$prioList/"
mkdir -p "$DT_DATA/$seleList"
cp refined-deps.csv "$DT_DATA/$seleList/"
mkdir -p "$DT_DATA/$paraList"
cp refined-deps.csv "$DT_DATA/$paraList/"

# Generate dt lists
#java -cp $DT_TOOLS: edu.washington.cs.dt.impact.tools.ConvertPradetDeps -pradetDeps refined-deps.csv -prioOutputDirectory "$DT_DATA/$prioList" -seleOutputDirectory "$DT_DATA/$seleList" -paraOutputDirectory "$DT_DATA/$paraList"

echo "[INFO] Copying dt-lists."
RESULTS_DIR="$DT_SCRIPTS/${SUBJ_NAME}-results/dt-lists/"
mkdir -p "$RESULTS_DIR/$prioList"
cp "$DT_ROOT/data/$prioList/* "$RESULTS_DIR/$prioList"
mkdir -p "$RESULTS_DIR/$seleList"
cp "$DT_ROOT/data/$seleList/* "$RESULTS_DIR/$seleList"
mkdir -p "$RESULTS_DIR/$paraList"
cp "$DT_ROOT/data/$paraList/* "$RESULTS_DIR/$paraList"

# Defined in constants.sh
copy_results "precomputed"

echo "[INFO] Script has finished running."

echo "[INFO] Start time was ${startTime}"
endTime=`date`
echo "[INFO] End time is ${endTime}"

