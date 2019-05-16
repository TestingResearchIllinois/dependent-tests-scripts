#!/bin/bash

RESULTS=$1
if [[ ${RESULTS} == "" ]]; then
    echo "arg1 - Path to results directory that contains origresults/, autoresults/, dtdresults/, origorders/"
    exit
fi


for testtype in orig auto; do
(
    cd ${RESULTS}/${testtype}results/

    # For each technique combination, find number of DTs discovered by each one

    # PRIORITIZATION
    tech=PRIORITIZATION
    for cov in FUNCTION STATEMENT; do
        for type in ABSOLUTE RELATIVE; do
            techdtsfile=$(mktemp /tmp/dts.XXXXXX)

            # Need to consider only the first revision for each project
            for l in $(ls | grep "_output$"); do
                # Get the first revision for each project
                firstrev=$(find ${l} -name "*-lifetime" | xargs ls | sort | head -1)
                firstsha=$(echo ${firstrev} | rev | cut -d'-' -f1 | rev | cut -c 1-8)

                for f in $(find ${l} -name "${tech}-*-${cov}-${type}-*" | grep OMITTED | grep false | grep "${firstsha}"); do
                    dtsline=$(grep -A1 "DTs not fixed are:" ${f} | sed 's;\[;;' | sed 's;\];;')
                    if [[ ${dtsline} == "" ]]; then
                        continue
                    fi
                    for dts in $(echo ${dtsline} | sed 's;DTs not fixed are: ;;g' | sed 's; -- ; ;g'); do
                        for dt in $(echo ${dts} | xargs | sed 's;,;\n;g' | xargs); do
                            echo ${l},${dt} >> ${techdtsfile}
                        done
                    done
                done
            done
            macrokey=$(echo ${tech} | cut -c 1-4)_$(echo ${cov} | cut -c 1-4)_$(echo ${type} | cut -c 1-4)
            echo "\Def{${testtype}_dts_$(echo ${macrokey} | tr '[:upper:]' '[:lower:]')}{$(sort -u ${techdtsfile} | wc -l)}"
            rm ${techdtsfile}
        done
    done

    # SELECTION
    tech=SELECTION
    for cov in FUNCTION STATEMENT; do
        for type in ORIGINAL ABSOLUTE RELATIVE; do
            techdtsfile=$(mktemp /tmp/dts.XXXXXX)
            for f in $(find -name "${tech}-*-${cov}-${type}-*" | grep OMITTED | grep false); do
                dtsline=$(grep -A1 "DTs not fixed are:" ${f} | sed 's;\[;;' | sed 's;\];;')
                if [[ ${dtsline} == "" ]]; then
                    continue
                fi
                for dts in $(echo ${dtsline} | sed 's;DTs not fixed are: ;;g' | sed 's; -- ; ;g'); do
                    for dt in $(echo ${dts} | xargs | sed 's;,;\n;g' | xargs); do
                        echo ${l},${dt} >> ${techdtsfile}
                    done
                done
            done
            macrokey=$(echo ${tech} | cut -c 1-4)_$(echo ${cov} | cut -c 1-4)_$(echo ${type} | cut -c 1-4)
            echo "\Def{${testtype}_dts_$(echo ${macrokey} | tr '[:upper:]' '[:lower:]')}{$(sort -u ${techdtsfile} | wc -l)}"
            rm ${techdtsfile}
        done
    done

    # PARALLELIZATION
    tech=PARALLELIZATION
    for type in ORIGINAL TIME; do
        techdtsfile=$(mktemp /tmp/dts.XXXXXX)

        # Need to consider only the first revision for each project
        for l in $(ls | grep "_output$"); do
            # Get the first revision for each project
            firstrev=$(find ${l} -name "*-lifetime" | xargs ls | sort | head -1)
            firstsha=$(echo ${firstrev} | rev | cut -d'-' -f1 | rev | cut -c 1-8)

            for f in $(find ${l} -name "${tech}-*-${type}-*" | grep OMITTED | grep false | grep "${firstsha}"); do
                dtsline=$(grep -A1 "DTs not fixed are:" ${f} | sed 's;\[;;' | sed 's;\];;')
                if [[ ${dtsline} == "" ]]; then
                    continue
                fi
                for dts in $(echo ${dtsline} | sed 's;DTs not fixed are: ;;g' | sed 's; -- ; ;g'); do
                    for dt in $(echo ${dts} | xargs | sed 's;,;\n;g' | xargs); do
                        echo ${l},${dt} >> ${techdtsfile}
                    done
                done
            done
        done
        macrokey=$(echo ${tech} | cut -c 1-4)_$(echo ${type} | cut -c 1-4)
        echo "\Def{${testtype}_dts_$(echo ${macrokey} | tr '[:upper:]' '[:lower:]')}{$(sort -u ${techdtsfile} | wc -l)}"
        rm ${techdtsfile}
    done
)
done
