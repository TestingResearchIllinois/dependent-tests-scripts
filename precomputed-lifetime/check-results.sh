#!/usr/bin/env bash

# Usage: bash check-results.sh
# Will look for all directories in the current directory containing all three of
# $prioDir, $seleDir, $paraDir (see constants.sh), then check if any of the result files
# in them contain dependent tests.

. ./constants.sh

for dir in $(find -type d -maxdepth 1)
do
    if [[ -d "$dir/$prioDir" ]] && [[ -d "$dir/$seleDir" ]] && [[ -d "$dir/$paraDir" ]]; then
        if grep -ERq "DTs not fixed: [1-9]" $dir; then
            echo "Dependent tests were found in $dir"
        else
            echo "No dependent tests found in $dir"
        fi
    fi
done

