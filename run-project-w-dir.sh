#!/bin/bash

if [[ "$1" == "--help" ]]; then
    echo "Usage: ./run_project.sh project-dir [new commit] [old commit] [autoremove directory if exists (Y/N)]"
    exit 1
fi

if [[ "$#" -lt 1 ]]; then
    echo "Usage: ./run_project.sh project-dir [new commit] [old commit] [autoremove directory if exists (Y/N)]"
    exit 1
fi

for arg
do
    shift
    # Ignore this argument.
    if [[ "$arg" = "--parallel" ]]; then
        PARALLEL="Y"
        continue
    fi
    set -- "$@" "$arg"
done

NEW_VERSION="HEAD"

if [[ ! -z "$2" ]]; then
    NEW_VERSION=$2
fi

if [[ ! -z "$3" ]]; then
    OLD_VERSION=$3
else
    OLD_VERSION="$NEW_VERSION~100"
fi

AUTOREMOVE="N"
if [[ ! -z "$4" ]]; then
    AUTOREMOVE=$4
fi

MODULE_FILTER=".*"
if [[ ! -z "$5" ]]; then
    MODULE_FILTER="$5"
fi

SKIP_COMPILE="N"
if [[ ! -z "$6" ]]; then
    SKIP_COMPILE="$6"
fi

. ./setup-vars.sh # Set up the basic environment variables (e.g. $DT_ROOT)

BASE_SUBJ_NAME="${1//\//.}"
PATH_NAME="$1"

# Download the project
cd $DT_ROOT

echo
echo "[INFO] Running for project: ${PATH_NAME}"

# echo
# echo "[INFO] Cloning project..."
# git clone "$1" "${PROJ_NAME}-temp"

cd "$1"

NEW_COMMIT=`git rev-parse "$NEW_VERSION"`
OLD_COMMIT=`git rev-parse "$OLD_VERSION"`
export DT_SUBJ_ROOT="$DT_ROOT/${PATH_NAME}-old-$OLD_COMMIT"
export NEW_DT_SUBJ_ROOT="$DT_ROOT/${PATH_NAME}-new-$NEW_COMMIT"
echo "[INFO] Cloning projects into $NEW_DT_SUBJ_ROOT and $DT_SUBJ_ROOT"
cd $DT_ROOT

if [[ -d "$NEW_DT_SUBJ_ROOT" ]]; then
    if [[ "$AUTOREMOVE" == "Y" ]]; then
        echo "[INFO] Autoremoving $NEW_DT_SUBJ_ROOT because it already exists"
        rm -rf "$NEW_DT_SUBJ_ROOT"
    fi
fi

if [[ -d "$DT_SUBJ_ROOT" ]]; then
    if [[ "$AUTOREMOVE" == "Y" ]]; then
        echo "[INFO] Autoremoving $DT_SUBJ_ROOT because it already exists"
        rm -rf "$DT_SUBJ_ROOT"
    fi
fi

# git clone "$1" "$NEW_DT_SUBJ_ROOT"
if ! [[ -d $NEW_DT_SUBJ_ROOT ]]; then
    cp -r "/home/awshi2/$1" "$NEW_DT_SUBJ_ROOT"
fi
# git clone "$1" "$DT_SUBJ_ROOT"
if ! [[ -d $DT_SUBJ_ROO ]]; then
    cp -r "/home/awshi2/$1" "$DT_SUBJ_ROOT"
fi

echo
echo "[INFO] Resetting old version to $OLD_VERSION."
cd $DT_SUBJ_ROOT
git reset --hard "$OLD_VERSION"

echo
echo "[INFO] Resetting new version to $NEW_VERSION."
cd $NEW_DT_SUBJ_ROOT
git reset --hard "$NEW_VERSION"

IFS=$'\n'

# Detect the maven modules inside the old and new projects.
echo
echo "[INFO] Detecting modules in old version."
OLD_SUBJ_MODULES=()
OLD_SUBJ_MODULE_DIRS=()
cd $DT_SUBJ_ROOT
for line in $(find -name "pom.xml")
do
    OLD_SUBJ_MODULES+=($(basename $(dirname $line)))
    OLD_SUBJ_MODULE_DIRS+=($(readlink -f $(dirname $line)))
done

