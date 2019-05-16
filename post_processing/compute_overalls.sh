#!/bin/bash

# LOC
echo "\Def{overall_srcloc}{$(grep "_srcloc" data/loc.tex | cut -d'{' -f3 | cut -d'}' -f1 | paste -sd+ | bc -l)}"
echo "\Def{overall_testloc}{$(grep "_testloc" data/loc.tex | cut -d'{' -f3 | cut -d'}' -f1 | paste -sd+ | bc -l)}"

# Tests
origtests=$(grep "_orig_numtests" data/results.tex | cut -d'{' -f3 | cut -d'}' -f1 | paste -sd+ | bc -l)
echo "\Def{overall_orig_numtests}{${origtests}}"
autotests=$(grep "_auto_numtests" data/results.tex | cut -d'{' -f3 | cut -d'}' -f1 | paste -sd+ | bc -l)
echo "\Def{overall_auto_numtests}{${autotests}}"

# DTs
origdts=$(grep "_orig_dts}" data/dts.tex | cut -d'{' -f3 | cut -d'}' -f1 | paste -sd+ | bc -l)
echo "\Def{overall_orig_dts}{${origdts}}"
echo "\Def{overall_orig_dtsperc}{$(echo "${origdts} / ${origtests} * 100" | bc -l | xargs printf "%.0f")\%}"

autodts=$(grep "_auto_dts}" data/dts.tex | cut -d'{' -f3 | cut -d'}' -f1 | paste -sd+ | bc -l)
echo "\Def{overall_auto_dts}{${autodts}}"
echo "\Def{overall_auto_dtsperc}{$(echo "${autodts} / ${autotests} * 100" | bc -l | xargs printf "%.0f")\%}"

# Revisions
echo "\Def{overall_orig_numrevs}{$(grep "_orig_numrevs}" data/results.tex | cut -d'{' -f3 | cut -d'}' -f1 | paste -sd+ | bc -l)}"

# Compute overall percentage dts per technique
for tech in prio sele para; do
    for testtype in orig auto; do
        techres=$(grep "_${testtype}_dts_${tech}}" data/dts.tex | cut -d'{' -f3 | cut -d'}' -f1 | paste -sd+ | bc -l)
        if [[ ${testtype} == orig ]]; then
            total=${origdts}
        else
            total=${autodts}
        fi
        if [[ ${total} == 0 ]]; then
            echo "\Def{overall_${testtype}_dtsperc_${tech}}{-}"
        else
            echo "\Def{overall_${testtype}_dtsperc_${tech}}{$(echo "${techres} / ${total} * 100" | bc -l | xargs printf "%.0f")\%}"
        fi
    done
done

# Compute some percentages per technique
function breakdowns() {
    testtype=$1
    total=$2

    tech=prio
    for cov in func stat; do
        for type in abso rela; do
            macrokey=${testtype}_dts_${tech}_${cov}_${type}
            echo "\Def{${macrokey}_perc}{$(echo "$(echo "$(grep ${macrokey} data/breakdown.tex | cut -d'{' -f3 | cut -d'}' -f1) / ${total} * 100" | bc -l | xargs printf "%.0f")")\%}"
        done
    done

    tech=sele
    for cov in func stat; do
        for type in orig abso rela; do
            macrokey=${testtype}_dts_${tech}_${cov}_${type}
            echo "\Def{${macrokey}_perc}{$(echo "$(echo "$(grep ${macrokey} data/breakdown.tex | cut -d'{' -f3 | cut -d'}' -f1) / ${total} * 100" | bc -l | xargs printf "%.0f")")\%}"
        done
    done

    tech=para
    for type in orig time; do
        macrokey=${testtype}_dts_${tech}_${type}
        echo "\Def{${macrokey}_perc}{$(echo "$(echo "$(grep ${macrokey} data/breakdown.tex | cut -d'{' -f3 | cut -d'}' -f1) / ${total} * 100" | bc -l | xargs printf "%.0f")")\%}"
    done
}

