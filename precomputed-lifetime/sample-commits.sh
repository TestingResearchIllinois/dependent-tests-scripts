#!/usr/bin/env bash

# Usage: bash sample-commits.sh GIT_REPO_PATH START_COMMIT COMMIT_NUM MODULE_PATH [random|uniform]
# Will sample COMMIT_NUM commits from git repository provided after the given date.
# Can sample either randomly or uniformly (meaning at uniform intervals).
# Will write the commit list to new-commit-list.txt

if [[ "$1" == "--help" ]]; then
    echo "Usage: ./sample-commits.sh project-dir start-commit num-commits path-of-module [random|uniform]"
    exit 1
fi

if [[ "$#" -lt 1 ]]; then
    echo "Usage: ./sample-commits.sh project-dir start-commit num-commits path-of-module [random|uniform]"
    exit 1
fi

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
git log -s --format="%H" --reverse "${START_COMMIT}" -- "$MODULE_PATH" > $tmpFile   # Only look back at most 100 commits
#runWithCommits $tmpFile
for c in $(tac $tmpFile); do
    # Skip commits without any change to java file in the module
    if [[ $(git show --name-only --oneline ${c} | grep ".java$") == "" ]]; then
        continue
    fi

    # Try checking out the commit and installing/testing, only keeping those that succeed
    git checkout -f ${c}
    /home/awshi2/apache-maven/bin/mvn install -Dmavanagaiata.skip=true -Drat.skip=true -Ddependency-check.skip=true -Dcheckstyle.skip=true -Dmaven.javadoc.skip=true -Dmaven-source.skip=true -Dcobertura.skip -DskipTests &> /dev/null
    # If does not compile, skip
    if [[ $? != 0 ]]; then
        continue
    fi
    (
        cd $GIT_REPO_PATH/$MODULE_PATH
        /home/awshi2/apache-maven/bin/mvn install -Dmavanagaiata.skip=true -Drat.skip=true -Ddependency-check.skip=true -Dcheckstyle.skip=true -Dmaven.javadoc.skip=true -Dmaven-source.skip=true -Dcobertura.skip &> /dev/null
        # If it all works, report it successful
        if [[ $? == 0 ]]; then
            echo ${c} >> "$ORIGINAL_DIR/new-commit-list.txt"
        fi
    )

    if [[ $(cat "$ORIGINAL_DIR/new-commit-list.txt" | wc -l) == $COMMIT_NUM ]]; then
        break
    fi
done
rm ${tmpFile}

#git log -s --format="%H" --after="$cutoffDate" --reverse ${START_COMMIT}.. -- "$MODULE_PATH" > $tmpFile
#runWithCommits $tmpFile

