export DT_ROOT=$(cd "$(dirname $BASH_SOURCE)/../.."; pwd)

# The root directory for the old subject
export DT_SUBJ_ROOT=$DT_ROOT/zeppelin-old-0f81b6d6132471ddf0e91cc3738da1ff365604f8
# Directory for where all of the old subject's information is stored.
export DT_SUBJ=$DT_SUBJ_ROOT/zeppelin-zengine/target
# Directory containing the old subject's src directory.
export DT_SUBJ_SRC=$DT_SUBJ_ROOT/zeppelin-zengine

# The root directory for the new subject
export NEW_DT_SUBJ_ROOT=$DT_ROOT/zeppelin-new-6353732095af880944b8c09eacc3ab7eaf64e7e0
# Directory for where all of the new subject's information is stored.
export NEW_DT_SUBJ=$NEW_DT_SUBJ_ROOT/zeppelin-zengine/target
# Directory containing the new subject's src directory.
export NEW_DT_SUBJ_SRC=$NEW_DT_SUBJ_ROOT/zeppelin-zengine

# The name of the subject you wish to add (e.g., xml_security)
export SUBJ_NAME=zeppelin-zeppelin-zengine
# The name of the subject you want to be displayed in the paper (e.g., XML Security)
export SUBJ_NAME_FORMAL=Zeppelin-Zengine

export SUBJ_START_DATE=2018-01-17

source ../setup-vars.sh

