#!/usr/bin/env bash

# Usage: source set-directory.sh $DT_SUBJ $NEW_DT_SUBJ $CLASSPATH
# Determines if the subj uses maven or ant, and if we are running the new or old version by using the classpath
# Then sets the directory to the proper location dependening on this information.

DT_SUBJ=$1
NEW_DT_SUBJ=$2
CLASSPATH=$3

DIR=$NEW_DT_SUBJ
if [[ "$CLASSPATH" =~ "$DT_SUBJ" ]]; then # old version
    DIR=$DT_SUBJ
fi

cd $DIR

if [[ -e "pom.xml" ]]; then
    echo "[INFO] This project is using Maven (found pom.xml)"
    cd ..
fi

if [[ "$(basename $(pwd))" == "target" ]] && [[ -e "../pom.xml" ]]; then
    echo "[INFO] This project is using Maven (found ../pom.xml and we are in target/)"
    cd ..
fi

echo "[INFO] PWD is now $(pwd)"

