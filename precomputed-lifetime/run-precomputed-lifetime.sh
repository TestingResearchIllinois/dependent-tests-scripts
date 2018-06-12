# Inputs:
# $1 - Git repo url
# $2 - Starting date or commit.
# $3 - path in repo (probably for module)
# $4 - Subj name
# $5 - Subj name formal

COMMIT_NUM=10

GIT_URL=$1
START=$2
MODULE_PATH=$3
export SUBJ_NAME=$4
export SUBJ_NAME_FORMAL=$5

PROJ_NAME=$(echo $GIT_URL | grep -Eo "([^/]+)\$") # Detect the project name

echo "[INFO] Downloading repository to select commits."
git clone $GIT_URL temp-$PROJ_NAME

echo "[INFO] Selecting $COMMIT_NUM commits."
cd temp-$PROJ_NAME
git pull # In case we are out of date, make sure we update to have the latest for the commit selection.

# Need to check if it is a date or a commit.
if date -d "$START" > /dev/null; then
    commits=$(git log -s --format="%H" --reverse --since="$START" "$MODULE_PATH")
else
    commits=$(git log -s --format="%H" --reverse ${START}..HEAD "$MODULE_PATH")
fi

cd ..
new_commits=($(for i in $commits; do echo $i; done | python choose.py $COMMIT_NUM 1)) # Drop 1, so start at the second commit.
old_commits=($(for i in $commits; do echo $i; done | python choose.py $COMMIT_NUM))

echo "[INFO] Selected commits:"
for (( i=0; i<${#new_commits[@]}; i++ ))
do
    echo "[INFO] New commit is: ${new_commits[$i]}, old commit is ${old_commits[$i]}"
done

for (( i=0; i<${#new_commits[@]}; i++ ))
do
    echo "[INFO] bash precomputed-lifetime.sh $GIT_URL ${new_commits[$i]} ${old_commits[$i]} $MODULE_PATH $SUBJ_NAME $SUBJ_NAME_FORMAL"
    bash precomputed-lifetime.sh $GIT_URL ${new_commits[$i]} ${old_commits[$i]} $MODULE_PATH $SUBJ_NAME $SUBJ_NAME_FORMAL | tee "${PROJ_NAME}-${new_commits[$i]}-${old_commits[$i]}.txt"
done

