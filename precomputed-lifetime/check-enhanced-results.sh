#!/usr/bin/env bash

# Usage: bash check-enhanced-results.sh DIRECTORIES

source ../setup-vars.sh

for dir in "$@"; do
    if [[ -d "$dir" ]]; then
        # Generate enhanced results
        echo "[INFO] Generating enhanced results for: $dir"
        java -cp $DT_TOOLS: edu.washington.cs.dt.impact.figure.generator.EnhancedResultsFigureGenerator -directory "$dir/prioritization-results" -outputDirectory "$dir" -allowNegatives
        java -cp $DT_TOOLS: edu.washington.cs.dt.impact.figure.generator.EnhancedResultsFigureGenerator -directory "$dir/selection-results" -outputDirectory "$dir" -allowNegatives
        java -cp $DT_TOOLS: edu.washington.cs.dt.impact.figure.generator.EnhancedResultsFigureGenerator -directory "$dir/parallelization-results" -outputDirectory "$dir" -allowNegatives

        # Looks for negative values. If we find any, that means the enhanced technique is worse.
        # TODO: Maybe go on a per-technique basis.
        for fname in $(find "$dir" -name "enhanced-*-orig-results.tex"); do
            data=$(cat "$fname" | head -1 | sed -E "s/&//g" | awk '{ $1=""; print $0; }') # Get the first line, and remove all the &
            # echo $data
            if echo $data | grep -q "\-"; then
                echo "Found negative values for $fname"
            fi
        done
    fi
done

