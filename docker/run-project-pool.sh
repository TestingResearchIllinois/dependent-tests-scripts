#!/bin/bash

if [[ $1 == "" ]] || [[ $2 == "" ]] || [[ $3 == "" ]]; then
    echo "arg1 - Path to CSV file with project,sha"
    echo "arg2 - Number of rounds"
    echo "arg3 - Timeout in seconds"
    echo "arg4 - The script to run (Optional)"
    echo "arg5 - Test type (Optional)"
    echo "arg6 - Technique (Optional)"
    exit
fi

mkdir -p "logs"
fname="logs/$(basename $1 .csv)-log.txt"

echo "Logging to $fname"
bash create_and_run_dockers.sh $@ &> $fname
echo "Finished running $fname"

