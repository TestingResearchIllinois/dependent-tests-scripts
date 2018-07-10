# Inputs:
# $1 - Git repo url
# $2 - Starting commit.
# $3 - path in repo (probably for module)
# $4 - Setup script

COMMIT_NUM=10

GIT_URL=$1
START=$2
MODULE_PATH=$3
SETUP_SCRIPT=$4

if [[ -e "$SETUP_SCRIPT" ]]; then
    # Generally the setup scripts are written so that they assume you are in a particular directory, so
    # make sure we match that.
    CURRENT=$(pwd)

    SCRIPT_DIR=$(dirname "$SETUP_SCRIPT")
    SCRIPT_NAME=$(basename "$SETUP_SCRIPT")

    echo "[INFO] Running setup script $SCRIPT_NAME in $SCRIPT_DIR"

    cd $SCRIPT_DIR
    source "$SCRIPT_NAME"

    cd $CURRENT
else
    echo "No setup script found with name $SETUP_SCRIPT!"
    exit 1
fi

NEW_COMMIT_FILE="new-commit-list.txt"
# OLD_COMMIT_FILE="old-commit-list.txt"

PROJ_NAME=$(echo $GIT_URL | grep -Eo "([^/]+)\$") # Detect the project name

if [[ ! -e "$NEW_COMMIT_FILE" ]]; then
    echo "[INFO] Downloading repository to select commits."
    git clone $GIT_URL "temp-$PROJ_NAME"
    bash sample-commits.sh "temp-$PROJ_NAME" "$START" "$COMMIT_NUM" "$MODULE_PATH" uniform $SUBJ_CUTOFF
    echo "[INFO] Wrote commits to $NEW_COMMIT_FILE" # and $OLD_COMMIT_FILE."
else
    echo "[INFO] Skipping commit selections, $NEW_COMMIT_FILE" # and $OLD_COMMIT_FILE already exist."
fi

new_commits=($(cat "$NEW_COMMIT_FILE"))
# old_commits=($(cat "$OLD_COMMIT_FILE"))

echo "[INFO] Selected commits:"
for (( i=0; i<${#new_commits[@]}; i++ ))
do
    echo "[INFO] New commit is: ${new_commits[$i]}" #, old commit is ${old_commits[$i]}"
done

for (( i=0; i<${#new_commits[@]}; i++ ))
do
    # echo "[INFO] bash precomputed-lifetime.sh $GIT_URL ${new_commits[$i]} ${old_commits[$i]} $MODULE_PATH $SUBJ_NAME $SUBJ_NAME_FORMAL \"$ORIGINAL_DT_SUBJ\""
    # bash precomputed-lifetime.sh $GIT_URL ${new_commits[$i]} ${old_commits[$i]} $MODULE_PATH $SUBJ_NAME $SUBJ_NAME_FORMAL "$ORIGINAL_DT_SUBJ" | tee "${PROJ_NAME}-${new_commits[$i]}-${old_commits[$i]}.txt"
    echo "[INFO] bash precomputed-lifetime.sh $GIT_URL ${new_commits[$i]} $MODULE_PATH"
    bash precomputed-lifetime.sh $GIT_URL ${new_commits[$i]} $MODULE_PATH | tee "${PROJ_NAME}-${new_commits[$i]}.txt"
done

