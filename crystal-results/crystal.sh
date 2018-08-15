export DT_ROOT=$(cd "$(dirname $BASH_SOURCE)/../.."; pwd)

# The root directory for the old subject
export DT_SUBJ_ROOT=$DT_ROOT/crystalvc

# The root directory for the new subject
export NEW_DT_SUBJ_ROOT=$DT_ROOT/crystal

# The name of the subject you wish to add (e.g., xml_security)
export SUBJ_NAME=crystal
# The name of the subject you want to be displayed in the paper (e.g., XML Security)
export SUBJ_NAME_FORMAL=Crystal

source ../setup-vars-ant.sh
