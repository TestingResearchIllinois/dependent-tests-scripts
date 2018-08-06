#!/usr/bin/env bash

# Automates the "Instructions for compiling subjects" section.

bash "$DT_SCRIPTS/compile-module.sh" "$DT_CLASS:$DT_TESTS:$DT_LIBS" "$DT_SUBJ_SRC" "$DT_SUBJ_ROOT"
bash "$DT_SCRIPTS/compile-module.sh" "$NEW_DT_CLASS:$NEW_DT_TESTS:$NEW_DT_LIBS" "$NEW_DT_SUBJ_SRC" "$NEW_DT_SUBJ_ROOT"

