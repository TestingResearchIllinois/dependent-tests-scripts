# Usage: one-subj-un-enhanced-results.sh $DT_ROOT "$DT_TOOLS" $ORIG_MIN_DTS $AUTO_MIN_DTS $SUBJ_NAME $SUBJ_NAME_FORMAL $DT_SUBJ $NEW_DT_SUBJ $NEW_DT_CLASS $NEW_DT_TESTS "$NEW_DT_LIBS" $NEW_DT_RANDOOP

source ./constants.sh

#!/bin/bash

DT_ROOT=$1
# Make sure DT_TOOLS gets passed to scripts.
export DT_TOOLS=$2
ORIG_MIN_DTS=$3
AUTO_MIN_DTS=$4

source ./subj-constants.sh $DT_ROOT

SUBJ_NAME=$5
SUBJ_NAME_FORMAL=$6

DT_SUBJ=$7
NEW_DT_SUBJ=$8
CLASSPATH=$9:${10}:"${11}":${12}:

startTime=`date`

# ======================================================

echo "[INFO] Running prioritization-runner script"
rm -rf $DT_ROOT/${prioDir}
mkdir $DT_ROOT/${prioDir}

echo -e "[INFO] Starting experiment: $DT_SUBJ"
bash ./subj-prio.sh $DT_SUBJ $DT_ROOT $SUBJ_NAME "$SUBJ_NAME_FORMAL" $NEW_DT_SUBJ true false true "$CLASSPATH"

java -cp $DT_TOOLS: edu.washington.cs.dt.impact.figure.generator.EnhancedResultsFigureGenerator -directory $DT_ROOT/$prioDir -outputDirectory $DT_ROOT/$prioDir -allowNegatives

# ======================================================

echo "[INFO] Running selection-runner script"
rm -rf $DT_ROOT/${seleDir}
mkdir $DT_ROOT/${seleDir}

echo -e "[INFO] Starting experiment: $DT_SUBJ"
bash ./subj-sele.sh $DT_SUBJ $DT_ROOT $SUBJ_NAME "$SUBJ_NAME_FORMAL" $NEW_DT_SUBJ true true "$CLASSPATH"

java -cp $DT_TOOLS: edu.washington.cs.dt.impact.figure.generator.EnhancedResultsFigureGenerator -directory $DT_ROOT/$seleDir -outputDirectory $DT_ROOT/$seleDir -allowNegatives

# ======================================================

echo "[INFO] Running parallelization-runner script"
rm -rf $DT_ROOT/${paraDir}
mkdir $DT_ROOT/${paraDir}

echo -e "[INFO] Starting experiment: $DT_SUBJ"
bash ./subj-para.sh $DT_SUBJ $DT_ROOT $SUBJ_NAME "$SUBJ_NAME_FORMAL" $NEW_DT_SUBJ true false true "$CLASSPATH"

java -cp $DT_TOOLS: edu.washington.cs.dt.impact.figure.generator.EnhancedResultsFigureGenerator -directory $DT_ROOT/$paraDir -outputDirectory $DT_ROOT/$paraDir -allowNegatives

# ======================================================

java -cp $DT_TOOLS: edu.washington.cs.dt.impact.figure.generator.NumDependentTestsFigureGenerator -priorDirectory $DT_ROOT/$prioDir -seleDirectory $DT_ROOT/$seleDir -paraDirectory $DT_ROOT/$paraDir -outputDirectory ./ -minBoundOrigDTFile $ORIG_MIN_DTS -minBoundAutoDTFile $AUTO_MIN_DTS

echo "[INFO] Script has finished running."
echo "[INFO] Start time was ${startTime}"

endTime=`date`
echo "[INFO] End time is ${endTime}"
