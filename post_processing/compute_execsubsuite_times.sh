#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

for testtype in orig auto; do
(
    cd ${testtype}results/

    for TYPE in OMITTED GIVEN; do

        for l in $(ls | grep "_output$"); do
            projmod=$(echo ${l} | sed 's;_output;;')

            # Get the first revision
            firstrev=$(find ${l} -name "*-lifetime" | xargs ls | sort | head -1)
            firstsha=$(echo ${firstrev} | rev | cut -d'-' -f1 | rev | cut -c 1-8)

            # Prioritization
            totaltime=0
            for f in $(find ${l} -name PRIORITIZATION-* | grep ${TYPE} | grep false); do
                # Only keep track of immediate next revision for prioritization
                if [[ $(echo ${f} | grep "${firstsha}") == "" ]]; then
                    continue
                fi
                testtime=$(python ${DIR}/parse_for_execsubsuite.py ${f} ../origorders/${projmod}-${testtype}-order)
                totaltime=$((totaltime + testtime))
            done
            if [[ ${TYPE} == GIVEN ]]; then
                echo "\Def{${projmod}_${testtype}_testtimererunsgiven_prio}{${totaltime}}"
            else
                echo "\Def{${projmod}_${testtype}_testtimereruns_prio}{${totaltime}}"
            fi

            # Selection
            totaltime=0
            for f in $(find ${l} -name SELECTION-* | grep ${TYPE} | grep false); do
                testtime=$(python ${DIR}/parse_for_execsubsuite.py ${f} ../origorders/${projmod}-${testtype}-order)
                totaltime=$((totaltime + testtime))
            done
            if [[ ${TYPE} == GIVEN ]]; then
                echo "\Def{${projmod}_${testtype}_testtimererunsgiven_sele}{${totaltime}}"
            else
                echo "\Def{${projmod}_${testtype}_testtimereruns_sele}{${totaltime}}"
            fi

            # Parallelization
            totaltime=0
            for f in $(find ${l} -name PARALLELIZATION-* | grep ${TYPE} | grep false); do
                timesline=$(grep -A1 "Time each test takes to run in the new order:" ${f})
                if [[ ${timesline} == "" ]]; then
                    continue
                fi
                testtime=$(python ${DIR}/parse_for_execsubsuite.py ${f} ../origorders/${projmod}-${testtype}-order)
                totaltime=$((totaltime + testtime))
            done
            if [[ ${TYPE} == GIVEN ]]; then
                echo "\Def{${projmod}_${testtype}_testtimererunsgiven_para}{${totaltime}}"
            else
                echo "\Def{${projmod}_${testtype}_testtimereruns_para}{${totaltime}}"
            fi
        done
    done
)
done
