#!/bin/bash

for testtype in orig auto; do
(
    cd ${testtype}results/

    # For each technique, find the number of revisions for each case
    caseA=0 # Neither fails
    caseB=0 # Both fails
    caseC=0 # Given passes, unaware fails
    caseD=0 # Given fails, unaware passes

    # PRIORITIZATION
    tech=PRIORITIZATION
    for l in $(ls | grep "_output$"); do
        # Get the first revision
        firstrev=$(find ${l} -name "*-lifetime" | xargs ls | sort | head -1)
        firstsha=$(echo ${firstrev} | rev | cut -d'-' -f1 | rev | cut -c 1-8)

        for cov in FUNCTION STATEMENT; do
            for type in ABSOLUTE RELATIVE; do
                for f in $(find -name "${tech}-*-${cov}-${type}-*" | grep OMITTED | grep false | grep "${firstsha}"); do
                    # Get the same corresponding OMITTED and GIVEN files
                    omittedfile=${f}
                    givenfile=$(echo ${f} | sed 's;OMITTED;GIVEN;')

                    # See if either of them have not fixed DTs
                    omitted=$(grep "DTs not fixed are:" ${omittedfile})
                    given=$(grep "DTs not fixed are:" ${givenfile})

                    # Case A
                    if [[ ${omitted} == "" && ${given} == "" ]]; then
                        caseA=$((caseA + 1))
                    fi
                    # Case B
                    if [[ ${omitted} != "" && ${given} != "" ]]; then
                        caseB=$((caseB + 1))
                    fi
                    # Case C
                    if [[ ${omitted} != "" && ${given} == "" ]]; then
                        caseC=$((caseC + 1))
                    fi
                    # Case D
                    if [[ ${omitted} == "" && ${given} != "" ]]; then
                        caseD=$((caseD + 1))
                    fi
                done
            done
        done
    done
    total=$(echo "${caseA} + ${caseB} + ${caseC} + ${caseD}" | bc -l)
    echo "\Def{${testtype}_caseA_prio}{$(echo "${caseA} / ${total} * 100" | bc -l | xargs printf "%.0f")\%}"
    echo "\Def{${testtype}_caseB_prio}{$(echo "${caseB} / ${total} * 100" | bc -l | xargs printf "%.0f")\%}"
    echo "\Def{${testtype}_caseC_prio}{$(echo "${caseC} / ${total} * 100" | bc -l | xargs printf "%.0f")\%}"
    echo "\Def{${testtype}_caseD_prio}{$(echo "${caseD} / ${total} * 100" | bc -l | xargs printf "%.0f")\%}"

    # SELECTION
    caseA=0
    caseB=0
    caseC=0
    caseD=0
    tech=SELECTION
    for cov in FUNCTION STATEMENT; do
        for type in ORIGINAL ABSOLUTE RELATIVE; do
            for f in $(find -name "${tech}-*-${cov}-${type}-*" | grep OMITTED | grep false); do
                # Get the same corresponding OMITTED and GIVEN files
                omittedfile=${f}
                givenfile=$(echo ${f} | sed 's;OMITTED;GIVEN;')

                # See if either of them have not fixed DTs
                omitted=$(grep "DTs not fixed are:" ${omittedfile})
                given=$(grep "DTs not fixed are:" ${givenfile})

                # Case A
                if [[ ${omitted} == "" && ${given} == "" ]]; then
                    caseA=$((caseA + 1))
                fi
                # Case B
                if [[ ${omitted} != "" && ${given} != "" ]]; then
                    caseB=$((caseB + 1))
                fi
                # Case C
                if [[ ${omitted} != "" && ${given} == "" ]]; then
                    caseC=$((caseC + 1))
                fi
                # Case D
                if [[ ${omitted} == "" && ${given} != "" ]]; then
                    caseD=$((caseD + 1))
                fi
            done
        done
    done
    total=$(echo "${caseA} + ${caseB} + ${caseC} + ${caseD}" | bc -l)
    echo "\Def{${testtype}_caseA_sele}{$(echo "${caseA} / ${total} * 100" | bc -l | xargs printf "%.0f")\%}"
    echo "\Def{${testtype}_caseB_sele}{$(echo "${caseB} / ${total} * 100" | bc -l | xargs printf "%.0f")\%}"
    echo "\Def{${testtype}_caseC_sele}{$(echo "${caseC} / ${total} * 100" | bc -l | xargs printf "%.0f")\%}"
    echo "\Def{${testtype}_caseD_sele}{$(echo "${caseD} / ${total} * 100" | bc -l | xargs printf "%.0f")\%}"

    # PARALLELIZATION
    caseA=0
    caseB=0
    caseC=0
    caseD=0
    tech=PARALLELIZATION
    for l in $(ls | grep "_output$"); do
        # Get the first revision
        firstrev=$(find ${l} -name "*-lifetime" | xargs ls | sort | head -1)
        firstsha=$(echo ${firstrev} | rev | cut -d'-' -f1 | rev | cut -c 1-8)

        for type in ORIGINAL TIME; do
            for f in $(find -name "${tech}-*-${type}-*" | grep OMITTED | grep false | grep "${firstsha}"); do
                # Get the same corresponding OMITTED and GIVEN files
                omittedfile=${f}
                givenfile=$(echo ${f} | sed 's;OMITTED;GIVEN;')

                # See if either of them have not fixed DTs
                omitted=$(grep "DTs not fixed are:" ${omittedfile})
                given=$(grep "DTs not fixed are:" ${givenfile})

                # Case A
                if [[ ${omitted} == "" && ${given} == "" ]]; then
                    caseA=$((caseA + 1))
                fi
                # Case B
                if [[ ${omitted} != "" && ${given} != "" ]]; then
                    caseB=$((caseB + 1))
                fi
                # Case C
                if [[ ${omitted} != "" && ${given} == "" ]]; then
                    caseC=$((caseC + 1))
                fi
                # Case D
                if [[ ${omitted} == "" && ${given} != "" ]]; then
                    caseD=$((caseD + 1))
                fi
            done
        done
    done
    total=$(echo "${caseA} + ${caseB} + ${caseC} + ${caseD}" | bc -l)
    echo "\Def{${testtype}_caseA_para}{$(echo "${caseA} / ${total} * 100" | bc -l | xargs printf "%.0f")\%}"
    echo "\Def{${testtype}_caseB_para}{$(echo "${caseB} / ${total} * 100" | bc -l | xargs printf "%.0f")\%}"
    echo "\Def{${testtype}_caseC_para}{$(echo "${caseC} / ${total} * 100" | bc -l | xargs printf "%.0f")\%}"
    echo "\Def{${testtype}_caseD_para}{$(echo "${caseD} / ${total} * 100" | bc -l | xargs printf "%.0f")\%}"
)
done
