#!/usr/bin/env bash

# Usage: bash sample-commits.sh GIT_REPO_PATH START_COMMIT COMMIT_NUM MODULE_PATH [random|uniform] [CUTOFF_DAYS]
# Will sample COMMIT_NUM commits from git repository provided after the given date.
# Can sample either randomly or uniformly (meaning at uniform intervals).
# If CUTOFF_DAYS is provided, will sample COMMIT_NUM commits from CUTOFF_DAYS after START_COMMIT **AND** COMMIT_NUM commits from before CUTOFF_DAYS after START_COMMIT
# Will write the commit lists to new-commit-list.txt and old-commit-list.txt

GIT_REPO_PATH="$1"
START_COMMIT="$2"
COMMIT_NUM="$3"
MODULE_PATH="$4"
SELECT_TYPE="$5"
CUTOFF_DAYS="$6"

ORIGINAL_DIR="$(pwd)"

cd $GIT_REPO_PATH

startDate=$(git show -s --format="%ci" $START_COMMIT)
cutoffDate=$(date -d "$startDate+$CUTOFF_DAYS days")

runWithCommits() {
    COMMIT_PATH="$1"

    (
        cd "$ORIGINAL_DIR"
        python sample-commits.py "$COMMIT_PATH" "$COMMIT_NUM" "$SELECT_TYPE"
    )
}

# Clear files
> "new-commit-list.txt"
> "old-commit-list.txt"

tmpFile="$(mktemp)"
if [[ -z "$CUTOFF_DAYS" ]]; then
    git log -s --format="%H" --reverse ${START_COMMIT}..HEAD -- "$MODULE_PATH" > $tmpFile
    runWithCommits $tmpFile
else
    git log -s --format="%H" --before="$cutoffDate" --reverse ${START_COMMIT}.. -- "$MODULE_PATH" > $tmpFile
    runWithCommits $tmpFile

    git log -s --format="%H" --after="$cutoffDate" --reverse ${START_COMMIT}.. -- "$MODULE_PATH" > $tmpFile
    runWithCommits $tmpFile
fi

