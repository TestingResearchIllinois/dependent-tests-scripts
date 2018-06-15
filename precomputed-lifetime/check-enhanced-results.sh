#!/usr/bin/env bash

# Usage: bash check-enhanced-results.sh DIRECTORIES

source ../setup-vars.sh

for dir in "$@"; do
    # Generate enhanced results
    java -cp $DT_TOOLS: edu.washington.cs.dt.impact.figure.generator.EnhancedResultsFigureGenerator -directory "$dir/prioritization-results" -outputDirectory "$dir" -allowNegatives

    # Looks for negative values. If we find any, that means the enhanced technique is worse.
    # TODO: Maybe go on a per-technique basis.
    if grep -q "-" enhanced-*-results.tex; then
        echo "Found negative values for $dir"
    fi
done

