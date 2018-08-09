#!/usr/bin/env bash

# Runs commands for "Instructions to setup a subject for test prioritization" section.

set -e

IGNORE_TESTS_LIST="$DT_SCRIPTS/${SUBJ_NAME}-results/${SUBJ_NAME}-ignore-order"
TEST_ORDER="${SUBJ_NAME}-orig-order"

if [[ ! -e "$NEW_DT_SUBJ/$TEST_ORDER" ]]; then
    echo "[INFO] Copying test order from $DT_SUBJ/$TEST_ORDER to $NEW_DT_SUBJ/$TEST_ORDER"

    cp "$DT_SUBJ/$TEST_ORDER" "$NEW_DT_SUBJ/$TEST_ORDER"

    # Remove the tests we're ignoring
    echo "[INFO] Removing ignored tests (from $IGNORE_TESTS_LIST)"
    temp="$(mktemp)"
    grep -Fvf "$IGNORE_TESTS_LIST" "$NEW_DT_SUBJ/$TEST_ORDER" > "$temp"
    mv "$temp" "$NEW_DT_SUBJ/$TEST_ORDER"
    rm "$temp"

    echo "[INFO] Removing missing tests."
    bash "$DT_SCRIPTS/remove-missing-tests.sh" "$NEW_DT_SUBJ/$TEST_ORDER" new
fi

