#!/usr/bin/env bash

# Usage: bash get-test-order.sh <old|new>
# EITHER:
# - Run the setup script before running this script
# OR:
# - Be in the same directory as the pom.xml before running this script.
# Only run for human-written tests

version=$1

if [[ "$version" == "new" ]]; then
    TESTS=$NEW_DT_TESTS
    CLASS=$NEW_DT_CLASS
    LIBS=$NEW_DT_LIBS
    SUBJ=$NEW_DT_SUBJ
    SUBJ_SRC=$NEW_DT_SUBJ_SRC
else
    TESTS=$DT_TESTS
    CLASS=$DT_CLASS
    LIBS=$DT_LIBS
    SUBJ=$DT_SUBJ
    SUBJ_SRC=$DT_SUBJ_SRC
fi


if [[ ! -z "$SUBJ_SRC" ]]; then
    cd "$SUBJ_SRC"
fi

output_file_name="test-order"
if [[ ! -z "$SUBJ_NAME" ]]; then
    output_file_name="$SUBJ/$SUBJ_NAME-orig-order"
fi

# Run the tests (assume has already been compiled)
/home/awshi2/apache-maven/bin/mvn test -Dmavanagaiata.skip=true -Drat.skip=true -Ddependency-check.skip=true -Dcheckstyle.skip=true -Dmaven.javadoc.skip=true -Dmaven-source.skip=true |& tee "test-log.txt"

java -cp $DT_TOOLS: edu.washington.cs.dt.impact.tools.GetOriginalOrder $output_file_name "target/" "test-log.txt"

# tests=($(grep -h "Running .*" "test-log.txt" | sed -E "s/.*Running (.*)/\1/g"))
# (
#     for test_name in "${tests[@]}"; do
#         test_case_names=($(xmllint --xpath "//testsuite/testcase/@name" "target/surefire-reports/TEST-$test_name.xml" | sed -E "s/name=\"([^\"]*)\"/\1/g"))
#         test_class_names=($(xmllint --xpath "//testsuite/testcase/@classname" "target/surefire-reports/TEST-$test_name.xml" | sed -E "s/classname=\"([^\"]*)\"/\1/g"))

#         n="${#test_class_names[@]}"

#         for (( i=0; i<"$n"; i++ )); do
#             test_case_name="${test_case_names[$i]}"
#             test_class_name="${test_class_names[$i]}"

#             fqn="$test_class_name.$test_case_name"

#             echo "$fqn"
#         done
#     done
# ) > "$output_file_name"

if [[ ! -z "$SUBJ_NAME" ]]; then
    TEST_ORDER="$output_file_name"
    IGNORE_TESTS_LIST="$DT_SCRIPTS/${SUBJ_NAME}-results/${SUBJ_NAME}-ignore-order"

    if [[ -e "$IGNORE_TESTS_LIST" ]]; then
        temp=$(mktemp)
        grep -Fvf "$IGNORE_TESTS_LIST" $TEST_ORDER > $temp
        mv $temp $TEST_ORDER
    fi

    java -cp $DT_TOOLS: edu.washington.cs.dt.impact.tools.detectors.FailingTestDetector --classpath "$CLASS:$TESTS:$LIBS:$DT_TOOLS:" --tests "$TEST_ORDER" --output "$IGNORE_TESTS_LIST"

    if [[ -e "$IGNORE_TESTS_LIST" ]]; then
        temp=$(mktemp)
        grep -Fvf "$IGNORE_TESTS_LIST" $TEST_ORDER > $temp
        mv $temp $TEST_ORDER
    fi
fi

