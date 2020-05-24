#!/bin/bash

RESULTS=$1
if [[ ${RESULTS} == "" ]]; then
    echo "arg1 - Path to results directory that contains origresults/, autoresults/, dtdresults/, origorders/"
    exit
fi

# Function for parsing a para file, to compute total time for computing deps across all deps in different machines
function parse_para() {
    parafile=$1

    totaldepstime=0
    totalnumdeps=0

    # Iterate through all the average times and match up with the dependent tests
    i=0
    for avg in $(grep "Average time to find one dependency: " ${parafile} | cut -d':' -f2 | cut -d' ' -f2); do
        j=0
        for dts in $(grep -A1 "Dependent test list:" ${parafile} | grep -v "Dependent test list:"); do
            # Match up the average time line with the dependent test list based on iteration position
            if [[ ${i} == ${j} ]]; then
                numdeps=$(echo ${dts} | sed 's;\[;;' | sed 's;\];;' | sed 's;, ;\n;g' | cut -d'>' -f2 | sort -u | wc -l)
                depstime=$(echo "${avg} * ${numdeps}" | bc -l | cut -d'.' -f1)

                totaldepstime=$(echo "${totaldepstime} + ${depstime}" | bc -l)
                totalnumdeps=$(echo "${totalnumdeps} + ${numdeps}" | bc -l)
                break
            fi

            j=$((j + 1))
        done
        i=$((i + 1))
    done

    echo ${totaldepstime},${totalnumdeps}
}

