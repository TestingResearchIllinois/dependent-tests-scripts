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
ORIGINAL_DT_SUBJ=$6

NEW_COMMIT_FILE="new-commit-list.txt"
OLD_COMMIT_FILE="old-commit-list.txt"

PROJ_NAME=$(echo $GIT_URL | grep -Eo "([^/]+)\$") # Detect the project name

echo "[INFO] Downloading repository to select commits."
git clone $GIT_URL temp-$PROJ_NAME

if [[ -z "$NEW_COMMIT_FILE" ]]; then
    echo "[INFO] Selecting $COMMIT_NUM commits."
    cd temp-$PROJ_NAME
    git pull # In case we are out of date, make sure we update to have the latest for the commit selection.

    bash sample-commits.sh "$(pwd)" "$START" "$COMMIT_NUM" uniform
fi

echo "[INFO] Using commits from $NEW_COMMIT_FILE and $OLD_COMMIT_FILE."

new_commits=($(cat "$NEW_COMMIT_FILE"))
old_commits=($(cat "$OLD_COMMIT_FILE"))

echo "[INFO] Selected commits:"
for (( i=0; i<${#new_commits[@]}; i++ ))
do
    echo "[INFO] New commit is: ${new_commits[$i]}, old commit is ${old_commits[$i]}"
done

for (( i=0; i<${#new_commits[@]}; i++ ))
do
    echo "[INFO] bash precomputed-lifetime.sh $GIT_URL ${new_commits[$i]} ${old_commits[$i]} $MODULE_PATH $SUBJ_NAME $SUBJ_NAME_FORMAL"
    bash precomputed-lifetime.sh $GIT_URL ${new_commits[$i]} ${old_commits[$i]} $MODULE_PATH $SUBJ_NAME $SUBJ_NAME_FORMAL | tee "${PROJ_NAME}-${new_commits[$i]}-${old_commits[$i]}.txt" "$ORIGINAL_DT_SUBJ"
done

