#!/usr/bin/env bash

# Usage: bash only-precomputed-dependencies.sh URL commit path/to/module

set -e

url="$1"
commit="$2"
path="$3"

CWD=$(pwd)

# Setup the environment variables
. ./constants.sh
. ./setup-vars.sh

PROJ_NAME=$(basename $url)

export DT_SUBJ_ROOT="$DT_ROOT/$PROJ_NAME-old-$commit"
SUBJECT_RESULTS="$DT_SCRIPTS/${SUBJ_NAME}-results"

if [[ ! -d "$DT_SUBJ_ROOT" ]]; then
    echo "[INFO] Cloning project..."
    git clone "$url" "$DT_SUBJ_ROOT"
fi

if [[ -d "$DT_SUBJ_ROOT" ]]; then
    (
        cd "$DT_SUBJ_ROOT"
        git checkout "$commit"
    )
else
    echo "[INFO] Error occurred while cloning: directory does not exist"
    exit 1
fi

module=$(basename $path)

echo "[INFO] Setting environment variables."
export DT_SUBJ="$DT_SUBJ_ROOT/$path/target"
export DT_SUBJ_SRC="$DT_SUBJ_ROOT/$path"

if [[ "$module" = "." ]]; then
    export SUBJ_NAME="${PROJ_NAME}"
    export SUBJ_NAME_FORMAL="${PROJ_NAME}"
else
    export SUBJ_NAME="${PROJ_NAME}-$module"
    export SUBJ_NAME_FORMAL="${PROJ_NAME}-$module"
fi

echo "[INFO] Checking for test files."

cd "$DT_SUBJ_SRC"
export DT_TEST_SRC=$(mvn -B help:evaluate -Dexpression=project.build.testSourceDirectory | grep -vE "\[")
echo "[INFO] Test source directory for ${SUBJ_NAME} (old) is $DT_TEST_SRC"
if [[ ! -d "$DT_TEST_SRC" ]]; then
    echo "[INFO] $SUBJ_NAME has no test files, skipping."
    exit 1
fi
cd "$CWD"

RESULTS_DIR="$DT_SCRIPTS/${SUBJ_NAME}-results"

echo "[INFO] Checking for results directory at $RESULTS_DIR"
# Make the results directory if it doesn't exist (and copy the setup script if applicable)
if [[ ! -d "$RESULTS_DIR" ]]; then
    echo "[INFO] Creating results directory"
    mkdir "$RESULTS_DIR"
fi

# Setup the environment variables again, now that we have all subject specific stuff set up.
source ./constants.sh
source ./setup-vars.sh

SETUP_SCRIPT="$DT_SCRIPTS/${SUBJ_NAME}-results/setup-$SUBJ_NAME.sh"
bash write-setup-script.sh "$SETUP_SCRIPT"

exit 0

if [[ "$SKIP_COMPILE" == "N" ]]; then
    bash ./compile-subj.sh
    if [[ $? -ne 0 ]]; then
        exit 1
    fi
fi

NONDETERMINISTIC_OUTPUT="$RESULTS_DIR/nondeterministic-output.txt"
echo "[INFO] Running nondeterministic runner for ${SUBJ_NAME}"
echo
bash nondeterministic-runner.sh $SETUP_SCRIPT &> "$NONDETERMINISTIC_OUTPUT"

DTDETECTOR_OUTPUT="$RESULTS_DIR/randomize-output.txt"
echo "[INFO] Running dtdetector for ${SUBJ_NAME}"
echo
bash run-dtdetector.sh $SETUP_SCRIPT &> "$DTDETECTOR_OUTPUT"

DT_COUNT=$(cat "$DTDETECTOR_OUTPUT" | wc -l)

echo "[INFO] Found $DT_COUNT dependent tests using the dtdetector."

# Runs commands for "Instructions to setup a subject for test prioritization" section.
bash ./setup-prio-first.sh

# Instructions to generate automatically-generated tests for a subject
bash ./generate-sootTestOutput-auto-first.sh

# Runs commands for "Instructions to setup a subject for test selection" section.
bash ./setup-sele-first.sh

# Runs commands for "Instructions to setup a subject for test parallelization" section.
bash ./setup-para.sh

bash run-precomputed-dependencies.sh

