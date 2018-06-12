#!/usr/bin/env bash

# $1 - Optional. Location of the setup script to run.
# $2 - Optional (new or old). Whether to run new or old subject. Defaults to 'new'.
# $3 - Optional (orig or auto). Whether to run for the auto tests or the orig tests. Defaults to 'orig'.

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

echo "[INFO] Running subject ${SUBJ_NAME}, NEW_DT_SUBJ=$NEW_DT_SUBJ"

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

echo "[INFO] Running main program."

ORDER="orig"
if [[ ! -z "$3" ]]; then
    ORDER="$3"
fi

PREFIX="new"

if [[ ! -z "$2" ]]; then
    if [[ "$2" = "old" ]]; then
        PREFIX="old"
    fi
fi

if [[ "$PREFIX" = "old" ]]; then
    cd $DT_SUBJ_SRC
    java -Xmx8000M -cp $DT_TOOLS:$DT_TESTS:$DT_CLASS:$DT_LIBS:$DT_RANDOOP: edu.washington.cs.dt.main.Main --randomize=true --round=1000 --tests=$DT_SUBJ/${SUBJ_NAME}-${ORDER}-order
else
    cd $NEW_DT_SUBJ_SRC
    java -Xmx8000M -cp $DT_TOOLS:$NEW_DT_TESTS:$NEW_DT_CLASS:$NEW_DT_LIBS:$NEW_DT_RANDOOP: edu.washington.cs.dt.main.Main --randomize=true --round=1000 --tests=$NEW_DT_SUBJ/${SUBJ_NAME}-${ORDER}-order
fi

RANDOMIZE_RESULTS="${SUBJ_NAME}-${PREFIX}-${ORDER}-randomize"

# Move the results
echo "[INFO] Moving results to $RANDOMIZE_RESULTS"
mkdir "$RANDOMIZE_RESULTS"
mv randomize_* "$RANDOMIZE_RESULTS"

# Calculate how many unique tests there are and write them to a file.
echo "[INFO] Counting unique dts"
grep -hR "Test: " "$RANDOMIZE_RESULTS"/* | sed -E "s/Test: (.*)$/\1/g" | sort | uniq > "$RANDOMIZE_RESULTS/dt-list.txt"
COUNT=$(cat "$RANDOMIZE_RESULTS/dt-list.txt" | wc -l)

# Zip things (and remove old directory) and send to the results directory.
echo "[INFO] Zipping results and copying to $RESULTS_DIR"
zip -r "$RANDOMIZE_RESULTS.zip" "$RANDOMIZE_RESULTS"
rm -rf "$RANDOMIZE_RESULTS"
mv "$RANDOMIZE_RESULTS.zip" "$RESULTS_DIR"

echo "[INFO] Found $COUNT dependent tests, wrote list to $RANDOMIZE_RESULTS/dt-list.txt"

