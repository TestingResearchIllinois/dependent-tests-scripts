#!/bin/bash
FILES=projectcsvs/*
OUTPUTDIR=$1
for f in $FILES
do
    for TESTTYPE in orig auto
    do
        for TECHNIQUE in para prio sele
        do
            line="$(cat $f),$TESTTYPE,$TECHNIQUE"
            fileName="$(echo $f |  rev | cut -d'.' -f2- | rev).$TESTTYPE.$TECHNIQUE.csv"
            echo $line > $fileName
        done
    done
done

mkdir -p $OUTPUTDIR
mv $FILES.orig.*.csv $OUTPUTDIR
mv $FILES.auto.*.csv $OUTPUTDIR
