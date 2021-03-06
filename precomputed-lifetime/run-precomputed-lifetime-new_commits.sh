# Inputs:
# $1 - project slug
# $2 - path in repo (probably for module)
# $3 - old commit to run for project/module
# $4 - new commit to run for project/module
# $5 - test types
# $6 - techniques to use (e.g., prio-sele-para or prio-para or sele-prio). Optional. If not provided, then will use all by default

if [[ "$1" == "--help" ]]; then
    echo "Usage: ./run-precomputed-lifetime.sh project-slug relative-module-path old_commit new_commit [testtypes] [techniques]"
    exit 1
fi

if [[ "$#" -lt 1 ]]; then
    echo "Usage: ./run-precomputed-lifetime.sh project-slug relative-module-path old_commit new_commit [testtypes] [techniques]"
    exit 1
fi

PROJ_SLUG=$1
MODULE_PATH=$2
OLD_COMMIT="$3"
NEW_COMMIT="$4"
TESTTYPES="$5"
TECHNIQUES="$6"

PROJ_NAME=$(echo $PROJ_SLUG | grep -Eo "([^/]+)\$") # Detect the project name

if [[ -z "$OLD_COMMIT" ]]; then
    echo "[ERROR] Did not pass in old commit to run!"
    exit 1
fi

if [[ -z "$NEW_COMMIT" ]]; then
    echo "[ERROR] Did not pass in new commit to run!"
    exit 1
fi

# Set up the environment variables for prior commits and such
export DT_SUBJ_ROOT=$HOME/${PROJ_SLUG}-old-${OLD_COMMIT}
export DT_SUBJ=$DT_SUBJ_ROOT/$MODULE_PATH/target
export DT_SUBJ_SRC=$DT_SUBJ_ROOT/$MODULE_PATH
module=$(basename $MODULE_PATH) # The module name expected is just the last part of the path
if [[ "$module" = "." ]]; then
    export SUBJ_NAME=${PROJ_SLUG//\//.}
    export SUBJ_NAME_FORMAL=${SUBJ_NAME}
else
    export SUBJ_NAME=${PROJ_SLUG//\//.}-${module}
    export SUBJ_NAME_FORMAL=${PROJ_SLUG//\//.}-${module}
fi

. ../setup-vars.sh

echo "[INFO] bash precomputed-lifetime.sh $PROJ_SLUG $NEW_COMMIT $MODULE_PATH \"$TECHNIQUES\" \"$TESTTYPES\""
bash precomputed-lifetime.sh $PROJ_SLUG $NEW_COMMIT $MODULE_PATH "$TECHNIQUES" "$TESTTYPES" | tee "${PROJ_NAME}-$NEW_COMMIT.txt"
