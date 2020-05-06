#!/usr/bin/env bash

if [[ $1 == "" ]] || [[ $2 == "" ]]; then
    echo "arg1 - Path to directory with CSV files that contain project,sha, to be parallel run"
    echo "arg2 - Timeout in seconds"
    echo "arg3 - The script to run (Optional)"
    echo "arg4 - Number of processes to run at the same time (Optional)"
    echo "arg5 - Test type (Optional)"
    echo "arg6 - Technique (Optional)"
    exit
fi

PROCESS_NUM="$4"

if [[ -z "$PROCESS_NUM" ]]; then
    PROCESS_NUM="4"
fi

find "$1" -maxdepth 1 -type f -name "*.csv" | xargs -P"$PROCESS_NUM" -I{} bash run-project-pool.sh {} "$2" "$3" "$5" "$6"

