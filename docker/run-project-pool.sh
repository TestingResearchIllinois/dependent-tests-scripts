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


if [[ -z "$5" ]] || [[ -z "$6" ]]; then
    line=$(cat $1)
    testtype=$(echo ${line} | cut -d',' -f5)
    technique=$(echo ${line} | cut -d',' -f6)
else
    testtype=$5
    technique=$6
fi

mkdir -p "logs"
fname="logs/$(basename $1 .csv)-log.txt"

echo "Logging to $fname"
echo "Running: bash create_and_run_dockers.sh $1 $2 $3 $4 $testtype $technique"
bash create_and_run_dockers.sh "$1" "$2" "$3" "$4" "$testtype" "$technique" &> $fname
echo "Finished running $fname"

