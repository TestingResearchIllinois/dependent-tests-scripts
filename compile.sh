# Usage: compile.sh $DT_ROOT

source ./constants.sh

#!/bin/bash

compileRandoop() {
  cd $1/target/randoop
  javac -cp $2 ErrorTest*.java RegressionTest*.java
  mkdir bin
  mv *.class ./bin
  cd $DT_ROOT/scripts
}

DT_ROOT=$1

source ./subj-constants.sh $DT_ROOT

startTime=`date`

# ======================================================
echo "[INFO] Compiling old version of ant subjects."

index=0
count=${#antExp[@]}
while [ "$index" -lt "$count" ]; do
  ANT_BASE_DIR=${antExp[$index]}

  ant -Dbasedir=$ANT_BASE_DIR -f $ANT_BASE_DIR/build.xml

  let "index++"
done

# ======================================================
echo "[INFO] Compiling new version of ant subjects."

index=0
count=${#antNextExp[@]}
while [ "$index" -lt "$count" ]; do
  ANT_BASE_DIR=${antNextExp[$index]}

  ant -Dbasedir=$ANT_BASE_DIR -f $ANT_BASE_DIR/build.xml

  let "index++"
done

# ======================================================
echo "[INFO] Compiling old version of Maven subjects."

index=0
count=${#antMvnExp[@]}
while [ "$index" -lt "$count" ]; do
  ANT_BASE_DIR=${antMvnExp[$index]}
  EXP_DIR=${antMvnCP[$index]}

  ant -Dbasedir=$ANT_BASE_DIR -f $DT_ROOT/scripts/data/build.xml

  compileRandoop $ANT_BASE_DIR $EXP_DIR

  let "index++"
done

# ======================================================
echo "[INFO] Compiling new version of Maven subjects."

index=0
count=${#antMvnNextExp[@]}
while [ "$index" -lt "$count" ]; do
  ANT_BASE_DIR=${antMvnNextExp[$index]}
  EXP_DIR=${antMvnCP[$index]}

  ant -Dbasedir=$ANT_BASE_DIR -f $DT_ROOT/scripts/data/build.xml

  compileRandoop $ANT_BASE_DIR $EXP_DIR

  let "index++"
done

# ======================================================


echo "[INFO] Script has finished running."

echo "[INFO] Start time was ${startTime}"

endTime=`date`
echo "[INFO] End time is ${endTime}"
