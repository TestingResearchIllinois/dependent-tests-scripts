#!/bin/bash

for l in $(ls dtdresults/ | grep "_output$"); do
    projmod=$(echo ${l} | sed 's;_output;;')

    # Get the first revision
    firstrev=$(find origresults/${l} -name "*-lifetime" | xargs ls | sort | head -1)
    firstsha=$(echo ${firstrev} | rev | cut -d'-' -f1 | rev | cut -c 1-8)

    # Get the orig
    origfile=$(find dtdresults/${l} -name list.txt | grep "orig")
    orig=$(grep -c "" ${origfile})
    echo "\\Def{${projmod}_orig_dts}{${orig}}"
    # Get the number of tests in the first revision (open some prioritization file and read total tests)
    priofile=$(find $(find origresults/${l} -name "*-lifetime" | sort | head -1) -name "PRIORITIZATION-$(echo orig | tr '[:lower:]' '[:upper:]')-*" | grep ${firstsha} | head -1)
    if [[ ${priofile} != "" ]]; then
        numtests=$(grep "Number of tests selected" ${priofile} | rev | cut -d' ' -f1 | rev)
    fi
    percdts=$(echo "${orig} / ${numtests} * 100" | bc -l | xargs printf "%.0f")
    echo "\Def{${projmod}_orig_dtsperc}{${percdts}\%}"

    # Get the auto
    autofile=$(find dtdresults/${l} -name list.txt | grep "auto")
    auto=$(grep -c "" ${autofile})
    echo "\\Def{${projmod}_auto_dts}{${auto}}"
    # Get the number of tests in the first revision (open some prioritization file and read total tests)
    priofile=$(find $(find autoresults/${l} -name "*-lifetime" | sort | head -1) -name "PRIORITIZATION-$(echo auto | tr '[:lower:]' '[:upper:]')-*" | grep ${firstsha} | head -1)
    if [[ ${priofile} != "" ]]; then
        numtests=$(grep "Number of tests selected" ${priofile} | rev | cut -d' ' -f1 | rev)
    fi
    percdts=$(echo "${auto} / ${numtests} * 100" | bc -l | xargs printf "%.0f")
    echo "\Def{${projmod}_auto_dtsperc}{${percdts}\%}"

    # Now compute how many of the dts are detected by the techniques
    for testtype in orig auto; do
        for tech in PRIORITIZATION SELECTION PARALLELIZATION; do
            techdtsfile=$(mktemp /tmp/dts.XXXXXX)
            for f in $(find ${testtype}results/${l} -name ${tech}-* | grep OMITTED | grep false); do
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
                done
            done
            macrokey=$(echo ${tech} | tr '[:upper:]' '[:lower:]' | cut -c 1-4)
            echo "\Def{${projmod}_${testtype}_dts_${macrokey}}{$(sort -u ${techdtsfile} | grep -c "")}"

            # Compute what percentage of the dts total are found by the technique
            if [[ ${testtype} == orig ]]; then
                dtdfile=${origfile}
                total=${orig}
            else
                dtdfile=${autofile}
                total=${auto}
            fi
            incommon=$(comm -12 <(sort -u ${techdtsfile}) <(sort -u ${dtdfile}) | grep -c "")
            if [[ ${total} != 0 ]]; then
                perc="$(echo "${incommon} / ${total} * 100" | bc -l | xargs printf "%.0f")\%"
            else
                perc="-"
            fi
            echo "\Def{${projmod}_${testtype}_dtsperc_${macrokey}}{${perc}}"

            rm ${techdtsfile}
        done
    done
done
