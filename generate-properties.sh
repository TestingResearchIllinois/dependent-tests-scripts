#!/usr/bin/env bash

# Usage: bash generate-properties.sh SETUP_SCRIPT

# Run the setup script
CURRENT=$(pwd)

SCRIPT_DIR=$(dirname "$1")
SCRIPT_NAME=$(basename "$1")

echo "[INFO] Running setup script $SCRIPT_NAME in $SCRIPT_DIR"

cd $SCRIPT_DIR
. "$SCRIPT_NAME"

cd $CURRENT

java -cp "$DT_TOOLS:" edu.washington.cs.dt.impact.tools.SubjectPropertiesGenerator

