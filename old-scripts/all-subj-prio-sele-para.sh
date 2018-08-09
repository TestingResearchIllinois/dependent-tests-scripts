# Usage: all-subj-prio-sele-para.sh $DT_ROOT "$DT_TOOLS" $ORIG_MIN_DTS $AUTO_MIN_DTS [prio|sele|para]

source ./constants.sh

#!/bin/bash

DT_ROOT=$1
# Make sure DT_TOOLS gets passed to scripts.
export DT_TOOLS=$2
ORIG_MIN_DTS=$3
AUTO_MIN_DTS=$4
STAGE=$5

source ./subj-constants.sh $DT_ROOT

startTime=`date`
count=${#expName[@]}

# ======================================================

if [[ "$STAGE" == "prio" ]] || [[ -z "$STAGE" ]]; then
    echo "[INFO] Running prioritization-runner script"
    rm -rf $DT_ROOT/${prioDir}
    mkdir $DT_ROOT/${prioDir}
    
    index=0
    while [ "$index" -lt "$count" ]; do
      SUBJ_NAME=${expName[$index]}
      SUBJ_NAME_FORMAL=${expNameFormal[$index]}
    
      DT_SUBJ=${expDirectories[$index]}
      NEW_DT_SUBJ=${nextExpDirectories[$index]}
      CLASSPATH=${nextExpCP[$index]}
    
      echo -e "[INFO] Starting experiment: $DT_SUBJ"
      bash ./subj-prio.sh $DT_SUBJ $DT_ROOT $SUBJ_NAME "$SUBJ_NAME_FORMAL" $NEW_DT_SUBJ true false true $CLASSPATH
    
      let "index++"
    done
    
    java -cp $DT_TOOLS: edu.washington.cs.dt.impact.figure.generator.EnhancedResultsFigureGenerator -directory $DT_ROOT/$prioDir -outputDirectory $DT_ROOT/$prioDir -allowNegatives
fi

# ======================================================

if [[ "$STAGE" == "sele" ]] || [[ -z "$STAGE" ]]; then
    echo "[INFO] Running selection-runner script"
    rm -rf $DT_ROOT/${seleDir}
    mkdir $DT_ROOT/${seleDir}
    
    index=0
    while [ "$index" -lt "$count" ]; do
      SUBJ_NAME=${expName[$index]}
      SUBJ_NAME_FORMAL=${expNameFormal[$index]}
    
      DT_SUBJ=${expDirectories[$index]}
      NEW_DT_SUBJ=${nextExpDirectories[$index]}
      CLASSPATH=${nextExpCP[$index]}
    
      echo -e "[INFO] Starting experiment: $DT_SUBJ"
      bash ./subj-sele.sh $DT_SUBJ $DT_ROOT $SUBJ_NAME "$SUBJ_NAME_FORMAL" $NEW_DT_SUBJ true true $CLASSPATH
    
      let "index++"
    done
    
    java -cp $DT_TOOLS: edu.washington.cs.dt.impact.figure.generator.EnhancedResultsFigureGenerator -directory $DT_ROOT/$seleDir -outputDirectory $DT_ROOT/$seleDir -allowNegatives
fi

# ======================================================

if [[ "$STAGE" == "para" ]] || [[ -z "$STAGE" ]]; then
    echo "[INFO] Running parallelization-runner script"
    rm -rf $DT_ROOT/${paraDir}
    mkdir $DT_ROOT/${paraDir}
    
    index=0
    while [ "$index" -lt "$count" ]; do
      SUBJ_NAME=${expName[$index]}
      SUBJ_NAME_FORMAL=${expNameFormal[$index]}
    
      DT_SUBJ=${expDirectories[$index]}
      NEW_DT_SUBJ=${nextExpDirectories[$index]}
      CLASSPATH=${nextExpCP[$index]}
    
      echo -e "[INFO] Starting experiment: $DT_SUBJ"
      bash ./subj-para.sh $DT_SUBJ $DT_ROOT $SUBJ_NAME "$SUBJ_NAME_FORMAL" $NEW_DT_SUBJ true false true $CLASSPATH
    
      let "index++"
    done
    
    java -cp $DT_TOOLS: edu.washington.cs.dt.impact.figure.generator.EnhancedResultsFigureGenerator -directory $DT_ROOT/$paraDir -outputDirectory $DT_ROOT/$paraDir -allowNegatives
fi

# ======================================================

java -cp $DT_TOOLS: edu.washington.cs.dt.impact.figure.generator.NumDependentTestsFigureGenerator -priorDirectory $DT_ROOT/$prioDir -seleDirectory $DT_ROOT/$seleDir -paraDirectory $DT_ROOT/$paraDir -outputDirectory ./ -minBoundOrigDTFile $ORIG_MIN_DTS -minBoundAutoDTFile $AUTO_MIN_DTS

echo "[INFO] Script has finished running."

echo "[INFO] Start time was ${startTime}"

endTime=`date`
echo "[INFO] End time is ${endTime}"
