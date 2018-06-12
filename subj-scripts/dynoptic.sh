export DT_ROOT=$(cd "$(dirname $BASH_SOURCE)/../.."; pwd)

# The root directory for the old subject
export DT_SUBJ_ROOT=$DT_ROOT/dynoptic

# The root directory for the new subject
export NEW_DT_SUBJ_ROOT=$DT_ROOT/dynoptic-ea407ba0a750

# The name of the subject you wish to add (e.g., xml_security)
export SUBJ_NAME=synoptic
# The name of the subject you want to be displayed in the paper (e.g., XML Security)
export SUBJ_NAME_FORMAL=Synoptic

source ../setup-vars-ant.sh

# Override some of the variables we just set because dynoptic setup is a little different.
export DT_CLASS=$DT_SUBJ/bin/:$DT_ROOT/synoptic/bin/:$DT_ROOT/daikonizer/bin/
export NEW_DT_CLASS=$NEW_DT_SUBJ/bin/:$DT_ROOT/synoptic/bin/:$DT_ROOT/daikonizer/bin/

export DT_LIBS=$DT_ROOT/synoptic/lib/*
export NEW_DT_LIBS=$DT_ROOT/synoptic/lib/*

