# Usage: source ambari-server-new.sh $DT_ROOT

export DT_ROOT=$(cd "$(dirname $BASH_SOURCE)/../.."; pwd)

# The root directory for the old subject
export DT_SUBJ_ROOT=$DT_ROOT/ambari-old-c088e59ebcf099b01603d883dce7700d44cabc68
# Directory for where all of the old subject's information is stored.
export DT_SUBJ=$DT_SUBJ_ROOT/ambari-server/target
# Directory containing the old subject's src directory.
export DT_SUBJ_SRC=$DT_SUBJ_ROOT/ambari-server

# The root directory for the new subject
export NEW_DT_SUBJ_ROOT=$DT_ROOT/ambari-new-ad9bcb645dd5c743924d548b889e12185345b523
# Directory for where all of the new subject's information is stored.
export NEW_DT_SUBJ=$NEW_DT_SUBJ_ROOT/ambari-server/target
# Directory containing the new subject's src directory.
export NEW_DT_SUBJ_SRC=$NEW_DT_SUBJ_ROOT/ambari-server

# The name of the subject you wish to add (e.g., xml_security)
export SUBJ_NAME=ambari-server
# The name of the subject you want to be displayed in the paper (e.g., XML Security)
export SUBJ_NAME_FORMAL=Ambari-Server

source ../setup-vars.sh
