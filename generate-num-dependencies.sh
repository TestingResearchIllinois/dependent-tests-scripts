#!/bin/bash
# Make sure we've found the human written tests in the new subject.

set -e

cd $NEW_DT_SUBJ
echo "[DEBUG] Finding human written tests in the new subject."
bash "$DT_SCRIPTS/get-test-order.sh" new

# Make sure the env-files exist
if [ ! -e $DT_SUBJ/$SUBJ_NAME-env-files ]; then
    touch $DT_SUBJ/$SUBJ_NAME-env-files
fi

if [ ! -e $NEW_DT_SUBJ/$SUBJ_NAME-env-files ]; then
    touch $NEW_DT_SUBJ/$SUBJ_NAME-env-files
fi

cd $DT_SCRIPTS
echo "[DEBUG] Running one-subj.sh"
#bash $DT_SCRIPTS/one-subj.sh $DT_SUBJ $DT_ROOT $SUBJ_NAME "$SUBJ_NAME_FORMAL" \
  "$DT_TOOLS" "$DT_LIBS" $DT_CLASS $DT_RANDOOP $DT_TESTS false false $NEW_DT_SUBJ $ORIG_MIN_DTS $AUTO_MIN_DTS