# Main logic starts here
(
    cd ${RESULTS}

    for l in $(ls dtdresults/ | grep "_output$"); do
    (
        proj=$(echo ${l} | sed 's;_output;;')
        precomputed=$(find dtdresults/${l} -name precomputed)
        cd ${precomputed}

        for testtype in ORIG AUTO; do
            # Some rolling sum to compute for selection (which is combination of prioritization and parallelization)
            rollingseledepstime=0
            rollingseledepscount=0
            rollingselenumdepscount=0

            rollingdepstime=0
            rollingdepscount=0
            rollingnumdepscount=0
            for cov in FUNCTION STATEMENT; do
                for type in ABSOLUTE RELATIVE; do
                    totaldepstime=0
                    totalnumdeps=0
                    # Find all the files that result in finding DTs
                    # First look through prioritization
                    for f in $(find -name "PRIORITIZATION-${testtype}-*${cov}-${type}*true.txt" | xargs grep -l "Average time to find one dependency:"); do
                        # Get the total amount of time to get dependencies by getting average time and number of dependent tests handled
                        # First get average time for one
                        onedeptime=$(grep "Average time to find one dependency: " ${f} | cut -d':' -f2 | cut -d' ' -f2)
                        # Second get the number of dependent tests handled
                        dependenttests=$(grep -A1 "Dependent test list:" ${f} | grep -v "Dependent test list:")
                        numdeps=$(echo ${dependenttests} | sed 's;\[;;' | sed 's;\];;' | sed 's;, ;\n;g' | cut -d'>' -f2 | sort -u | wc -l)
                        depstime=$(echo "${onedeptime} * ${numdeps}" | bc -l | cut -d'.' -f1)

                        totaldepstime=$(echo "${totaldepstime} + ${depstime}" | bc -l)
                        totalnumdeps=$(echo "${totalnumdeps} + ${numdeps}" | bc -l)

                    done
                    if [[ ${totalnumdeps} != 0 ]]; then
                        theavg=$(echo "${totaldepstime} / ${totalnumdeps}" | bc -l | cut -d'.' -f1)
                    else
                        theavg=0
                    fi
                    echo "\\Def{${proj}_$(echo ${testtype} | tr '[:upper:]' '[:lower:]')_deptime_prio_$(echo ${cov} | cut -c1-4 | tr '[:upper:]' '[:lower:]')_$(echo ${type} | cut -c1-4 | tr '[:upper:]' '[:lower:]')}{${theavg}}"
                    if [[ ${totaldepstime} != 0 ]]; then
                        rollingdepstime=$((rollingdepstime + totaldepstime))
                        rollingdepscount=$((rollingdepscount + 1))
                        rollingnumdepscount=$((rollingnumdepscount + totalnumdeps))
                    fi
                done
            done
            if [[ ${rollingdepscount} != 0 ]]; then
                echo "\\Def{${proj}_$(echo ${testtype} | tr '[:upper:]' '[:lower:]')_deptime_prio_avg}{$(echo ${rollingdepstime} / ${rollingnumdepscount} | bc -l | cut -d'.' -f1)}"
                rollingseledepstime=$((rollingseledepstime + rollingdepstime))
                rollingseledepscount=$((rollingseledepscount + rollingdepscount))
                rollingselenumdepscount=$((rollingselenumdepscount + rollingnumdepscount))
            else
                echo "\\Def{${proj}_$(echo ${testtype} | tr '[:upper:]' '[:lower:]')_deptime_prio_avg}{-}"
            fi

            rollingdepstime=0
            rollingdepscount=0
            rollingnumdepscount=0
            for type in ORIGINAL TIME; do
                for machine in TWO FOUR EIGHT SIXTEEN; do
                    # Next look through parallelization
                    totaldepstime=0
                    totalnumdeps=0
                    for f in $(find -name "PARALLELIZATION-${testtype}-*${type}-*${machine}*true.txt" | xargs grep -l "Average time to find one dependency:"); do
                        # Get the total amount of time to get dependencies by getting average time and number of dependent tests handled
                        parsepara=$(parse_para ${f})
                        depstime=$(echo ${parsepara} | cut -d',' -f1)
                        numdeps=$(echo ${parsepara} | cut -d',' -f2)

                        totaldepstime=$(echo "${totaldepstime} + ${depstime}" | bc -l)
                        totalnumdeps=$(echo "${totalnumdeps} + ${numdeps}" | bc -l)
                    done
                    if [[ ${totalnumdeps} != 0 ]]; then
                        theavg=$(echo "${totaldepstime} / ${totalnumdeps}" | bc -l | cut -d'.' -f1)
                    else
                        theavg=0
                    fi
                    echo "\\Def{${proj}_$(echo ${testtype} | tr '[:upper:]' '[:lower:]')_deptime_para_$(echo ${type} | cut -c1-4 | tr '[:upper:]' '[:lower:]')_$(echo ${machine} | cut -c1-4 | tr '[:upper:]' '[:lower:]')}{${theavg}}"
                    if [[ ${totaldepstime} != 0 ]]; then
                        rollingdepstime=$((rollingdepstime + totaldepstime))
                        rollingdepscount=$((rollingdepscount + 1))
                        rollingnumdepscount=$((rollingnumdepscount + totalnumdeps))
                    fi
                done
            done
            if [[ ${rollingdepscount} != 0 ]]; then
                echo "\\Def{${proj}_$(echo ${testtype} | tr '[:upper:]' '[:lower:]')_deptime_para_avg}{$(echo ${rollingdepstime} / ${rollingnumdepscount} | bc -l | cut -d'.' -f1)}"
                rollingseledepstime=$((rollingseledepstime + rollingdepstime))
                rollingseledepscount=$((rollingseledepscount + rollingdepscount))
                rollingselenumdepscount=$((rollingselenumdepscount + rollingnumdepscount))
            else
                echo "\\Def{${proj}_$(echo ${testtype} | tr '[:upper:]' '[:lower:]')_deptime_para_avg}{-}"
            fi

            # Write out the average for selection purposes
            if [[ ${rollingseledepscount} != 0 ]]; then
                echo "\\Def{${proj}_$(echo ${testtype} | tr '[:upper:]' '[:lower:]')_deptime_sele_avg}{$(echo "${rollingseledepstime} / ${rollingselenumdepscount}" | bc -l | cut -d'.' -f1)}"
            else
                echo "\\Def{${proj}_$(echo ${testtype} | tr '[:upper:]' '[:lower:]')_deptime_sele_avg}{-}"
            fi
        done
    )
done
)
