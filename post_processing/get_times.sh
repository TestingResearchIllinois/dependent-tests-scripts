#!/bin/bash

RESULTS=$1
if [[ ${RESULTS} == "" ]]; then
    echo "arg1 - Path to results directory that contains origresults/, autoresults/, dtdresults/, origorders/"
    exit
fi

for testtype in orig auto; do
(
    cd ${RESULTS}/${testtype}results/

    for TYPE in OMITTED GIVEN; do

        for l in $(ls | grep "_output$"); do
            projmod=$(echo ${l} | sed 's;_output;;')

            # Get the first revision
            firstrev=$(find ${l} -name "*-lifetime" | xargs ls | sort | head -1)
            firstsha=$(echo ${firstrev} | rev | cut -d'-' -f1 | rev | cut -c 1-8)

            # Selection
            totaltime=0
            for f in $(find ${l} -name SELECTION-* | grep ${TYPE} | grep "true"); do
                timesline=$(grep -A1 "Time each test takes to run in the new order:" ${f})
                if [[ ${timesline} == "" ]]; then
                    continue
                fi
                teststime=$(echo ${timesline} | sed 's;Time each test takes to run in the new order:;;' | xargs | sed 's;\[;;' | sed 's;\];;' | sed 's;-;;g' | sed 's;, ;\n;g' | paste -sd+ | bc -l)
                totaltime=$((totaltime + teststime))
            done
            if [[ ${TYPE} == GIVEN ]]; then
                echo "\Def{${projmod}_${testtype}_testtimegiven_sele}{${totaltime}}"
            else
                echo "\Def{${projmod}_${testtype}_testtime_sele}{${totaltime}}"
            fi

            # Parallelization
            totaltime=0
            for f in $(find ${l} -name PARALLELIZATION-* | grep ${TYPE} | grep "true"); do
                # Only keep track of immediate next revision for parallelization
                if [[ $(echo ${f} | grep "${firstsha}") == "" ]]; then
                    continue
                fi

                timesline=$(grep -A1 "Time each test takes to run in the new order:" ${f})
                if [[ ${timesline} == "" ]]; then
                    continue
                fi
                longesttime=0
                IFS=$'\n'
                for testtimeline in $(echo ${timesline} | sed 's;Time each test takes to run in the new order:;;g' | sed 's; -- ;\n;g'); do
                    teststime=$(echo ${testtimeline} | xargs | sed 's;\[;;' | sed 's;\];;' | sed 's;-;;g' | sed 's;, ;\n;g' | paste -sd+ | bc -l)
                    if [[ ${teststime} -gt ${longesttime} ]]; then
                        longesttime=${teststime}
                    fi
                done
                totaltime=$((totaltime + longesttime))
            done
            if [[ ${TYPE} == GIVEN ]]; then
                echo "\Def{${projmod}_${testtype}_testtimegiven_para}{${totaltime}}"
            else
                echo "\Def{${projmod}_${testtype}_testtime_para}{${totaltime}}"
            fi
        done
    done
)
done
