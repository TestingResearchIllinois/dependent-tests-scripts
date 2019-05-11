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
                    echo ${dts} | xargs | sed 's;,;\n;g' | xargs >> ${techdtsfile}
                    echo ${dts} | xargs | sed 's;,;\n;g' | xargs >> ${totaldtsfile}
                done
            done
            echo "\Def{${projmod}_${testtype}_dtsgiven_$(echo ${tech} | tr '[:upper:]' '[:lower:]' | cut -c 1-4)}{$(sort -u ${techdtsfile} | wc -l)}"
            rm ${techdtsfile}
    
            # Count how many revisions had DTs found
            revswithdts=""
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
                revswithdts="${revswithdts} $(echo ${f} | rev | cut -d'/' -f3 | rev)"
            done
            if [[ ! -z ${revswithdts} ]]; then
                echo "\Def{${projmod}_${testtype}_revswithdtsgiven_$(echo ${tech} | tr '[:upper:]' '[:lower:]' | cut -c 1-4)}{$(echo ${revswithdts} | sed 's; ;\n;g' | sort -u | wc -l)}"
            else
                echo "\Def{${projmod}_${testtype}_revswithdtsgiven_$(echo ${tech} | tr '[:upper:]' '[:lower:]' | cut -c 1-4)}{0}"
            fi
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
