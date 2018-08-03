#!/usr/bin/env bash

SKIP_COMPILE="N"

if [[ ! -z "$1" ]]; then
    SKIP_COMPILE="$1"
fi

# Setup the environment variables
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

