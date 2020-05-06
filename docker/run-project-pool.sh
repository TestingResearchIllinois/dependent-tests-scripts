#!/bin/bash

if [[ $1 == "" ]] || [[ $2 == "" ]]; then
    echo "arg1 - Path to CSV file with project,sha"
    echo "arg2 - Timeout in seconds"
    echo "arg3 - The script to run (Optional)"
    echo "arg4 - Test type (Optional)"
    echo "arg5 - Technique (Optional)"
    exit
fi

# If the script is not provided, the default is run_project.sh, which may not need arg4 and arg5
if [[ -z "$3" ]]; then
    testtype=$4
    technique=$5
# If script is provided, could be wanting to run run_project_lifetime.sh, which can parse arguments from csv file
elif [[ -z "$4" ]] || [[ -z "$5" ]]; then
    line=$(cat $1)
    testtype=$(echo ${line} | cut -d',' -f6)
    technique=$(echo ${line} | cut -d',' -f7)
else
    testtype=$4
    technique=$5
fi

mkdir -p "logs"
fname="logs/$(basename $1 .csv)-log.txt"

echo "Logging to $fname"
echo "Running: bash create_and_run_dockers.sh $1 $2 $3 $testtype $technique"
bash create_and_run_dockers.sh "$1" "$2" "$3" "$testtype" "$technique" &> $fname
echo "Finished running $fname"

