# Inputs:
# $1 - project slug
# $2 - path in repo (probably for module)
# $3 - path to file with commits for the project/module
# $4 - techniques to use (e.g., prio-sele-para or prio-para or sele-prio). Optional. If not provided, then will use all by default
# $5 - test types

if [[ "$1" == "--help" ]]; then
    echo "Usage: ./run-precomputed-lifetime.sh project-slug relative-module-path commit-list [techniques] [testtypes]"
    exit 1
fi

if [[ "$#" -lt 1 ]]; then
    echo "Usage: ./run-precomputed-lifetime.sh project-slug relative-module-path commit-list [testtypes] [techniques]"
    exit 1
fi

PROJ_SLUG=$1
MODULE_PATH=$2
NEW_COMMIT_FILE="$3"
TESTTYPES="$4"
TECHNIQUES="$5"
# OLD_COMMIT_FILE="old-commit-list.txt"

PROJ_NAME=$(echo $PROJ_SLUG | grep -Eo "([^/]+)\$") # Detect the project name

if [[ ! -e "$NEW_COMMIT_FILE" ]]; then
    echo "[ERROR] Commit list does not exist at $NEW_COMMIT_FILE!"
    exit 1
fi

new_commits=($(tac "$NEW_COMMIT_FILE"))
# old_commits=($(cat "$OLD_COMMIT_FILE"))

echo "[INFO] Selected commits:"
for (( i=0; i<${#new_commits[@]}; i++ ))
do
    echo "[INFO] New commit is: ${new_commits[$i]}" #, old commit is ${old_commits[$i]}"
done

# Set up the environment variables for prior commits and such
OLD_COMMIT=${new_commits[0]}
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

for (( i=1; i<${#new_commits[@]}; i++ ))
do
    echo "[INFO] bash precomputed-lifetime.sh $PROJ_SLUG ${new_commits[$i]} $MODULE_PATH \"$TECHNIQUES\" \"$TESTTYPES\""
    bash precomputed-lifetime.sh $PROJ_SLUG ${new_commits[$i]} $MODULE_PATH "$TECHNIQUES" "$TESTTYPES" | tee "${PROJ_NAME}-${new_commits[$i]}.txt"

    # Shift environment variables for next run
    #OLD_COMMIT=${new_commits[$i]}
    #export DT_SUBJ_ROOT=$HOME/${PROJ_SLUG}-new-${OLD_COMMIT}
    #export DT_SUBJ=$DT_SUBJ_ROOT/$MODULE_PATH/target
    #export DT_SUBJ_SRC=$DT_SUBJ_ROOT/$MODULE_PATH
done

