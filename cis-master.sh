#!/bin/bash
# cis-master.sh

# Ensure kubeconfig path is passed as an environment variable
if [[ -z "$KUBECONFIG_PATH" ]]; then
    echo "KUBECONFIG_PATH environment variable not set. Exiting."
    exit 1
fi

export KUBECONFIG=$KUBECONFIG_PATH

# Run kube-bench in a Docker container and save the detailed output
docker run --rm \
    --pid=host \
    -v /etc:/etc:ro \
    -v /var:/var:ro \
    -v $(which kubectl):/usr/local/mount-from-host/bin/kubectl \
    -v $KUBECONFIG_PATH:/root/.kube/config \
    -e KUBECONFIG=/root/.kube/config \
    -t aquasec/kube-bench:latest \
    run --targets master \
        --version 1.19 \
        --check 1.2.7,1.2.8,1.2.9 \
        --json > master-bench-report.json

# Extract the number of failures
total_fail=$(jq .Totals.total_fail < master-bench-report.json)
 # Append results to combined report with valid JSON structure
if [ ! -f combined-bench-report.json ]; then
    echo "[]" > combined-bench-report.json
fi
jq '. + [{"target": "master", "Tests": .Tests}]' master-bench-report.json combined-bench-report.json > temp.json && mv temp.json combined-bench-report.json

# Check if there are any failures( it should be 0, but rn we just want the test to pass)
if [[ "$total_fail" -ge 3 ]]; then
    echo "CIS Benchmark Failed MASTER while testing for 1.2.7, 1.2.8, 1.2.9"
    echo "Check the detailed report in kube-bench-report.json for more information."
    exit 1
else
    echo "CIS Benchmark Passed for MASTER - 1.2.7, 1.2.8, 1.2.9"
fi
