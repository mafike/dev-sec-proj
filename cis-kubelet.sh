#!/bin/bash
# cis-kubelet.sh

# Ensure kubeconfig path is passed as an environment variable
if [[ -z "$KUBECONFIG_PATH" ]]; then
    echo "KUBECONFIG_PATH environment variable not set. Exiting."
    exit 1
fi

export KUBECONFIG=$KUBECONFIG_PATH

# Run kube-bench in a Docker container targeting node (kubelet) and capture the total number of failures
docker run --rm \
    --pid=host \
    -v /etc:/etc:ro \
    -v /var:/var:ro \
    -v $(which kubectl):/usr/local/mount-from-host/bin/kubectl \
    -v $KUBECONFIG_PATH:/root/.kube/config \
    -e KUBECONFIG=/root/.kube/config \
    -t aquasec/kube-bench:latest \
    run --targets node \
        --version 1.15 \
        --check 4.2.1,4.2.2 \
        --json > kubelet-bench-report.json

# Extract the number of failures from the JSON report
total_fail=$(jq .Totals.total_fail < kubelet-bench-report.json)
# Append results to the combined report
jq '. | .target="kubelet"' kubelet-bench-report.json >> combined-bench-report.json

# Check if there are any failures
if [[ "$total_fail" -ne 0 ]]; then
    echo "CIS Benchmark Failed Kubelet while testing for 4.2.1, 4.2.2"
    exit 1
else
    echo "CIS Benchmark Passed Kubelet for 4.2.1, 4.2.2"
fi
