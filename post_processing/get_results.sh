#!/bin/bash

RESULTS=$1
if [[ ${RESULTS} == "" ]]; then
    echo "arg1 - Path to results directory that contains origresults/, autoresults/, dtdresults/, origorders/"
    exit
fi

for testtype in orig auto; do
(
    cd ${RESULTS}/${testtype}results/

    for l in $(ls | grep "_output$"); do
        projmod=$(echo ${l} | sed 's;_output;;')
    
        # Get the first revision
        firstrev=$(find ${l} -name "*-lifetime" | xargs ls | sort | head -1)
        firstsha=$(echo ${firstrev} | rev | cut -d'-' -f1 | rev | cut -c 1-8)
        echo "\Def{${projmod}_${testtype}_firstsha}{${firstsha}}"
    
        # Get the number of tests in the first revision (open some prioritization file and read total tests)
        priofile=$(find $(find ${l} -name "*-lifetime" | sort | head -1) -name "PRIORITIZATION-$(echo ${testtype} | tr '[:lower:]' '[:upper:]')-*" | grep ${firstsha} | head -1)
        if [[ ${priofile} != "" ]]; then
            numtests=$(grep "Number of tests selected" ${priofile} | rev | cut -d' ' -f1 | rev)
            echo "\Def{${projmod}_${testtype}_numtests}{${numtests}}"
        fi
    
        # Get the number of revisions used
        numrevs=$(find ${l} -name "*-lifetime" | xargs ls | wc -l)
        echo "\Def{${projmod}_${testtype}_numrevs}{${numrevs}}"

        # Record the number of test failures that occurred
        for tech in PRIORITIZATION SELECTION PARALLELIZATION; do
            techdtsfile=$(mktemp /tmp/dts.XXXXXX)
            for f in $(find ${l} -name ${tech}-* | grep OMITTED | grep false); do
                # If PRIORITIZATION or PARALLELIZATION, only keep track of those in immediate next revision
                if [[ ${tech} == PRIORITIZATION || ${tech} == PARALLELIZATION ]]; then
                    if [[ $(echo ${f} | grep "${firstsha}") == "" ]]; then
                        continue
                    fi
                fi
                dtsline=$(grep -A1 "DTs not fixed are:" ${f} | sed 's;\[;;' | sed 's;\];;')
                if [[ ${dtsline} == "" ]]; then
                    continue
                fi
                for dts in $(echo ${dtsline} | sed 's;DTs not fixed are: ;;g' | sed 's; -- ; ;g'); do
                    for dt in $(echo ${dts} | xargs | sed 's;,;\n;g' | xargs); do
                        echo ${dt} >> ${techdtsfile}
                    done
                done
            done
            echo "\Def{${projmod}_${testtype}_dtfailures_$(echo ${tech} | tr '[:upper:]' '[:lower:]' | cut -c 1-4)}{$(cat ${techdtsfile} | wc -l)}"
            rm ${techdtsfile}
    
            # Count how many configurations had DTs found
            confswithdts=0
            totalconfs=0
            for f in $(find ${l} -name ${tech}-* | grep OMITTED | grep false); do
                # If PRIORITIZATION or PARALLELIZATION, only keep track of those in immediate next revision
                if [[ ${tech} == PRIORITIZATION || ${tech} == PARALLELIZATION ]]; then
                    if [[ $(echo ${f} | grep "${firstsha}") == "" ]]; then
                        continue
                    fi
                fi
                totalconfs=$((totalconfs + 1))
                dtsline=$(grep -A1 "DTs not fixed are:" ${f})
                if [[ ${dtsline} == "" ]]; then
                    continue
                fi
                confswithdts=$((confswithdts + 1))
            done
            echo "\Def{${projmod}_${testtype}_confswithdts_$(echo ${tech} | tr '[:upper:]' '[:lower:]' | cut -c 1-4)}{${confswithdts}}"
            echo "\Def{${projmod}_${testtype}_totalconfs_$(echo ${tech} | tr '[:upper:]' '[:lower:]' | cut -c 1-4)}{${totalconfs}}"
        done
    done
)
done
