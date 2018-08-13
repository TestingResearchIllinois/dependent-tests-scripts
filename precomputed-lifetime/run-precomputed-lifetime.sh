# Inputs:
# $1 - Git repo url
# $2 - path in repo (probably for module)
# $3 - Setup script
# $4 - techniques to use (e.g., prio-sele-para or prio-para or sele-prio). Optional. If not provided, then will use all by default

COMMIT_NUM=10

GIT_URL=$1
MODULE_PATH=$2
SETUP_SCRIPT=$3
TECHNIQUES="$4"

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
    echo "[ERROR] Commit list does not exist at $NEW_COMMIT_FILE!"
    exit 1
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
    echo "[INFO] bash precomputed-lifetime.sh $GIT_URL ${new_commits[$i]} $MODULE_PATH \"$TECHNIQUES\""
    bash precomputed-lifetime.sh $GIT_URL ${new_commits[$i]} $MODULE_PATH "$TECHNIQUES" | tee "${PROJ_NAME}-${new_commits[$i]}.txt"
done

