#!/bin/bash

# Ensure the JSON output files exist
if [[ ! -f kube-bench-report.json ]] || [[ ! -f etcd-bench-report.json ]] || [[ ! -f kubelet-bench-report.json ]]; then
    echo "One or more kube-bench JSON output files are missing."
    exit 1
fi

# Combine JSON files into one
echo '{ "Benchmarks": [' > combined-bench.json
echo "Processing kube-bench-report.json..."
cat kube-bench-report.json | jq '.Controls' > debug-kube-bench.json
cat debug-kube-bench.json | sed 's/^\[/{ "type": "master", "controls": [/' | sed 's/\]$/] }/' >> combined-bench.json
echo ',' >> combined-bench.json

echo "Processing etcd-bench-report.json..."
cat etcd-bench-report.json | jq '.Controls' > debug-etcd-bench.json
cat debug-etcd-bench.json | sed 's/^\[/{ "type": "etcd", "controls": [/' | sed 's/\]$/] }/' >> combined-bench.json
echo ',' >> combined-bench.json

echo "Processing kubelet-bench-report.json..."
cat kubelet-bench-report.json | jq '.Controls' > debug-kubelet-bench.json
cat debug-kubelet-bench.json | sed 's/^\[/{ "type": "kubelet", "controls": [/' | sed 's/\]$/] }/' >> combined-bench.json

echo '] }' >> combined-bench.json

# Validate the combined JSON
jq . combined-bench.json > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo "Failed to generate a valid combined JSON file. Debug files have been created."
    exit 1
fi

echo "Combined JSON file generated: combined-bench.json"
