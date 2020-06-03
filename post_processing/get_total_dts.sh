#!/bin/bash

RESULTS=$1
if [[ ${RESULTS} == "" ]]; then
    echo "arg1 - Path to results directory that contains origresults/, autoresults/, dtdresults/, origorders/"
    exit
fi

(
    cd ${RESULTS}

    for l in $(ls dtdresults/ | grep "_output$"); do
        projmod=$(echo ${l} | sed 's;_output;;')

        # ORIG

        # Get the first revision
        firstrev=$(find origresults/${l} -name "*-lifetime" | xargs ls | sort | head -1)
        firstsha=$(echo ${firstrev} | rev | cut -d'-' -f1 | rev | cut -c 1-8)

        # Get the number of orig tests in the first revision (open some prioritization file and read total tests)
        priofile=$(find $(find origresults/${l} -name "*-lifetime" | sort | head -1) -name "PRIORITIZATION-$(echo orig | tr '[:lower:]' '[:upper:]')-*" | grep ${firstsha} | head -1)
        if [[ ${priofile} != "" ]]; then
            numorigtests=$(grep "Number of tests selected" ${priofile} | rev | cut -d' ' -f1 | rev)
        fi

        # Get the orig nods
        orignodfile=$(find dtdresults/${l} -name list.txt | grep "orig" | grep "nondeterministic")
        if [[ ${orignodfile} == "" ]]; then
            orignod=0
        else
            orignod=$(grep -c "" ${orignodfile})
        fi
        echo "\Def{${projmod}_orig_nods}{${orignod}}"
        percnods=$(echo "${orignod} / ${numorigtests} * 100" | bc -l | xargs printf "%.0f")
        echo "\Def{${projmod}_orig_nodsperc}{${percnods}\%}"

        # Get the orig dts
        origfile=$(find dtdresults/${l} -name list.txt | grep "orig" | grep "random" | grep "all-")
        orig=$(grep -c "" ${origfile})
        echo "\Def{${projmod}_orig_dts}{${orig}}"
        percdts=$(echo "${orig} / ${numorigtests} * 100" | bc -l | xargs printf "%.0f")
        echo "\Def{${projmod}_orig_dtsperc}{${percdts}\%}"

        # AUTO

        # Get the number of auto tests in the first revision (open some prioritization file and read total tests)
        priofile=$(find $(find autoresults/${l} -name "*-lifetime" | sort | head -1) -name "PRIORITIZATION-$(echo auto | tr '[:lower:]' '[:upper:]')-*" | grep ${firstsha} | head -1)
        if [[ ${priofile} != "" ]]; then
            numautotests=$(grep "Number of tests selected" ${priofile} | rev | cut -d' ' -f1 | rev)
        fi

        # Get the auto nods
        autonodfile=$(find dtdresults/${l} -name list.txt | grep "auto" | grep "nondeterministic")
        if [[ ${autonodfile} == "" ]]; then
            autonod=0
        else
            autonod=$(grep -c "" ${autonodfile})
        fi
        echo "\Def{${projmod}_auto_nods}{${autonod}}"
        percnods=$(echo "${autonod} / ${numautotests} * 100" | bc -l | xargs printf "%.0f")
        echo "\Def{${projmod}_auto_nodsperc}{${percnods}\%}"

        # Get the auto dts
        autofile=$(find dtdresults/${l} -name list.txt | grep "auto" | grep "random" | grep "all-")
        auto=$(grep -c "" ${autofile})
        echo "\\Def{${projmod}_auto_dts}{${auto}}"
        percdts=$(echo "${auto} / ${numautotests} * 100" | bc -l | xargs printf "%.0f")
        echo "\Def{${projmod}_auto_dtsperc}{${percdts}\%}"

        # Now compute how many of the dts are detected by the techniques
        for testtype in orig auto; do
            for tech in PRIORITIZATION SELECTION PARALLELIZATION; do
                techdtsfile=$(mktemp /tmp/dts.XXXXXX)
                for f in $(find ${testtype}results/${l} -name ${tech}-* | grep OMITTED | grep "true"); do
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

                # Compute what percentage of the dts total are found by the technique
                if [[ ${testtype} == orig ]]; then
                    dtdfile=${origfile}
                    total=${orig}
                else
                    dtdfile=${autofile}
                    total=${auto}
                fi
                incommon=$(comm -12 <(sort -u ${techdtsfile}) <(sort -u ${dtdfile}) | grep -c "")
                #echo "\Def{${projmod}_${testtype}_dts_${macrokey}}{$(sort -u ${techdtsfile} | grep -c "")}" # Only in common ones
                echo "\Def{${projmod}_${testtype}_dts_${macrokey}}{${incommon}}" # Only in common ones
                if [[ ${total} != 0 ]]; then
                    perc="$(echo "${incommon} / ${total} * 100" | bc -l | xargs printf "%.0f")\%"
                else
                    perc="n/a"
                fi
                echo "\Def{${projmod}_${testtype}_dtsperc_${macrokey}}{${perc}}"

                rm ${techdtsfile}
            done
        done
    done
)
