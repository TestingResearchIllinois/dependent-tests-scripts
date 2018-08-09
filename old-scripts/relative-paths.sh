#!/usr/bin/env bash

# Makes all paths in a script relative to the currently directory.
# $1 - The script containing the paths.

CURRENT=$(pwd)

echo "ROOT=$CURRENT" > temp
sed -E "s|$CURRENT|\$ROOT|g" $1 >> temp
mv temp $1

