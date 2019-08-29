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
        projdir=$(echo ${proj} | sed 's;=;-;')
        cd ${RESULTS}/${projdir}/${projdir}-results/precomputed/

        for testtype in ORIG AUTO; do
            # Some rolling sum to compute for selection (which is combination of prioritization and parallelization)
            rollingseledepstime=0
            rollingseledepscount=0

            rollingdepstime=0
            rollingdepscount=0
            for cov in FUNCTION STATEMENT; do
                for type in ABSOLUTE RELATIVE; do
                    totaldepstime=0
                    # Find all the files that result in finding DTs
                    # First look through prioritization
                    for f in $(find -name "PRIORITIZATION-${testtype}-*${cov}-${type}*false.txt" | xargs grep -l "Number of DTs fixed: [^0]"); do
                        # Get the total amount of time to get dependencies
                        onedeptime=$(grep "Average time to find one dependency: " ${f} | cut -d':' -f2 | cut -d' ' -f2)
                        numdeps=$(grep "Number of DTs fixed: " ${f} | cut -d':' -f2 | cut -d' ' -f2)
                        totaldepstime=$(echo "${onedeptime} * ${numdeps}" | bc -l | cut -d'.' -f1)

                        # Get the total time to run tests by parsing and adding up each individual time
                        testtime=$(grep -A2 "Time each test takes to run in the new order:" ${f} | grep "\[" | sed 's;\[;;' | sed 's;\];;' | sed 's;, ;+;g' | bc -l)

                        # Compute the amount of time dependency collection is greater than just test time
                        #echo "${totaldepstime} / $(echo ${testtime} / 1000 | bc -l)" | bc -l
                    done
                    echo "\\Def{${proj}_$(echo ${testtype} | tr '[:upper:]' '[:lower:]')_deptime_prio_$(echo ${cov} | cut -c1-4 | tr '[:upper:]' '[:lower:]')_$(echo ${type} | cut -c1-4 | tr '[:upper:]' '[:lower:]')}{${totaldepstime}}"
                    if [[ ${totaldepstime} != 0 ]]; then
                        rollingdepstime=$((rollingdepstime + totaldepstime))
                        rollingdepscount=$((rollingdepscount + 1))
                    fi
                done
            done
            if [[ ${rollingdepscount} != 0 ]]; then
                echo "\\Def{${proj}_$(echo ${testtype} | tr '[:upper:]' '[:lower:]')_deptime_prio_avg}{$(echo ${rollingdepstime} / ${rollingdepscount} | bc -l | xargs printf '%0.1f')}"
                rollingseledepstime=$((rollingseledepstime + rollingdepstime))
                rollingseledepscount=$((rollingseledepscount + rollingdepscount))
            else
                echo "\\Def{${proj}_$(echo ${testtype} | tr '[:upper:]' '[:lower:]')_deptime_prio_avg}{-}"
            fi

            rollingdepstime=0
            rollingdepscount=0
            for type in ORIGINAL TIME; do
                for machine in TWO FOUR EIGHT SIXTEEN; do
                    # Next look through parallelization
                    totaldepstime=0
                    for f in $(find -name "PARALLELIZATION-${testtype}-*${type}-*${machine}*false.txt" | xargs grep -l "Number of DTs fixed: [^0]" | head -1); do
                        # Get the total amount of time to get dependencies
                        onedeptime=$(grep "Average time to find one dependency: " ${f} | cut -d':' -f2 | cut -d' ' -f2 | paste -sd+ | bc -l)

                        numdeps=$(grep "Number of DTs fixed: " ${f} | cut -d':' -f2 | cut -d' ' -f2 | paste -sd+ | bc -l)
                        totaldepstime=$(echo "${onedeptime} * ${numdeps}" | bc -l | cut -d'.' -f1)

                        # Get the total time to run tests by parsing and adding up each individual time
                        testtime=$(grep -A2 "Time each test takes to run in the new order:" ${f} | grep "\[" | sed 's;\[;;' | sed 's;\];;' | sed 's;, ;+;g' | paste -sd+ | bc -l)

                        # Compute the amount of time dependency collection is greater than just test time
                        #echo "${totaldepstime} / $(echo ${testtime} / 1000 | bc -l)" | bc -l
                    done
                    echo "\\Def{${proj}_$(echo ${testtype} | tr '[:upper:]' '[:lower:]')_deptime_para_$(echo ${type} | cut -c1-4 | tr '[:upper:]' '[:lower:]')_$(echo ${machine} | cut -c1-4 | tr '[:upper:]' '[:lower:]')}{${totaldepstime}}"
                    if [[ ${totaldepstime} != 0 ]]; then
                        rollingdepstime=$((rollingdepstime + totaldepstime))
                        rollingdepscount=$((rollingdepscount + 1))
                    fi
                done
            done
            if [[ ${rollingdepscount} != 0 ]]; then
                echo "\\Def{${proj}_$(echo ${testtype} | tr '[:upper:]' '[:lower:]')_deptime_para_avg}{$(echo ${rollingdepstime} / ${rollingdepscount} | bc -l | xargs printf '%0.1f')}"
                rollingseledepstime=$((rollingseledepstime + rollingdepstime))
                rollingseledepscount=$((rollingseledepscount + rollingdepscount))
            else
                echo "\\Def{${proj}_$(echo ${testtype} | tr '[:upper:]' '[:lower:]')_deptime_para_avg}{-}"
            fi

            # Write out the average for selection purposes
            if [[ ${rollingseledepscount} != 0 ]]; then
                echo "\\Def{${proj}_$(echo ${testtype} | tr '[:upper:]' '[:lower:]')_deptime_sele_avg}{$(echo ${rollingseledepstime})}"
            else
                echo "\\Def{${proj}_$(echo ${testtype} | tr '[:upper:]' '[:lower:]')_deptime_sele_avg}{-}"
            fi
        done
    )
done
