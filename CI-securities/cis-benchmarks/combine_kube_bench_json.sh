#!/bin/bash

# Ensure the JSON output files exist
if [[ ! -f kube-bench-report.json ]] || [[ ! -f etcd-bench-report.json ]] || [[ ! -f kubelet-bench-report.json ]]; then
    echo "One or more kube-bench JSON output files are missing."
    exit 1
fi

# Combine JSON files into one
echo '{ "Benchmarks": [' > combined-bench.json

# Add master JSON
cat kube-bench-report.json | jq '{ "type": "master", "controls": .Controls }' >> combined-bench.json
echo ',' >> combined-bench.json

# Add etcd JSON
cat etcd-bench-report.json | jq '{ "type": "etcd", "controls": .Controls }' >> combined-bench.json
echo ',' >> combined-bench.json

# Add kubelet JSON
cat kubelet-bench-report.json | jq '{ "type": "kubelet", "controls": .Controls }' >> combined-bench.json

# Close the JSON array
echo '] }' >> combined-bench.json

# Validate the combined JSON
jq . combined-bench.json > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo "Failed to generate a valid combined JSON file. Check combined-bench.json for errors."
    exit 1
fi

echo "Combined JSON file generated: combined-bench.json"
