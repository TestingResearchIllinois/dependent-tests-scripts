#!/usr/bin/env bash

# Usage: bash sample-commits.sh GIT_REPO_PATH START_COMMIT COMMIT_NUM MODULE_PATH SUCCESSFUL_COMMITS [random|uniform] 
# Will sample COMMIT_NUM commits from git repository provided after the given date.
# Can sample either randomly or uniformly (meaning at uniform intervals).
# Will write the commit list to new-commit-list.txt

GIT_REPO_PATH="$1"
START_COMMIT="$2"
COMMIT_NUM="$3"
MODULE_PATH="$4"
#SUCCESSFUL_COMMITS="$5"
SELECT_TYPE="$5"

ORIGINAL_DIR="$(pwd)"

echo "[INFO] Selecting $COMMIT_NUM commits using selection type $SELECT_TYPE"

cd $GIT_REPO_PATH
git pull # In case we are out of date, make sure we update to have the latest for the commit selection.

#startDate=$(git show -s --format="%ci" $START_COMMIT)
#cutoffDate=$(date -d "$startDate+$SUBJ_CUTOFF days")

#echo "[INFO] Cutoff date is $cutoffDate"

runWithCommits() {
    COMMIT_PATH="$1"

    (
        cd "$ORIGINAL_DIR"
        echo "[INFO] Found $(cat $COMMIT_PATH | wc -l) commits."
        python sample-commits.py "$COMMIT_PATH" "$COMMIT_NUM" "$SELECT_TYPE"
    )
}

# Clear files
> "$ORIGINAL_DIR/new-commit-list.txt"

tmpFile="$(mktemp)"
#git log -s --format="%H" --before="$cutoffDate" --reverse ${START_COMMIT}.. -- "$MODULE_PATH" > $tmpFile
git log -s --format="%H" --reverse "${START_COMMIT}"~100.. -- "$MODULE_PATH" > $tmpFile   # Only look back at most 100 commits
runWithCommits $tmpFile
rm ${tmpFile}

#git log -s --format="%H" --after="$cutoffDate" --reverse ${START_COMMIT}.. -- "$MODULE_PATH" > $tmpFile
#runWithCommits $tmpFile

