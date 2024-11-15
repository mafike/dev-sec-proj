#!/bin/bash

# Ensure the JSON output files exist
if [[ ! -f master-bench.json ]] || [[ ! -f etcd-bench.json ]] || [[ ! -f kubelet-bench.json ]]; then
    echo "One or more kube-bench JSON output files are missing."
    exit 1
fi

# Combine JSON files into one
echo '{ "Benchmarks": [' > combined-bench.json
cat kube-bench.json | jq '.Controls' | sed 's/^\[/{ "type": "master", "controls": [/' | sed 's/\]$/] },/' >> combined-bench.json
cat etcd-bench.json | jq '.Controls' | sed 's/^\[/{ "type": "etcd", "controls": [/' | sed 's/\]$/] },/' >> combined-bench.json
cat kubelet-bench.json | jq '.Controls' | sed 's/^\[/{ "type": "kubelet", "controls": [/' | sed 's/\]$/] }/' >> combined-bench.json
echo '] }' >> combined-bench.json

# Validate the combined JSON
jq . combined-bench.json > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo "Failed to generate a valid combined JSON file."
    exit 1
fi

echo "Combined JSON file generated: combined-bench.json"
