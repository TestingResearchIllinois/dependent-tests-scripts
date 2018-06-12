#!/usr/bin/env bash

# $1 - test order file (located in either DT_SUBJ or NEW_DT_SUBJ)
# $2 - Optional. 'new' or 'old'. Whether to run using new subject or old subject. Defaults to 'new'.

PREFIX="new"
if [[ ! -z "$2" ]]; then
    PREFIX="$2"
fi

if [[ "$PREFIX" = "old" ]]; then
    cd $DT_SUBJ
    CLASSPATH=$DT_LIBS:$DT_TESTS:$DT_CLASS:
else
    cd $NEW_DT_SUBJ
    CLASSPATH=$NEW_DT_LIBS:$NEW_DT_TESTS:$NEW_DT_CLASS:
fi

MODIFIED_ORDER="$1-modified"
REMOVED_LIST="$1-removed"

# Create these files.
cp $1 $MODIFIED_ORDER
> $REMOVED_LIST

while true
do
    echo "[INFO] Running $(cat $MODIFIED_ORDER | wc -l) tests."
    MISSING_TEST=$(java -cp $DT_TOOLS: edu.washington.cs.dt.main.ImpactMain -classpath $CLASSPATH -inputTests $MODIFIED_ORDER |& grep "Test method not found: " | head -1 | sed -E "s/.*Test method not found: (.*)/\1/g")

    if [[ -z "$MISSING_TEST" ]]; then
        break
    fi

    echo "[INFO] Removing $MISSING_TEST"

    echo $MISSING_TEST >> $REMOVED_LIST

    grep -vFf $REMOVED_LIST $1 > $MODIFIED_ORDER
done

mv $1 $1-old
cp $MODIFIED_ORDER $1

