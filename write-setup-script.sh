#!/usr/bin/env bash

# Usage: bash write-setup-script.sh [OUTPUT_FILENAME]
# Should have already set the environment variables for the subject BEFORE running this script
# If OUTPUT_FILENAME is not supplied, will use $DT_SCRIPTS/${SUBJ_NAME}-results/setup-$SUBJ_NAME.sh if those variables have been defined, and
# simply setup.sh if not.

if [[ ! -z "$DT_SCRIPTS" ]] && [[ ! -z "$SUBJ_NAME" ]]; then
    OUTPUT_FILENAME="$DT_SCRIPTS/${SUBJ_NAME}-results/setup-$SUBJ_NAME.sh"
else
    OUTPUT_FILENAME="setup.sh"
fi

if [[ ! -z "$1" ]]; then
    OUTPUT_FILENAME="$1"
fi

echo "export DT_ROOT=$DT_ROOT" | tee "$OUTPUT_FILENAME"
(
    echo "export DT_SUBJ_ROOT=$DT_SUBJ_ROOT"
    echo "export DT_SUBJ=$DT_SUBJ"
    echo "export DT_SUBJ_SRC=$DT_SUBJ_SRC"
    echo "export DT_CLASS=$DT_CLASS"
    echo "export DT_TESTS=$DT_TESTS"
    echo "export DT_TEST_SRC=$DT_TEST_SRC"
    echo "export NEW_DT_SUBJ_ROOT=$NEW_DT_SUBJ_ROOT"
    echo "export NEW_DT_SUBJ=$NEW_DT_SUBJ"
    echo "export NEW_DT_SUBJ_SRC=$NEW_DT_SUBJ_SRC"
    echo "export NEW_DT_CLASS=$NEW_DT_CLASS"
    echo "export NEW_DT_TESTS=$NEW_DT_TESTS"
    echo "export NEW_DT_TEST_SRC=$NEW_DT_TEST_SRC"
    echo "export SUBJ_NAME=$SUBJ_NAME"
    echo "export SUBJ_NAME_FORMAL=$SUBJ_NAME_FORMAL"
    echo ". $DT_ROOT/scripts/setup-vars.sh"
) | sed -E "s|$DT_ROOT|\$DT_ROOT|g" | tee -a "$OUTPUT_FILENAME"

