#!/bin/bash

RESULTS=$1
if [[ ${RESULTS} == "" ]]; then
    echo "arg1 - Path to results directory"
    exit
fi

for proj in $(cat projects.txt); do
    # Skip those that start with #
    if [[ ${proj} =~ "#" ]]; then
        continue
    fi
    #echo ${proj}
    (
        cd ${RESULTS}/${proj}/${proj}-results/precomputed/

        # Find all the files that result in finding DTs (TODO: ORIG for now)
        # First look through prioritization
        for f in $(find -name "PRIORITIZATION*-ORIG-*false.txt" | xargs grep -l "Number of DTs fixed: [^0]"); do
            # Get the total amount of time to get dependencies
            onedeptime=$(grep "Average time to find one dependency: " ${f} | cut -d':' -f2 | cut -d' ' -f2)
            numdeps=$(grep "Number of DTs fixed: " ${f} | cut -d':' -f2 | cut -d' ' -f2)
            totaldepstime=$(echo "${onedeptime} * ${numdeps}" | bc -l)

            # Get the total time to run tests by parsing and adding up each individual time
            testtime=$(grep -A2 "Time each test takes to run in the new order:" ${f} | grep "\[" | sed 's;\[;;' | sed 's;\];;' | sed 's;, ;+;g' | bc -l)

            # Compute the amount of time dependency collection is greater than just test time
            echo "${totaldepstime} / $(echo ${testtime} / 1000 | bc -l)" | bc -l
        done

        # Next look through parallelization
        for f in $(find -name "PARALLELIZATION*-ORIG-*false.txt" | xargs grep -l "Number of DTs fixed: [^0]" | head -1); do
            # Get the total amount of time to get dependencies
            onedeptime=$(grep "Average time to find one dependency: " ${f} | cut -d':' -f2 | cut -d' ' -f2 | paste -sd+ | bc -l)

            numdeps=$(grep "Number of DTs fixed: " ${f} | cut -d':' -f2 | cut -d' ' -f2 | paste -sd+ | bc -l)
            totaldepstime=$(echo "${onedeptime} * ${numdeps}" | bc -l)

            # Get the total time to run tests by parsing and adding up each individual time
            testtime=$(grep -A2 "Time each test takes to run in the new order:" ${f} | grep "\[" | sed 's;\[;;' | sed 's;\];;' | sed 's;, ;+;g' | paste -sd+ | bc -l)

            # Compute the amount of time dependency collection is greater than just test time
            echo "${totaldepstime} / $(echo ${testtime} / 1000 | bc -l)" | bc -l
        done
    )
done
