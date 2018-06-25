#!/usr/bin/env bash

# Inputs:
# $1 - Git repo url
# $2 - commit to run (new)
# $3 - commit to run (old)
# $4 - path in repo (probably for module)
# $5 - Subj name
# $6 - Subj name formal
# $7 - Original subject version's DT_SUBJ

# Run to get things like DT_ROOT and DT_SCRIPTS
. ../setup-vars.sh

GIT_URL=$1
NEW_COMMIT=$2
OLD_COMMIT=$3
MODULE_PATH=$4
export SUBJ_NAME=$5
export SUBJ_NAME_FORMAL=$6
ORIGINAL_DT_SUBJ=$7

PROJ_NAME=$(echo $GIT_URL | grep -Eo "([^/]+)\$") # Detect the project name

MAIN_ROOT="$DT_ROOT/${PROJ_NAME}"
PRECOMPUTED_LIFETIME_ROOT="$DT_SCRIPTS/precomputed-lifetime"

export DT_SUBJ_ROOT="${MAIN_ROOT}-old-$OLD_COMMIT"
export NEW_DT_SUBJ_ROOT="${MAIN_ROOT}-new-$NEW_COMMIT"

echo "[INFO] Starting $PROJ_NAME with commits $NEW_COMMIT and $OLD_COMMIT"
# 1. Download project at specified commit (INPUT)
git clone $GIT_URL $DT_SUBJ_ROOT
git clone $GIT_URL $NEW_DT_SUBJ_ROOT

# Set project version.
echo "[INFO] Setting project versions."

# Use these checks ot make sure we don't accidentally reset the git repo we are currently in.
if [[ -d "$NEW_DT_SUBJ_ROOT" ]]; then
    cd $NEW_DT_SUBJ_ROOT
    echo "[INFO] Resetting $NEW_DT_SUBJ_ROOT to $NEW_COMMIT"
    git reset --hard "$NEW_COMMIT"
else
    echo "Directory not found: $NEW_DT_SUBJ_ROOT"
    exit 1
fi

cd $NEW_DT_SUBJ_ROOT
new_date=$(git log -1 --format="%cd" --date=format:"%Y-%m-%d-%H-%M-%S")
echo "[INFO] Date of new commit is: $new_date"

if [[ -d "$DT_SUBJ_ROOT" ]]; then
    cd $DT_SUBJ_ROOT
    echo "[INFO] Resetting $DT_SUBJ_ROOT to $OLD_COMMIT"
    git reset --hard "$OLD_COMMIT"
else
    echo "Directory not found: $DT_SUBJ_ROOT"
    exit 1
fi

# Setup environment variables

echo "[INFO] Setting environment variables"
export DT_SUBJ=$DT_SUBJ_ROOT/$MODULE_PATH/target
export DT_SUBJ_SRC=$DT_SUBJ_ROOT/$MODULE_PATH

export NEW_DT_SUBJ=$NEW_DT_SUBJ_ROOT/$MODULE_PATH/target
export NEW_DT_SUBJ_SRC=$NEW_DT_SUBJ_ROOT/$MODULE_PATH

cd $PRECOMPUTED_LIFETIME_ROOT
source "$DT_SCRIPTS/setup-vars.sh"

bash "$DT_SCRIPTS/write-setup-script.sh" "setup-${PROJ_NAME}-${new_date}-${NEW_COMMIT}.sh"

# Modified version of run-subj.sh (but using the precomputed dependencies we already have).
echo "[INFO] Compiling subject."
bash $DT_SCRIPTS/compile-subj.sh > /dev/null
if [[ $? -ne 0 ]]; then
    echo "[INFO] Compilation failed, exiting."
    exit 1
fi

# Make sure the env-files exist
if [[ ! -e $DT_SUBJ/$SUBJ_NAME-env-files ]]; then
    touch $DT_SUBJ/$SUBJ_NAME-env-files
fi

if [[ ! -e $NEW_DT_SUBJ/$SUBJ_NAME-env-files ]]; then
    touch $NEW_DT_SUBJ/$SUBJ_NAME-env-files
fi

# Runs commands for "Instructions to setup a subject for test prioritization" section.
bash $DT_SCRIPTS/setup-prio.sh

# Copy the auto tests over from the old version.
bash $PRECOMPUTED_LIFETIME_ROOT/copy-auto-tests.sh "$ORIGINAL_DT_SUBJ/randoop"

# Runs commands for "Instructions to setup a subject for test selection" section.
bash $DT_SCRIPTS/setup-sele.sh

# Runs commands for "Instructions to setup a subject for test parallelization" section.
bash $DT_SCRIPTS/setup-para.sh

bash run-with-deps.sh

# Save results for later
result_dir="$PRECOMPUTED_LIFETIME_ROOT/${PROJ_NAME}-${new_date}-${NEW_COMMIT}"
mkdir -p $result_dir
mv $DT_ROOT/prioritization-results $result_dir
mv $DT_ROOT/selection-results $result_dir
mv $DT_ROOT/parallelization-results $result_dir

cd $PRECOMPUTED_LIFETIME_ROOT

