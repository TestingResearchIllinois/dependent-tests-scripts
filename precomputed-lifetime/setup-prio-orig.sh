#!/usr/bin/env bash

# Runs commands for "Instructions to setup a subject for test prioritization" section.

set -e

cd $NEW_DT_SUBJ

TEST_ORDER="${SUBJ_NAME}-new-order"

if [[ ! -e "$TEST_ORDER" ]]; then
    echo "[DEBUG] Finding human written tests in new subject."
    bash "$DT_SCRIPTS/find-test-list.sh" new orig
fi

