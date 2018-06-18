#!/usr/bin/env bash

# Usage: bash check-results.sh
# Will look for all directories in the current directory containing all three of
# $prioDir, $seleDir, $paraDir (see constants.sh), then check if any of the result files
# in them contain dependent tests.

. ./constants.sh

for dir in $(find -maxdepth 1 -type d)
do
    if [[ -d "$dir/$prioDir" ]] && [[ -d "$dir/$seleDir" ]] && [[ -d "$dir/$paraDir" ]]; then
        matches=$(grep -lER "DTs not fixed: [1-9]" $dir)
        if [[ ! -z "$matches" ]]; then
            echo "Dependent tests found in $matches"
        else
            echo "No dependent tests found in $dir"
        fi
    fi
done

