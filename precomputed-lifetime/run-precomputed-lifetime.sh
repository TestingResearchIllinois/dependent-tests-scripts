# Inputs:
# $1 - Git repo url
# $2 - Starting commit.
# $3 - path in repo (probably for module)
# $4 - Subj name
# $5 - Subj name formal
# $6 - Original version's DT_SUBJ

COMMIT_NUM=10

GIT_URL=$1
START=$2
MODULE_PATH=$3
export SUBJ_NAME=$4
export SUBJ_NAME_FORMAL=$5
ORIGINAL_DT_SUBJ=$(cd "$6"; pwd)

NEW_COMMIT_FILE="new-commit-list.txt"
OLD_COMMIT_FILE="old-commit-list.txt"

PROJ_NAME=$(echo $GIT_URL | grep -Eo "([^/]+)\$") # Detect the project name

if [[ ! -e "$NEW_COMMIT_FILE" ]] || [[ ! -e "$OLD_COMMIT_FILE" ]]; then
    echo "[INFO] Downloading repository to select commits."
    git clone $GIT_URL "temp-$PROJ_NAME"
    bash sample-commits.sh "temp-$PROJ_NAME" "$START" "$COMMIT_NUM" "$MODULE_PATH" uniform 58
    echo "[INFO] Wrote commits to $NEW_COMMIT_FILE and $OLD_COMMIT_FILE."
else
    echo "[INFO] Skipping commit selections, $NEW_COMMIT_FILE and $OLD_COMMIT_FILE already exist."
fi

new_commits=($(cat "$NEW_COMMIT_FILE"))
old_commits=($(cat "$OLD_COMMIT_FILE"))

echo "[INFO] Selected commits:"
for (( i=0; i<${#new_commits[@]}; i++ ))
do
    echo "[INFO] New commit is: ${new_commits[$i]}, old commit is ${old_commits[$i]}"
done

for (( i=0; i<${#new_commits[@]}; i++ ))
do
    echo "[INFO] bash precomputed-lifetime.sh $GIT_URL ${new_commits[$i]} ${old_commits[$i]} $MODULE_PATH $SUBJ_NAME $SUBJ_NAME_FORMAL \"$ORIGINAL_DT_SUBJ\""
    bash precomputed-lifetime.sh $GIT_URL ${new_commits[$i]} ${old_commits[$i]} $MODULE_PATH $SUBJ_NAME $SUBJ_NAME_FORMAL "$ORIGINAL_DT_SUBJ" | tee "${PROJ_NAME}-${new_commits[$i]}-${old_commits[$i]}.txt"
done

