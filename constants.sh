# This file is to share variables and functions. Please do not run this
# file.

# Number of times to run the test order before taking the median
medianTimes=5
# Number of times to randomize the test order when calculating the
# precomputed dependences
randomTimes=100

testTypes=(orig auto)
coverages=(statement function)
machines=(2 4 8 16)

# Ordering for the three techniques
priorOrders=(absolute relative)
seleOrders=(original absolute relative)

# Directory to output the results
prioDir=prioritization-results
seleDir=selection-results
paraDir=parallelization-results

prioList=prioritization-dt-list
seleList=selection-dt-list
paraList=parallelization-dt-list

# Which method of handling DTs should be used.
postProcessFlags=("" "-postProcessDTs")

function clearTemp() {
  rm -rf tmpfile.txt
  rm -rf tmptestfiles.txt
  rm -rf dtFixerOutput
  rm -rf local-repo/
  rm -rf helium-bundle/
  rm -rf notebook/
  rm -rf ViewVersionInfo/
}

copy_results() {
    mkdir "$DT_SCRIPTS/${SUBJ_NAME}-results/$1"

    cp -r "$DT_ROOT/prioritization-results/" "$DT_SCRIPTS/${SUBJ_NAME}-results/$1"
    cp -r "$DT_ROOT/selection-results/" "$DT_SCRIPTS/${SUBJ_NAME}-results/$1"
    cp -r "$DT_ROOT/parallelization-results/" "$DT_SCRIPTS/${SUBJ_NAME}-results/$1"
}

