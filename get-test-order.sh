#!/usr/bin/env bash

# Usage: bash get-test-order.sh
# EITHER:
# - Run the setup script before running this script
# OR:
# - Be in the same directory as the pom.xml before running this script.

if [[ ! -z "$DT_SUBJ_SRC" ]]; then
    cd "$DT_SUBJ_SRC"
fi

output_file_name="test-order"
if [[ ! -z "$SUBJ_NAME" ]]; then
    output_file_name="$SUBJ_NAME-orig-order"
fi

if [[ ! -z "$DT_SUBJ_ROOT" ]]; then
    (
        cd $DT_SUBJ_ROOT
        mvn install -fn -DskipTests -Drat.skip=true
    )
else
    mvn install -fn -DskipTests -Drat.skip=true
fi

mvn test -Drat.skip=true |& tee "test-log.txt"

tests=($(grep -h "Running .*" "test-log.txt" | sed -E "s/.*Running (.*)/\1/g"))
(
    for test_name in "${tests[@]}"; do
        test_case_names=($(xmllint --xpath "//testsuite/testcase/@name" "target/surefire-reports/TEST-$test_name.xml" | sed -E "s/name=\"([^\"]*)\"/\1/g"))
        test_class_names=($(xmllint --xpath "//testsuite/testcase/@classname" "target/surefire-reports/TEST-$test_name.xml" | sed -E "s/classname=\"([^\"]*)\"/\1/g"))

        n="${#test_class_names[@]}"

        for (( i=0; i<"$n"; i++ )); do
            test_case_name="${test_case_names[$i]}"
            test_class_name="${test_class_names[$i]}"

            fqn="$test_class_name.$test_case_name"

            echo "$fqn"
        done
    done
) > "$output_file_name"

if [[ ! -z "$SUBJ_NAME" ]]; then
    TEST_ORDER="$output_file_name"
    IGNORE_TESTS_LIST="$DT_SCRIPTS/${SUBJ_NAME}-results/${SUBJ_NAME}-ignore-order"

    if [[ -e "$IGNORE_TESTS_LIST" ]]; then
        temp=$(mktemp)
        grep -Fvf "$IGNORE_TESTS_LIST" $TEST_ORDER > $temp
        mv $temp $TEST_ORDER
    fi

    java -cp $DT_TOOLS: edu.washington.cs.dt.impact.tools.detectors.FailingTestDetector --classpath "$DT_CLASS:$DT_TESTS:$DT_LIBS:" --tests "$TEST_ORDER" --output "$IGNORE_TESTS_LIST"

    if [[ -e "$IGNORE_TESTS_LIST" ]]; then
        temp=$(mktemp)
        grep -Fvf "$IGNORE_TESTS_LIST" $TEST_ORDER > $temp
        mv $temp $TEST_ORDER
    fi
fi

