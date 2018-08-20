#!/usr/bin/env bash

# Usage: bash find-test-list.sh <old|new> <orig|auto>
# $1 - old or new (default old). Which version to use.
# $2 - orig or auto (default orig). Which tests to look at.

version=$1
testType=$2

TEST_ORDER="$(pwd)/${SUBJ_NAME}-${testType}-order"
IGNORE_TESTS_LIST="$DT_SCRIPTS/${SUBJ_NAME}-results/${SUBJ_NAME}-ignore-order"

TESTS=$DT_TESTS
CLASS=$DT_CLASS
LIBS=$DT_LIBS

if [[ "$testType" == "auto" ]]; then
    if [[ "$version" == "new" ]]; then
        TESTS=$NEW_DT_RANDOOP
    else
        TESTS=$DT_RANDOOP
    fi
else
    if [[ "$version" == "new" ]]; then
        TESTS=$NEW_DT_TESTS
    fi
fi

if [[ "$version" == "new" ]]; then
    LIBS=$NEW_DT_LIBS
    CLASS=$NEW_DT_CLASS
fi

java -cp $DT_TOOLS:$LIBS:$CLASS:$TESTS: edu.washington.cs.dt.tools.UnitTestFinder --pathOrJarFile $TESTS --junit3and4=true

if [[ "$testType" == "auto" ]]; then
    grep -i "randoop" allunittests.txt > $TEST_ORDER
else
    grep -vi "randoop" allunittests.txt > $TEST_ORDER
fi

if [[ -e "$IGNORE_TESTS_LIST" ]]; then
    temp=$(mktemp)
    grep -Fvf "$IGNORE_TESTS_LIST" $TEST_ORDER > $temp
    mv $temp $TEST_ORDER
fi

cd $DT_SUBJ_SRC
java -cp $DT_TOOLS: edu.washington.cs.dt.impact.tools.detectors.FailingTestDetector --classpath "$DT_CLASS:$DT_TESTS:$DT_LIBS:" --tests "$TEST_ORDER" --output "$IGNORE_TESTS_LIST"
cd $DT_SUBJ

if [[ -e "$IGNORE_TESTS_LIST" ]]; then
    temp=$(mktemp)
    grep -Fvf "$IGNORE_TESTS_LIST" $TEST_ORDER > $temp
    mv $temp $TEST_ORDER
fi

