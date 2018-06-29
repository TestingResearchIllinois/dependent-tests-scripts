#!/usr/bin/env bash

# Usage: bash generate-cutoff.sh directory/containing/result/directories
# Note: Environment variables should be set up first

cutoff=$(java -cp $DT_TOOLS: edu.washington.cs.dt.impact.tools.PrecomputedLifetime --start-date "$SUBJ_START_DATE" --paths "$1" | tail -1)

echo "export SUBJ_CUTOFF=$cutofff" >> "$DT_SCRIPTS/${SUBJ_NAME}-results/setup-${SUBJ_NAME}.sh"

