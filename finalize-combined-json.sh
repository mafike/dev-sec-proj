#!/bin/bash
# Finalize combined JSON report

if [[ -f combined-bench-report.json ]]; then
    # Add opening bracket for JSON array
    echo "[" > tmp-combined.json

    # Remove trailing newlines and ensure proper comma separation
    sed -e '$!s/$/,/' combined-bench-report.json >> tmp-combined.json

    # Add closing bracket for JSON array
    echo "]" >> tmp-combined.json

    # Replace the original file with the finalized JSON
    mv tmp-combined.json combined-bench-report.json
else
    echo "No combined report found. Exiting."
    exit 1
fi
