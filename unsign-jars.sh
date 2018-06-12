#!/usr/bin/env bash

# Usage: bash unsign-jars.sh <directory containing jars>

for file in $(ls -1 "$1/"*.jar)
do
    zip -d "$file" 'META-INF/*.SF' 'META-INF/*.RSA' > /dev/null
done

