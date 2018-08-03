#!/usr/bin/env bash

# Usage: bash only-precomputed-dependencies.sh URL commit path/to/module

URL="$1"
COMMIT="$2"
PATH="$3"

PWD=$(pwd)

# Setup the environment variables
source ./constants.sh
source ./setup-vars.sh

PROJ_NAME=$(basename $URL)

export DT_SUBJ_ROOT="$DT_ROOT/$PROJ_NAME-old-$COMMIT"
SUBJECT_RESULTS="$DT_SCRIPTS/${SUBJ_NAME}-results"

echo "[INFO] Cloning project..."
git clone "$1" "$SUBJ_ROOT"

if [[ -d "$DT_SUBJ_ROOT" ]]; then
    (
        cd "$DT_SUBJ_ROOT"
        git checkout "$COMMIT"
    )
else
    echo "[INFO] Error occurred while cloning: directory does not exist"
    exit 1
fi

module=$(basename $PATH)

echo "[INFO] Setting environment variables."
export DT_SUBJ=${OLD_SUBJ_MODULE_DIRS[$i]}/target
export DT_SUBJ_SRC=${OLD_SUBJ_MODULE_DIRS[$i]}

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
cd "$PWD"

bash write-setup-script.sh

# Setup the environment variables again, now that we have all subject specific stuff set up.
source ./constants.sh
source ./setup-vars.sh

if [[ "$SKIP_COMPILE" == "N" ]]; then
    bash ./compile-subj.sh
    if [[ $? -ne 0 ]]; then
        exit 1
    fi
fi

# Runs commands for "Instructions to setup a subject for test prioritization" section.
bash ./setup-prio-first.sh

# Instructions to generate automatically-generated tests for a subject
bash ./generate-sootTestOutput-auto-first.sh

# Runs commands for "Instructions to setup a subject for test selection" section.
bash ./setup-sele-first.sh

# Runs commands for "Instructions to setup a subject for test parallelization" section.
bash ./setup-para.sh

bash run-precomputed-dependencies.sh

