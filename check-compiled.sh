#!/usr/bin/env bash

# Usage: bash check-compiled.sh $CLASSPATH
# Checks for existance of every item listed in the classpath (separated by ':')
# If any are missing, then will exit with an exit code of 1


checkExists() {
    path=$1
    if ! ls $path > /dev/null; then
        echo "[ERROR] $path does not exist. The subject probably needs to be compiled."
        exit 1
    fi
}

# Split on :
for path in ${1//:/ }
do
    checkExists $path
done