breakdowns orig ${origdts}
breakdowns auto ${autodts}

# Compute some difference in dts between given and regular algorithms
for proj in $(cat projects.txt); do
    for testtype in orig auto; do
        for tech in prio sele para; do
            techres=$(grep "${proj}_${testtype}_dts_${tech}}" data/dts.tex | cut -d'{' -f3 | cut -d'}' -f1)
            giventechres=$(grep "${proj}_${testtype}_dtsgiven_${tech}}" data/givenresults.tex | cut -d'{' -f3 | cut -d'}' -f1)
            if [[ ${techres} == 0 ]]; then
                echo "\Def{${proj}_${testtype}_dtsdiff_${tech}}{-}"
            else
                echo "\Def{${proj}_${testtype}_dtsdiff_${tech}}{$(echo "((${techres} - ${giventechres}) * 100) / ${techres}" | bc -l | xargs printf "%.0f")\%}"
            fi
        done
    done
done

# Compute some difference in dt failures between given and regular algorithms
supertotaldtfailures=0
supertotaldtfailuresgiven=0
for testtype in orig auto; do
    testtypedtfailures=0
    testtypedtfailuresgiven=0
    for tech in prio sele para; do
        totaldtfailures=0
        totaldtfailuresgiven=0
        for proj in $(cat projects.txt); do
            techres=$(grep "${proj}_${testtype}_dtfailures_${tech}}" data/results.tex | cut -d'{' -f3 | cut -d'}' -f1)
            giventechres=$(grep "${proj}_${testtype}_dtfailuresgiven_${tech}}" data/givenresults.tex | cut -d'{' -f3 | cut -d'}' -f1)
            if [[ ${techres} == 0 ]]; then
                # Check if there actually are dts for this project
                if [[ $(grep "${proj}_${testtype}_dts}" data/dts.tex| cut -d'{' -f3 | cut -d'}' -f1) != 0 ]]; then
                    # In case of the weird case where more failures due to given, but is still 0
                    if [[ ${giventechres} != 0 ]]; then
                        echo "\Def{${proj}_${testtype}_dtfailuresdiff_${tech}}{-100\%*}"
                    else
                        echo "\Def{${proj}_${testtype}_dtfailuresdiff_${tech}}{-}"
                    fi
                else
                    echo "\Def{${proj}_${testtype}_dtfailuresdiff_${tech}}{n/a}"
                fi
            else
                echo "\Def{${proj}_${testtype}_dtfailuresdiff_${tech}}{$(echo "((${techres} - ${giventechres}) * 100) / ${techres}" | bc -l | xargs printf "%.0f")\%}"
            fi
            totaldtfailures=$((totaldtfailures + techres))
            totaldtfailuresgiven=$((totaldtfailuresgiven + giventechres))
        done
        echo "\Def{overall_${testtype}_dtfailuresdiff_${tech}}{$(echo "((${totaldtfailures} - ${totaldtfailuresgiven}) * 100) / ${totaldtfailures}" | bc -l | xargs printf "%.0f")\%}"
        testtypedtfailures=$((testtypedtfailures + totaldtfailures))
        testtypedtfailuresgiven=$((testtypedtfailuresgiven + totaldtfailuresgiven))
        supertotaldtfailures=$((supertotaldtfailures + totaldtfailures))
        supertotaldtfailuresgiven=$((supertotaldtfailuresgiven + totaldtfailuresgiven))
    done
    echo "\Def{overall_${testtype}_dtfailuresdiff}{$(echo "((${testtypedtfailures} - ${testtypedtfailuresgiven}) * 100) / ${testtypedtfailures}" | bc -l | xargs printf "%.0f")\%}"
done
echo "\Def{overall_dtfailuresdiff}{$(echo "((${supertotaldtfailures} - ${supertotaldtfailuresgiven}) * 100) / ${supertotaldtfailures}" | bc -l | xargs printf "%.0f")\%}"

