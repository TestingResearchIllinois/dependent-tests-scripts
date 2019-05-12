#!/bin/bash

for testtype in orig auto; do
(
    cd ${testtype}results/

    for l in $(ls | grep "_output$"); do
        projmod=$(echo ${l} | sed 's;_output;;')
    
        # Get the first revision
        firstrev=$(find ${l} -name "*-lifetime" | xargs ls | sort | head -1)
        firstsha=$(echo ${firstrev} | rev | cut -d'-' -f1 | rev | cut -c 1-8)
    
        # Get the number of tests in the first revision (open some prioritization file and read total tests)
        priofile=$(find $(find ${l} -name "*-lifetime" | sort | head -1) -name "PRIORITIZATION-$(echo ${testtype} | tr '[:lower:]' '[:upper:]')-*" | grep ${firstsha} | head -1)
        if [[ ${priofile} != "" ]]; then
            numtests=$(grep "Number of tests selected" ${priofile} | rev | cut -d' ' -f1 | rev)
        fi
    
        # Keep track of total DTs are across all techniques for this subject
        totaldtsfile=$(mktemp /tmp/dts.XXXXXX)
    
        for tech in PRIORITIZATION SELECTION PARALLELIZATION; do
            techdtsfile=$(mktemp /tmp/dts.XXXXXX)
            for f in $(find ${l} -name ${tech}-* | grep GIVEN | grep false); do
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
                        echo ${dt} >> ${totaldtsfile}
                    done
                done
            done
            echo "\Def{${projmod}_${testtype}_dtsgiven_$(echo ${tech} | tr '[:upper:]' '[:lower:]' | cut -c 1-4)}{$(cat ${techdtsfile} | wc -l)}"

            # Remove any of these failures that are also nondeterministic
            nodfile=$(find ../dtdresults/ -name list.txt | grep "${l}" | grep "${testtype}" | grep "nondeterministic")
            if [[ ${nodfile} != "" ]]; then
                comm -23 <(sort -u ${techdtsfile}) <(sort -u ${nodfile}) > /tmp/tmp
                mv /tmp/tmp ${techdtsfile}
            fi
            echo "\Def{${projmod}_${testtype}_dtfailuresgiven_$(echo ${tech} | tr '[:upper:]' '[:lower:]' | cut -c 1-4)}{$(sort -u ${techdtsfile} | wc -l)}"
            rm ${techdtsfile}
    
            # Count how many configurations had DTs found
            confswithdts=0
            totalconfs=0
            for f in $(find ${l} -name ${tech}-* | grep GIVEN | grep false); do
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
            echo "\Def{${projmod}_${testtype}_confswithdtsgiven_$(echo ${tech} | tr '[:upper:]' '[:lower:]' | cut -c 1-4)}{${confswithdts}}"
            echo "\Def{${projmod}_${testtype}_totalconfsgiven_$(echo ${tech} | tr '[:upper:]' '[:lower:]' | cut -c 1-4)}{${totalconfs}}"
        done

        dts=$(sort -u ${totaldtsfile} | wc -l)
        echo "\Def{${projmod}_${testtype}_dtsgiven}{${dts}}"
        rm ${totaldtsfile}
    
        # Compute some percentages
        percdts=$(echo "${dts} / ${numtests} * 100" | bc -l | xargs printf "%.1f")
        echo "\Def{${projmod}_${testtype}_dtsgivenperc}{${percdts}}"
    done
)
done
