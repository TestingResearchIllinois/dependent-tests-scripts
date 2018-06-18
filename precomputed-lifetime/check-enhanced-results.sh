#!/usr/bin/env bash

# Usage: bash check-enhanced-results.sh START_DATE DIRECTORIES
# START_DATE should be in the format yyyy-mm-dd-H-M-S

source ../setup-vars.sh

START_DATE=$1

# Create and clear the results files.
> prio-results.txt
> sele-results.txt
> para-results.txt

for dir in "${@:2}"; do
    if [[ -d "$dir" ]]; then
        # Generate enhanced results
        echo "[INFO] Generating enhanced results for: $dir"
        java -cp $DT_TOOLS: edu.washington.cs.dt.impact.figure.generator.EnhancedResultsFigureGenerator -directory "$dir/prioritization-results" -outputDirectory "$dir" -allowNegatives
        java -cp $DT_TOOLS: edu.washington.cs.dt.impact.figure.generator.EnhancedResultsFigureGenerator -directory "$dir/selection-results" -outputDirectory "$dir" -allowNegatives
        java -cp $DT_TOOLS: edu.washington.cs.dt.impact.figure.generator.EnhancedResultsFigureGenerator -directory "$dir/parallelization-results" -outputDirectory "$dir" -allowNegatives

        for fname in $(find "$dir" -name "enhanced-*-orig-results.tex"); do
            data=$(cat "$fname" | head -1 | awk '{ $1=""; $2=""; print $0; }') # Get the first line, remove the subject name and it's &
            
            if [[ "$fname" =~ "prio" ]]; then
                echo "$dir & $data" >> prio-results.txt
            elif [[ "$fname" =~ "sele" ]]; then
                echo "$dir & $data" >> sele-results.txt
            elif [[ "$fname" =~ "para" ]]; then
                echo "$dir & $data" >> para-results.txt
            fi
        done
    fi
done

python check-enhanced-results.py $START_DATE prio-results.txt sele-results.txt para-results.txt

