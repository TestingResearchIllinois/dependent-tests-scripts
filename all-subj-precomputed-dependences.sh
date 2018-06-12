# Usage: all-subj-precomputed-dependences.sh $DT_ROOT

source ./constants.sh

#!/bin/bash

DT_ROOT=$1
# Make sure DT_TOOLS gets passed to scripts.
export DT_TOOLS=$DT_ROOT/impact-tools/*
source ./subj-constants.sh $DT_ROOT

startTime=`date`

# ======================================================

echo "[INFO] Running prioritization-runner script to generate precomputed dependences"
rm -rf $DT_ROOT/${prioDir}
mkdir $DT_ROOT/${prioDir}

index=0
count=${#expName[@]}

while [ "$index" -lt "$count" ]; do
  SUBJ_NAME=${expName[$index]}
  SUBJ_NAME_FORMAL=${expNameFormal[$index]}

  DT_SUBJ=${expDirectories[$index]}
  CLASSPATH=${expCP[$index]}

  echo -e "[INFO] Starting experiment: $SUBJ_NAME"
  bash ./subj-prio.sh $DT_SUBJ $DT_ROOT $SUBJ_NAME "$SUBJ_NAME_FORMAL" $DT_SUBJ true true false $CLASSPATH

  let "index++"
done

# ======================================================

echo "[INFO] Running parallelization-runner script to generate precomputed dependences"
rm -rf $DT_ROOT/${paraDir}
mkdir $DT_ROOT/${paraDir}

index=0
while [ "$index" -lt "$count" ]; do
  SUBJ_NAME=${expName[$index]}
  SUBJ_NAME_FORMAL=${expNameFormal[$index]}

  DT_SUBJ=${expDirectories[$index]}
  CLASSPATH=${expCP[$index]}

  echo -e "[INFO] Starting experiment: $SUBJ_NAME"
  bash ./subj-para.sh $DT_SUBJ $DT_ROOT $SUBJ_NAME "$SUBJ_NAME_FORMAL" $DT_SUBJ true true false $CLASSPATH

  let "index++"
done

# ======================================================

echo "[INFO] Script has finished running."

echo "[INFO] Start time was ${startTime}"

endTime=`date`
echo "[INFO] End time is ${endTime}"

