#!/bin/bash

RESULTS=$1
if [[ ${RESULTS} == "" ]]; then
    echo "arg1 - Path to results directory that contains origresults/, autoresults/, dtdresults/, origorders/"
    exit
fi

function compute_selection() {

    testtype=$1

    # Rolling sums for the final overall number
    rollingomittedtotaltime=0
    rollinggiventotaltime=0

    for p in $(ls | grep "_output$"); do
        projmod=$(echo ${p} | sed 's;_output;;')

        # Sum up the times between the two, omitted and given
        omittedtotaltime=0
        giventotaltime=0

        # Match up the OMITTED with the GIVEN to check if there is a difference and if should count
        for omitted in $(find ${p} -name SELECTION-* | grep OMITTED | grep "true"); do
            given=$(echo ${omitted} | sed 's;OMITTED;GIVEN;')

            omittedtestorder=$(grep -A1 "Test order list:" ${omitted} | grep -v "Test order list:")
            giventestorder=$(grep -A1 "Test order list:" ${given} | grep -v "Test order list:")

            # Skip if the two orders are the same
            if [[ $(diff <(echo ${omittedtestorder}) <(echo ${giventestorder})) == "" ]]; then
                continue
            fi

            # Otherwise, get the test time
            omittedtesttime=$(grep "Execution time for executing the following testing order: " ${omitted} | cut -d' ' -f9)
            giventesttime=$(grep "Execution time for executing the following testing order: " ${given} | cut -d' ' -f9)

            # Sum up the respective times across all revisions
            omittedtotaltime=$(echo ${omittedtotaltime} + ${omittedtesttime} | bc -l)
            giventotaltime=$(echo ${giventotaltime} + ${giventesttime} | bc -l)
        done

        # Report the times and the diff between the two by percentage, using omittedtotaltime as the baseline
        echo "\Def{${projmod}_${testtype}_testtime_sele}{${omittedtotaltime}}"
        echo "\Def{${projmod}_${testtype}_testtimegiven_sele}{${giventotaltime}}"
        if [[ ${omittedtotaltime} != 0 ]]; then
            echo "\Def{${projmod}_${testtype}_testtimediff_sele}{$(echo "(${giventotaltime} - ${omittedtotaltime}) / ${omittedtotaltime} * 100" | bc -l | xargs printf "%.0f")\%}"
        else
            echo "\Def{${projmod}_${testtype}_testtimediff_sele}{=}"
        fi

        rollingomittedtotaltime=$(echo "${rollingomittedtotaltime} + ${omittedtotaltime}" | bc -l)
        rollinggiventotaltime=$(echo "${rollinggiventotaltime} + ${giventotaltime}" | bc -l)
    done

    # Compute the overall summary across all projects
    if [[ ${rollingomittedtotaltime} != 0 ]]; then
        echo "\Def{overall_${testtype}_testtimediff_sele}{$(echo "(${rollinggiventotaltime} - ${rollingomittedtotaltime}) / ${rollingomittedtotaltime} * 100" | bc -l | xargs printf "%.0f")\%}"
    else
        echo "\Def{overall_${testtype}_testtimediff_sele}{=}"
    fi

}

