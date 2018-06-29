#!/usr/bin/env bash

# Usage: bash result-updater-isolation.sh <RESULTS_FOLDERS...>
# NOTE: Environment variables should be set up first.
# NOTE: RESULTS_FOLDER MUST BE IN THE CURRENT DIRECTORY.
# NOTE: There must also be a setup-script with the name setup-$RESULTS_FOLDER.sh in the current directory

# TODO: NOTE: This file was only used for updating the format of some result files.
#             It is probably no longer useful at 2018-07-06.

set -e

for RESULTS_FOLDER in "$@"; do
    if [[ ! -d "$RESULTS_FOLDER" ]]; then
        continue
    fi

    SETUP_SCRIPT="setup-$RESULTS_FOLDER.sh"

    if [[ ! -e "$SETUP_SCRIPT" ]]; then
        # Generally the setup scripts are written so that they assume you are in a particular directory, so
        # make sure we match that.
        CURRENT=$(pwd)

        SCRIPT_DIR=$(dirname "$SETUP_SCRIPT")
        SCRIPT_NAME=$(basename "$SETUP_SCRIPT")

        echo "[INFO] Running setup script $SCRIPT_NAME in $SCRIPT_DIR"

        cd $SCRIPT_DIR
        . "$SCRIPT_NAME"

        cd $CURRENT
    else
        echo "No setup script found with name $SETUP_SCRIPT!"
        exit 1
    fi

    echo "[INFO] Running subject ${SUBJ_NAME}"

    RESULTS_DIR="$DT_SCRIPTS/${SUBJ_NAME}-results"

    echo "[INFO] Checking for results directory at $RESULTS_DIR"
    # Make the results directory if it doesn't exist (and copy the setup script if applicable)
    if [[ ! -d "$RESULTS_DIR" ]]; then
        echo "[INFO] Creating results directory"
        mkdir "$RESULTS_DIR"

        if [[ ! -z "$1" ]]; then
            echo "[INFO] Copying setup script"
            cp "$1" "$RESULTS_DIR"
        fi
    fi

    java -cp $DT_TOOLS: edu.washington.cs.dt.impact.tools.ResultFileUpdater -cp "$DT_TOOLS:$NEW_DT_CLASS:$NEW_DT_TESTS:$NEW_DT_LIBS:$NEW_DT_RANDOOP" --orig-order "$NEW_DT_SUBJ/${SUBJ_NAME}-orig-order" --auto-order "$NEW_DT_SUBJ/${SUBJ_NAME}-auto-order" --result-dir "$RESULTS_FOLDER"
done

