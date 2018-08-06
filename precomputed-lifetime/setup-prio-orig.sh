#!/usr/bin/env bash

# Runs commands for "Instructions to setup a subject for test prioritization" section.

set -e

TEST_ORDER="${SUBJ_NAME}-orig-order"

if [[ ! -e "$NEW_DT_SUBJ/$TEST_ORDER" ]]; then
    echo "[INFO] Copying test order from $DT_SUBJ/$TEST_ORDER to $NEW_DT_SUBJ/$TEST_ORDER"

    cp "$DT_SUBJ/$TEST_ORDER" "$NEW_DT_SUBJ/$TEST_ORDER"
fi

