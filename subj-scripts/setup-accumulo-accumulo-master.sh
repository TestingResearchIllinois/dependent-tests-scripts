ROOT=$(cd "$(dirname $BASH_SOURCE)/../.."; pwd)
export DT_SUBJ_ROOT=$ROOT/accumulo-old-daeffd8d9cf980814fb7d131a0d89cbdfd856298
export DT_SUBJ=$ROOT/accumulo-old-daeffd8d9cf980814fb7d131a0d89cbdfd856298/server/master/target
export DT_SUBJ_SRC=$ROOT/accumulo-old-daeffd8d9cf980814fb7d131a0d89cbdfd856298/server/master
export DT_CLASS=$ROOT/accumulo-old-daeffd8d9cf980814fb7d131a0d89cbdfd856298/server/master/target/classes
export DT_TESTS=$ROOT/accumulo-old-daeffd8d9cf980814fb7d131a0d89cbdfd856298/server/master/target/test-classes
export NEW_DT_SUBJ_ROOT=$ROOT/accumulo-new-a770d44b57027fcee5b25dc2fa9778959e7807c7
export NEW_DT_SUBJ=$ROOT/accumulo-new-a770d44b57027fcee5b25dc2fa9778959e7807c7/server/master/target
export NEW_DT_SUBJ_SRC=$ROOT/accumulo-new-a770d44b57027fcee5b25dc2fa9778959e7807c7/server/master
export NEW_DT_CLASS=$ROOT/accumulo-new-a770d44b57027fcee5b25dc2fa9778959e7807c7/server/master/target/classes
export NEW_DT_TESTS=$ROOT/accumulo-new-a770d44b57027fcee5b25dc2fa9778959e7807c7/server/master/target/test-classes
export SUBJ_NAME=accumulo-accumulo-master
export SUBJ_NAME_FORMAL=accumulo-accumulo-master

# The lowest level package that contains all of this subject's code. Used by PIT
export SUBJ_PACKAGE="org.apache.accumulo.master.*"

export SUBJ_START_DATE=2018-01-17

. ../setup-vars.sh