OLD_MODULE_COUNT=${#OLD_SUBJ_MODULES[@]}
echo "[INFO] Found:"
for (( i=0; i<${OLD_MODULE_COUNT}; i++ ));
do
    echo "[INFO] ${OLD_SUBJ_MODULES[$i]}: ${OLD_SUBJ_MODULE_DIRS[$i]}"
done

echo
echo "[INFO] Detecting modules in new version."
NEW_SUBJ_MODULES=()
NEW_SUBJ_MODULE_DIRS=()
cd $NEW_DT_SUBJ_ROOT
for line in $(find -name "pom.xml")
do
    NEW_SUBJ_MODULES+=($(basename $(dirname $line)))
    NEW_SUBJ_MODULE_DIRS+=($(readlink -f $(dirname $line)))
done
NEW_MODULE_COUNT=${#NEW_SUBJ_MODULES[@]}

echo "[INFO] Found:"
for (( i=0; i<${NEW_MODULE_COUNT}; i++ ));
do
    echo "[INFO] ${NEW_SUBJ_MODULES[$i]}: ${NEW_SUBJ_MODULE_DIRS[$i]}"
done

for (( i=0; i<${OLD_MODULE_COUNT}; i++ ));
do
    module="${OLD_SUBJ_MODULES[$i]}"
    if ! grep -Fqx "${BASE_SUBJ_NAME}-$module" "$DT_SCRIPTS/modules-torun.txt"; then
        echo "[INFO] Not supposed to run ${BASE_SUBJ_NAME}-$module, skipping."
        continue
    fi

    for (( j=0; j<${NEW_MODULE_COUNT}; j++ ));
    do
        new_module="${NEW_SUBJ_MODULES[$j]}"

        if [[ "${new_module}" == "${module}" ]]; then
            if [[ "${new_module}" =~ $MODULE_FILTER ]]; then
                echo
                echo "[INFO] ${module} is in both the old and new versions, running tools."

                # Make sure we exit if any one of these steps fails.
                (
                    set -e

                    echo "[INFO] Setting environment variables."
                    export DT_SUBJ=${OLD_SUBJ_MODULE_DIRS[$i]}/target
                    export DT_SUBJ_SRC=${OLD_SUBJ_MODULE_DIRS[$i]}

                    export NEW_DT_SUBJ=${NEW_SUBJ_MODULE_DIRS[$j]}/target
                    export NEW_DT_SUBJ_SRC=${NEW_SUBJ_MODULE_DIRS[$j]}

                    if [[ "$module" = "." ]]; then
                        export SUBJ_NAME="${BASE_SUBJ_NAME}"
                        export SUBJ_NAME_FORMAL="${SUBJ_NAME}"
                    else
                        export SUBJ_NAME="${BASE_SUBJ_NAME}-$module"
                        export SUBJ_NAME_FORMAL="${SUBJ_NAME}"
                    fi

                    . $DT_SCRIPTS/setup-vars.sh

                    echo "[INFO] Checking for test files."

                    cd $DT_SUBJ_SRC
                    export DT_TEST_SRC=$(/home/awshi2/apache-maven/bin/mvn -B help:evaluate -Dexpression=project.build.testSourceDirectory | grep -vE "\[")
                    echo "[INFO] Test source directory for ${SUBJ_NAME} (old) is $DT_TEST_SRC"
                    if [[ ! -d "$DT_TEST_SRC" ]]; then
                        echo "[INFO] $module in the old subject has no test files, skipping."
                        break
                    fi

                    cd $NEW_DT_SUBJ_SRC
                    export NEW_DT_TEST_SRC=$(/home/awshi2/apache-maven/bin/mvn -B help:evaluate -Dexpression=project.build.testSourceDirectory | grep -vE "\[")
                    echo "[INFO] Test source directory for ${SUBJ_NAME} (new) is $NEW_DT_TEST_SRC"
                    if [[ ! -d "$NEW_DT_TEST_SRC" ]]; then
                        echo "[INFO] $module in the new subject has no test files, skipping."
                        break
                    fi

                    cd $DT_SCRIPTS

                    # Keep track that we tried this one:
                    echo "${SUBJ_NAME}-$module" >> "$DT_SCRIPTS/modules-tried.txt"

                    # Save the results if we already did it.
                    if [[ -d "$DT_SCRIPTS/${SUBJ_NAME}-results" ]]; then
                        echo "Moving from $DT_SCRIPTS/${SUBJ_NAME}-results to $DT_SCRIPTS/${SUBJ_NAME}-old-results"
                        mv "$DT_SCRIPTS/${SUBJ_NAME}-results" "$DT_SCRIPTS/${SUBJ_NAME}-old-results"
                    fi

                    # Make sure compile-output exists
                    mkdir -p "$DT_SCRIPTS/compile-output"

                    mkdir -p "$DT_SCRIPTS/${SUBJ_NAME}-results"
                    cd $DT_SCRIPTS

                    # Generate a setup script.
                    SETUP_SCRIPT="$DT_SCRIPTS/${SUBJ_NAME}-results/setup-$SUBJ_NAME.sh"
                    bash "$DT_SCRIPTS/write-setup-script.sh" "$SETUP_SCRIPT"

                    echo
                    echo "[INFO] Calling main script: $DT_SCRIPTS/run-module.sh"

                    if [[ "$PARALLEL" = "Y" ]]; then
                        nohup bash run-module.sh $SETUP_SCRIPT &> "$DT_SCRIPTS/${SUBJ_NAME}-results/module-output.txt" &
                    else
                        bash run-module.sh $SETUP_SCRIPT &> "$DT_SCRIPTS/${SUBJ_NAME}-results/module-output.txt"
                    fi
                )

                break
            else
                echo "Skipping because ${new_module} does not match filter $MODULE_FILTER"
            fi
        fi
    done
done

echo "[INFO] Finished $SUBJ_NAME"

