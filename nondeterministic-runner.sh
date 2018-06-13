#!/usr/bin/env bash

# $1 - Optional. Location of the setup script to run.
# $2 - Optional (new or old). Whether to run new or old subject. Defaults to 'old'.
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

source $DT_SCRIPTS/config.sh

startTime=$(date +%s)

version="old"
if [[ ! -z "$2" ]]; then
    version="$2"
fi

testType="orig"
if [[ ! -z "$3" ]]; then
    testType="$3"
fi

numTimesToRun=100
crossReferenceClass=edu.washington.cs.dt.impact.tools.CrossReferencer

if [[ "$version" == "old" ]]; then
    if [[ "$testType" == "orig" ]]; then
        experimentCP=$DT_TOOLS:$DT_CLASS:$DT_TESTS:$DT_LIBS:
    else
        experimentCP=$DT_TOOLS:$DT_CLASS:$DT_RANDOOP:$DT_LIBS:
    fi
    testOrder=$DT_SUBJ/${SUBJ_NAME}-${testType}-order
else
    if [[ "$testType" == "orig" ]]; then
        experimentCP=$DT_TOOLS:$NEW_DT_CLASS:$NEW_DT_TESTS:$NEW_DT_LIBS:
    else
        experimentCP=$DT_TOOLS:$NEW_DT_CLASS:$NEW_DT_RANDOOP:$NEW_DT_LIBS:
    fi
    testOrder=$NEW_DT_SUBJ/${SUBJ_NAME}-${testType}-order
fi

RESULTS_DIR="$DT_SCRIPTS/${SUBJ_NAME}-results"
NONDETERMINISTIC_FOLDER="${SUBJ_NAME}-${version}-${testType}-nondeterministic"

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

echo "[INFO] Results will be written to $RESULTS_DIR/$NONDETERMINISTIC_FOLDER"

echo "[INFO] Running main program."

echo -e "Starting experiment: $SUBJ_NAME"

if [[ "$version" == "new" ]]; then
    cd $NEW_DT_SUBJ_SRC
else
    cd $DT_SUBJ_SRC
fi

if [[ -d "$NONDETERMINISTIC_FOLDER/" ]]; then
    rm -rf $NONDETERMINISTIC_FOLDER
fi
mkdir $NONDETERMINISTIC_FOLDER/

if [[ "$version" == "new" ]]; then
    cp $DT_SUBJ/$SUBJ_NAME-$testType-order $NONDETERMINISTIC_FOLDER/deterministic-order
else
    cp $NEW_DT_SUBJ/$SUBJ_NAME-$testType-order $NONDETERMINISTIC_FOLDER/deterministic-order
fi

while [[ "$k" -le "$numTimesToRun" ]]
do
    echo '======================= Start ' $k ' ======================='

    echo "[INFO] Running order for first time."
    clearProjectFiles
    java -cp $experimentCP edu.washington.cs.dt.main.ImpactMain -inputTests $NONDETERMINISTIC_FOLDER/deterministic-order > $NONDETERMINISTIC_FOLDER/${SUBJ_NAME}-${testType}-order-results.txt

    echo "[INFO] Re-running order."
    clearProjectFiles
    java -cp $experimentCP edu.washington.cs.dt.main.ImpactMain -inputTests $NONDETERMINISTIC_FOLDER/deterministic-order > $NONDETERMINISTIC_FOLDER/${SUBJ_NAME}-${testType}-rerun-results.txt

    echo "[INFO] Cross referencing."
    java -cp $experimentCP $crossReferenceClass -origOrder $NONDETERMINISTIC_FOLDER/${SUBJ_NAME}-${testType}-order-results.txt -testOrder $NONDETERMINISTIC_FOLDER/${SUBJ_NAME}-${testType}-rerun-results.txt > $NONDETERMINISTIC_FOLDER/cross-referencer-file.txt

    if [[ $((k % 100)) = 0 ]] ; then
      j=$(($j+1))
      echo "" > $NONDETERMINISTIC_FOLDER/debug.log$j
    fi

    echo '======================= Start ' $k ' =======================' >> $NONDETERMINISTIC_FOLDER/debug.log$j
    cat $NONDETERMINISTIC_FOLDER/cross-referencer-file.txt >> $NONDETERMINISTIC_FOLDER/debug.log$j
    echo "" >> $NONDETERMINISTIC_FOLDER/debug.log$j

    echo "[INFO] Finding non-deterministic tests"
    java -cp $experimentCP edu.washington.cs.dt.impact.tools.UndeterministicTestFinder -undeterministicTestFile $NONDETERMINISTIC_FOLDER/undeterminisitic-order -deterministicTestFile $NONDETERMINISTIC_FOLDER/deterministic-order -crossReferenceFile $NONDETERMINISTIC_FOLDER/cross-referencer-file.txt -randomizeDeterministicTests

    k=$(($k+1))

    curTime=$(date +%s)
    timePerRound=$(( (curTime - startTime) / k ))
    echo "[INFO] Estimated time remaining: $(( timePerRound * (numTimesToRun - k) ))"
done
clearProjectFiles


if [[ -d "$RESULTS_DIR/$NONDETERMINISTIC_FOLDER" ]]; then
    rm -rf "$RESULTS_DIR/$NONDETERMINISTIC_FOLDER"
else
    mv $NONDETERMINISTIC_FOLDER/ $RESULTS_DIR
fi

cd $RESULTS_DIR
cd $NONDETERMINISTIC_FOLDER/
grep -hoFf $testOrder debug.log* | sort | uniq > nondeterministic-list.txt

# Make sure we ignore the nondeterministic tests for everything else.
if [[ -e "$RESULTS_DIR/${SUBJ_NAME}-ignore-order" ]]; then
    cat "nondeterministic-list.txt" "$RESULTS_DIR/${SUBJ_NAME}-ignore-order" | sort | uniq > temp
    mv temp "$RESULTS_DIR/${SUBJ_NAME}-ignore-order"
else
    cp "nondeterministic-list.txt" "$RESULTS_DIR/${SUBJ_NAME}-ignore-order"
fi

echo "[INFO] Finished. Found $(cat nondeterministic-list.txt | wc -l) nondeterministic tests."