# Compute some difference in test times between given and regular algorithms, but only selection and parallelization
supertotaltimes=0
supertotaltimesgiven=0
for testtype in orig auto; do
    for tech in sele para; do
        totaltimes=0
        totaltimesgiven=0
        for proj in $(cat projects.txt); do
            # For para, need to observe if the technique detects any DTs, and if not then should just skip
            if [[ ${tech} == "para" && $(grep "${proj}_${testtype}_dts_${tech}}" data/dts.tex | cut -d'{' -f3 | cut -d'}' -f1) == 0 ]]; then
                echo "\Def{${proj}_${testtype}_testtimediff_${tech}}{n/e}"
                continue
            fi
            # For sele, need to observe if either para or prio of it had any DTs, and skip if both are 0
            if [[ ${tech} == "sele" ]]; then
                para=$(grep "${proj}_${testtype}_dts_para}" data/dts.tex | cut -d'{' -f3 | cut -d'}' -f1)
                prio=$(grep "${proj}_${testtype}_dts_prio}" data/dts.tex | cut -d'{' -f3 | cut -d'}' -f1)
                if [[ ${para} == 0 && ${prio} == 0 ]]; then
                    echo "\Def{${proj}_${testtype}_testtimediff_${tech}}{n/e}"
                    continue
                fi
            fi
            techres=$(grep "${proj}_${testtype}_testtime_${tech}}" data/times.tex | cut -d'{' -f3 | cut -d'}' -f1)
            giventechres=$(grep "${proj}_${testtype}_testtimegiven_${tech}}" data/times.tex | cut -d'{' -f3 | cut -d'}' -f1)
            if [[ ${techres} == 0 ]]; then
                echo "\Def{${proj}_${testtype}_testtimediff_${tech}}{-}"
            else
                echo "\Def{${proj}_${testtype}_testtimediff_${tech}}{$(echo "((${giventechres} - ${techres}) * 100) / ${techres}" | bc -l | xargs printf "%.0f")\%}"
            fi
            totaltimes=$((totaltimes + techres))
            totaltimesgiven=$((totaltimesgiven + giventechres))
        done
        echo "\Def{overall_${testtype}_testtimediff_${tech}}{$(echo "((${totaltimesgiven} - ${totaltimes}) * 100) / ${totaltimes}" | bc -l | xargs printf "%.0f")\%}"
        supertotaltimes=$((supertotaltimes + totaltimes))
        supertotaltimesgiven=$((supertotaltimesgiven + totaltimesgiven))
    done
done
echo "\Def{overall_testtimediff}{$(echo "((${supertotaltimesgiven} - ${supertotaltimes}) * 100) / ${supertotaltimes}" | bc -l | xargs printf "%.0f")\%}"

