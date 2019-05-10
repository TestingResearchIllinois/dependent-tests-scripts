#!/usr/bin/env bash

# $1 - Optional. Location of the setup script to run.
# $2 - Optional. What technique to run
# $3 - Optional. Whether to use Pradet or Minimizer for dependencies.

set -e

if [[ ! -z "$1" ]]; then
    # Generally the setup scripts are written so that they assume you are in a particular directory, so
    # make sure we match that.
    CURRENT=$(pwd)

    SCRIPT_DIR=$(dirname "$1")
    SCRIPT_NAME=$(basename "$1")

    echo "[INFO] Running setup script $SCRIPT_NAME in $SCRIPT_DIR"

    cd $SCRIPT_DIR
    . "$SCRIPT_NAME"

    cd $CURRENT
fi

if [[ ! -z "$2" ]]; then
    TECHNIQUE=$2
else
    TECHNIQUE=""
fi

PRADET=$3

. $DT_SCRIPTS/constants.sh

RESULTS_DIR="$DT_SCRIPTS/${SUBJ_NAME}-results"

echo "[INFO] Checking for results directory at $RESULTS_DIR"
# Make the results directory if it doesn't exist (and copy the setup script if applicable)
if [[ ! -d "$RESULTS_DIR" ]]; then
    echo "[INFO] Creating results directory"
    mkdir -p "$RESULTS_DIR"

    if [[ ! -z "$1" ]]; then
        echo "[INFO] Copying setup script"
        cp -f "$1" "$RESULTS_DIR"
    fi
fi

echo "[INFO] Compiling $SUBJ_NAME"
echo
if [[ ! "$@" =~ "skip-compile" ]]; then
    bash ./compile-subj.sh
    if [[ $? -ne 0 ]]; then
        exit 1
    fi
fi

# Get the orig order.
(
    cd $DT_SUBJ
    echo "[DEBUG] Finding human written tests in old subject."
    bash "$DT_SCRIPTS/get-test-order.sh" old
    if [ -n "${PRADET}" ]; then
        output_file_name="test-order"
        if [[ ! -z "$SUBJ_NAME" ]]; then
            output_file_name="$DT_SUBJ/$SUBJ_NAME-orig-order"
        else
            echo "WARNING ======== SUBJ_NAME not set ======="
        fi

        yes | cp -rf $output_file_name "$DT_SUBJ/test-execution-order"
    fi

    cd $NEW_DT_SUBJ
    echo "[DEBUG] Finding human written tests in new subject."
    bash "$DT_SCRIPTS/get-test-order.sh" new
)

# Generate randoop tests
#echo "[INFO] Generate Randoop tests for ${SUBJ_NAME}"
#bash generate-auto-tests.sh

NONDETERMINISTIC_OUTPUT="$RESULTS_DIR/nondeterministic-output.txt"
echo "[INFO] Running nondeterministic runner for ${SUBJ_NAME}"
echo
#bash nondeterministic-runner.sh $SETUP_SCRIPT &> "$NONDETERMINISTIC_OUTPUT"

echo "[INFO] Running dtdetector for ${SUBJ_NAME}"
echo
# orig
DTDETECTOR_OUTPUT="$RESULTS_DIR/randomize-output-orig.txt"
bash run-dtdetector.sh "$SETUP_SCRIPT" "old" "orig" &> "$DTDETECTOR_OUTPUT"
#DT_COUNT=$(cat "$DT_SCRIPTS/${SUBJ_NAME}-results/${SUBJ_NAME}-old-orig-randomize/list.txt" | wc -l)
#echo "[INFO] Found $DT_COUNT orig dependent tests using the dtdetector."
# auto
DTDETECTOR_OUTPUT="$RESULTS_DIR/randomize-output-auto.txt"
bash run-dtdetector.sh "$SETUP_SCRIPT" "old" "auto" &> "$DTDETECTOR_OUTPUT"
#DT_COUNT=$(cat "$DT_SCRIPTS/${SUBJ_NAME}-results/${SUBJ_NAME}-old-auto-randomize/list.txt" | wc -l)
#echo "[INFO] Found $DT_COUNT auto dependent tests using the dtdetector."
exit

SKIP_COMPILE="Y" # Always skip compile, because we did it already.
echo "[INFO] Running initial setup and runner (without dependencies.)"
echo
bash run-subj.sh $SKIP_COMPILE |& tee "$RESULTS_DIR/output.txt" | grep --line-buffered -v "Test being executed"

echo "[INFO] Copying results."
mv figure* "$RESULTS_DIR" || true

if [[ ! "$@" =~ "skip-precomputed" ]]; then

    if [[ -z "${PRADET}" ]]; then
        echo "[INFO] Running Minimizer."
        echo
        bash run-precomputed-dependencies.sh ${TECHNIQUE}
    else
        echo "[INFO] Running PRADET."
        echo
        CURRENT=$(pwd)
        bash -x run-pradet-tool.sh
        cd $CURRENT

        # Once we add tool to convert PRADET's refined-deps.csv to our format, we can have it run enhanced. The tool should be added directly to run-pradet-tools.sh
    fi


    # This is in here because we can only run the enhanced results if we have the precomputed dependencies.
    if [[ ! "$@" =~ "skip-enhanced" ]] && [[ -z "${PRADET}" ]]; then
        echo "[INFO] Running enhanced results."
        echo
        bash run-enhanced.sh ${TECHNIQUE}
    else
        echo "[INFO] Skipping enhanced results."
    fi
else
    echo "[INFO] Skipping precomputed dependencies."
fi

echo
echo "[INFO] Finished running ${SUBJ_NAME}"

