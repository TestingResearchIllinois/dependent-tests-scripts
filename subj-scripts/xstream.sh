# The root directory for the old subject
export DT_SUBJ_ROOT=/home/user/dependent-tests-impact/experiments/xstream-1.2
# Directory for where all of the old subject's information is stored.
export DT_SUBJ=$DT_SUBJ_ROOT/xstream/target
# Directory containing the old subject's src directory.
export DT_SUBJ_SRC=$DT_SUBJ_ROOT/xstream

# The root directory for the new subject
export NEW_DT_SUBJ_ROOT=/home/user/dependent-tests-impact/experiments/xstream-1.2.1
# Directory for where all of the new subject's information is stored.
export NEW_DT_SUBJ=$NEW_DT_SUBJ_ROOT/xstream/target
# Directory containing the new subject's src directory.
export NEW_DT_SUBJ_SRC=$NEW_DT_SUBJ_ROOT/xstream

# The name of the subject you wish to add (e.g., xml_security)
export SUBJ_NAME=xstream
# The name of the subject you want to be displayed in the paper (e.g., XML Security)
export SUBJ_NAME_FORMAL=XStream

source ../setup-vars.sh