# Compute some difference in test times between given and regular algorithms, but with the execSubsuite rerun strategy
supertotaltimes=0
supertotaltimesgiven=0
for testtype in orig auto; do
    for tech in prio sele para; do
        totaltimes=0
        totaltimesgiven=0
        for proj in $(cat projects.txt); do
            # Need to observe if the technique detects any DTs, and if not then should just skip
            if [[ ${tech} == "prio" || ${tech} == "para" ]]; then
                if [[ $(grep "${proj}_${testtype}_dts_${tech}}" data/dts.tex | cut -d'{' -f3 | cut -d'}' -f1) == 0 ]]; then
                    echo "\Def{${proj}_${testtype}_testtimererunsdiff_${tech}}{n/e}"
                    continue
                fi
            fi
            # For sele, need to observe if either para or prio of it had any DTs, and skip if both are 0
            if [[ ${tech} == "sele" ]]; then
                para=$(grep "${proj}_${testtype}_dts_para}" data/dts.tex | cut -d'{' -f3 | cut -d'}' -f1)
                prio=$(grep "${proj}_${testtype}_dts_prio}" data/dts.tex | cut -d'{' -f3 | cut -d'}' -f1)
                if [[ ${para} == 0 && ${prio} == 0 ]]; then
                    echo "\Def{${proj}_${testtype}_testtimererunsdiff_${tech}}{n/e}"
                    continue
                fi
            fi
            techres=$(grep "${proj}_${testtype}_testtimereruns_${tech}}" data/execsubsuitetimes.tex | cut -d'{' -f3 | cut -d'}' -f1)
            giventechres=$(grep "${proj}_${testtype}_testtimererunsgiven_${tech}}" data/execsubsuitetimes.tex | cut -d'{' -f3 | cut -d'}' -f1)
            if [[ ${techres} == 0 ]]; then
                echo "\Def{${proj}_${testtype}_testtimererunsdiff_${tech}}{-}"
            else
                echo "\Def{${proj}_${testtype}_testtimererunsdiff_${tech}}{$(echo "((${techres} - ${giventechres}) * 100) / ${techres}" | bc -l | xargs printf "%.0f")\%}"
            fi
            totaltimes=$((totaltimes + techres))
            totaltimesgiven=$((totaltimesgiven + giventechres))
        done
        echo "\Def{overall_${testtype}_testtimererunsdiff_${tech}}{$(echo "((${totaltimes} - ${totaltimesgiven}) * 100) / ${totaltimes}" | bc -l | xargs printf "%.0f")\%}"
        supertotaltimes=$((supertotaltimes + totaltimes))
        supertotaltimesgiven=$((supertotaltimesgiven + totaltimesgiven))
    done
done
echo "\Def{overall_testtimererunsdiff}{$(echo "((${supertotaltimes} - ${supertotaltimesgiven}) * 100) / ${supertotaltimes}" | bc -l | xargs printf "%.0f")\%}"

# Compute some overalls concerning configurations with dts
totalconfs=$(grep "_totalconfs_" data/results.tex | cut -d'{' -f3 | cut -d'}' -f1 | paste -sd+ | bc -l)
confswithdts=$(grep "_confswithdts_" data/results.tex | cut -d'{' -f3 | cut -d'}' -f1 | paste -sd+ | bc -l)
echo "\Def{overall_confswithdtsperc}{$(echo "${confswithdts} / ${totalconfs} * 100" | bc -l | xargs printf "%.0f")\%}"

totalconfsgiven=$(grep "_totalconfsgiven_" data/givenresults.tex | cut -d'{' -f3 | cut -d'}' -f1 | paste -sd+ | bc -l)
confswithdtsgiven=$(grep "_confswithdtsgiven_" data/givenresults.tex | cut -d'{' -f3 | cut -d'}' -f1 | paste -sd+ | bc -l)
echo "\Def{overall_confswithdtsgivenperc}{$(echo "${confswithdtsgiven} / ${totalconfsgiven} * 100" | bc -l | xargs printf "%.0f")\%}"

# Compute the same concerning configurations but per test type
totalconfs=$(grep "_orig_totalconfs_" data/results.tex | cut -d'{' -f3 | cut -d'}' -f1 | paste -sd+ | bc -l)
confswithdts=$(grep "_orig_confswithdts_" data/results.tex | cut -d'{' -f3 | cut -d'}' -f1 | paste -sd+ | bc -l)
echo "\Def{overall_orig_confswithdtsperc}{$(echo "${confswithdts} / ${totalconfs} * 100" | bc -l | xargs printf "%.0f")\%}"

totalconfs=$(grep "_auto_totalconfs_" data/results.tex | cut -d'{' -f3 | cut -d'}' -f1 | paste -sd+ | bc -l)
confswithdts=$(grep "_orig_confswithdts_" data/results.tex | cut -d'{' -f3 | cut -d'}' -f1 | paste -sd+ | bc -l)
echo "\Def{overall_auto_confswithdtsperc}{$(echo "${confswithdts} / ${totalconfs} * 100" | bc -l | xargs printf "%.0f")\%}"
