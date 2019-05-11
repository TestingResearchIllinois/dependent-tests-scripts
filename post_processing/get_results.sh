#!/bin/bash

for testtype in orig auto; do
(
    cd ${testtype}results/

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
    
        ## Keep track of total DTs across all techniques for this subject
        #totaldtsfile=$(mktemp /tmp/dts.XXXXXX)
    
        #for tech in PRIORITIZATION SELECTION PARALLELIZATION; do
        #    techdtsfile=$(mktemp /tmp/dts.XXXXXX)
        #    for f in $(find ${l} -name ${tech}-* | grep OMITTED | grep false); do
        #        # If PRIORITIZATION or PARALLELIZATION, only keep track of those in immediate next revision
        #        if [[ ${tech} == PRIORITIZATION || ${tech} == PARALLELIZATION ]]; then
        #            if [[ $(echo ${f} | grep "${firstsha}") == "" ]]; then
        #                continue
        #            fi
        #        fi
        #        dtsline=$(grep -A1 "DTs not fixed are:" ${f})
        #        if [[ ${dtsline} == "" ]]; then
        #            continue
        #        fi
        #        for dts in $(echo ${dtsline} | sed 's;DTs not fixed are: ;;g' | sed 's; -- ; ;g'); do
        #            echo ${dts} | xargs | sed 's;\[;;' | sed 's;\];;' | sed 's;, ;\n;g' >> ${techdtsfile}
        #            echo ${dts} | xargs | sed 's;\[;;' | sed 's;\];;' | sed 's;, ;\n;g' >> ${totaldtsfile}
        #        done
        #    done
        #    echo "\Def{${projmod}_${testtype}_dts_$(echo ${tech} | tr '[:upper:]' '[:lower:]' | cut -c 1-4)}{$(sort -u ${techdtsfile} | wc -l)}"
        #    rm ${techdtsfile}
    
        #    # Count how many revisions had DTs found
        #    revswithdts=""
        #    for f in $(find ${l} -name ${tech}-* | grep OMITTED | grep false); do
        #        # If PRIORITIZATION or PARALLELIZATION, only keep track of those in immediate next revision
        #        if [[ ${tech} == PRIORITIZATION || ${tech} == PARALLELIZATION ]]; then
        #            if [[ $(echo ${f} | grep "${firstsha}") == "" ]]; then
        #                continue
        #            fi
        #        fi
        #        dtsline=$(grep -A1 "DTs not fixed are:" ${f})
        #        if [[ ${dtsline} == "" ]]; then
        #            continue
        #        fi
        #        revswithdts="${revswithdts} $(echo ${f} | rev | cut -d'/' -f3 | rev)"
        #    done
        #    if [[ ! -z ${revswithdts} ]]; then
        #        echo "\Def{${projmod}_${testtype}_revswithdts_$(echo ${tech} | tr '[:upper:]' '[:lower:]' | cut -c 1-4)}{$(echo ${revswithdts} | sed 's; ;\n;g' | sort -u | wc -l)}"
        #    else
        #        echo "\Def{${projmod}_${testtype}_revswithdts_$(echo ${tech} | tr '[:upper:]' '[:lower:]' | cut -c 1-4)}{0}"
        #    fi
        #done
        #dts=$(sort -u ${totaldtsfile} | wc -l)
        #echo "\Def{${projmod}_${testtype}_dts_found}{${dts}}"
        #rm ${totaldtsfile}
    
        ## Compute some percentages
        #percdts=$(echo "${dts} / ${numtests} * 100" | bc -l | xargs printf "%.1f")
        #echo "\Def{${projmod}_${testtype}_dtsperc_found}{${percdts}}"
    done
)
done

#dts=$(find ${l} -name ${tech}-* | grep ${status} | grep -v "STATEMENT-ORIGINAL" | grep false | xargs grep "Number of DTs" | grep -v ": 0" | wc -l)
#total=$(find ${l} -name ${tech}-* | grep ${status} | grep -v "STATEMENT-ORIGINAL" | grep false | wc -l)
#echo ${l} ${dts} ${total}