function compute_parallelization() {

    testtype=$1

    # Rolling sums for the final overall number
    rollingomittedtotaltime=0
    rollinggiventotaltime=0

    for p in $(ls | grep "_output$"); do
        projmod=$(echo ${p} | sed 's;_output;;')

        # Get the first revision
        firstrev=$(find ${p} -name "*-lifetime" | xargs ls | sort | head -1)
        firstsha=$(echo ${firstrev} | rev | cut -d'-' -f1 | rev | cut -c 1-8)

        # Sum up the times between the two, omitted and given
        omittedtotaltime=0
        giventotaltime=0

        # Match up the OMITTED with the GIVEN to check if there is a difference and if should count
        for omitted in $(find ${p} -name PARALLELIZATION-* | grep OMITTED | grep "true"); do
            # Only keep track of immediate next revision for parallelization
            if [[ $(echo ${f} | grep "${firstsha}") == "" ]]; then
                continue
            fi

            given=$(echo ${omitted} | sed 's;OMITTED;GIVEN;')

            # In parallelization file, there are multiple such test order lists
            omittedtestorders=$(grep -A1 "Test order list:" ${omitted})
            giventestorders=$(grep -A1 "Test order list:" ${given})

            # Want to just get times corresponding to longest omitted order time
            longestomittedtime=0
            longestgiventime=0

            # ASSUMPTION: placement of test order in file matches up between omitted and given
            IFS=$'\n'

            # Search for which machine has the longest omitted order time
            i=0
            longestindex=0
            for ot in $(grep "Execution time for executing the following testing order: " ${omitted}); do
                omittedtesttime=$(echo ${ot} | cut -d' ' -f9)
                # If the omitted time is greater than the longest time, we keep it
                if [[ $(echo "${omittedtesttime} > ${longestomittedtime}" | bc -l) == 1 ]]; then
                    longestomittedtime=${omittedtesttime}
                    longestindex=${i}
                fi
                i=$((i + 1))
            done
            # Once we found the longest running time, get the corresponding time in the given
            i=0
            for gt in $(grep "Execution time for executing the following testing order: " ${given}); do
                # Time associated with longestindex
                if [[ ${i} == ${longestindex} ]]; then 
                    longestgiventime=$(echo ${gt} | cut -d' ' -f9)
                    break
                fi
                i=$((i + 1))
            done

            # Search for the test orders corresponding to this index and compare them to see if we should consider them
            i=0
            for omittedto in $(echo ${omittedtestorders} | sed 's;Test order list;;g' | sed 's; -- ;\n;g'); do
                if [[ ${i} == ${longestindex} ]]; then
                    break   # By breaking, omittedto should be this final one where the index match
                fi
                i=$((i + 1))
            done
            i=0
            for givento in $(echo ${giventestorders} | sed 's;Test order list;;g' | sed 's; -- ;\n;g'); do
                if [[ ${i} == ${longestindex} ]]; then
                    break   # By breaking, givento should be this final one where the index match
                fi
                i=$((i + 1))
            done

            # Only consider if the two orders are not the same, and sum it up
            if [[ $(diff <(echo ${omittedto}) <(echo ${givento})) != "" ]]; then
                omittedtotaltime=$(echo ${omittedtotaltime} + ${longestomittedtime} | bc -l)
                giventotaltime=$(echo ${giventotaltime} + ${longestgiventime} | bc -l)
            fi
        done

        # Report the times and the diff between the two by percentage, using omittedtotaltime as the baseline
        echo "\Def{${projmod}_${testtype}_testtime_para}{${omittedtotaltime}}"
        echo "\Def{${projmod}_${testtype}_testtimegiven_para}{${giventotaltime}}"
        if [[ ${omittedtotaltime} != 0 ]]; then
            echo "\Def{${projmod}_${testtype}_testtimediff_para}{$(echo "(${giventotaltime} - ${omittedtotaltime}) / ${omittedtotaltime} * 100" | bc -l | xargs printf "%.0f")}"
        else
            echo "\Def{${projmod}_${testtype}_testtimediff_para}{=}"
        fi

        rollingomittedtotaltime=$(echo "${rollingomittedtotaltime} + ${omittedtotaltime}" | bc -l)
        rollinggiventotaltime=$(echo "${rollinggiventotaltime} + ${giventotaltime}" | bc -l)
    done

    # Compute the overall summary across all projects
    if [[ ${rollingomittedtotaltime} != 0 ]]; then
        echo "\Def{overall_${testtype}_testtimediff_para}{$(echo "(${rollinggiventotaltime} - ${rollingomittedtotaltime}) / ${rollingomittedtotaltime} * 100" | bc -l | xargs printf "%.0f")}"
    else
        echo "\Def{overall_${testtype}_testtimediff_para}{=}"
    fi
}

# Main logic

for testtype in orig auto; do
(
    cd ${RESULTS}/${testtype}results/

    # Selection
    compute_selection ${testtype}

    # Parallelization
    compute_parallelization ${testtype}
)
done
