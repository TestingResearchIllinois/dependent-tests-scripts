#!/usr/bin/env bash

# This script should be run in a directory containing one of more directories ending in "results"
# each on which contains a setup script for a subject (the script's name should begin with "setup")

for dirname in $(ls -1 | grep "results$")
do
    (
        CUR_DIR=$(pwd)

        cd $dirname

        SETUP_SCRIPT=$(ls -1 | grep -E "setup.*\.sh" | head -1)

        # Check if there is a setup script in this directory at all.
        if [[ ! -z "$SETUP_SCRIPT" ]]; then
            . "$SETUP_SCRIPT"

            echo "[INFO] Running randomize with setup script: $SETUP_SCRIPT"
            cd $CUR_DIR

            echo "[DEBUG] nohup bash run-dtdetector.sh \"$SETUP_SCRIPT\" &> \"$dirname/${SUBJ_NAME}-randomize.txt\" &"
            nohup bash run-dtdetector.sh "$dirname/$SETUP_SCRIPT" &> "$dirname/${SUBJ_NAME}-randomize.txt" &
        else
            echo "[INFO] No setup scripts found in $dirname"
        fi
    )
done

