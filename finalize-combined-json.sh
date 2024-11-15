#!/bin/bash
# Finalize combined JSON report

if [[ -f combined-bench-report.json ]]; then
    echo "[" > tmp-combined.json
    cat combined-bench-report.json >> tmp-combined.json
    echo "]" >> tmp-combined.json
    mv tmp-combined.json combined-bench-report.json
else
    echo "No combined report found. Exiting."
    exit 1
fi
