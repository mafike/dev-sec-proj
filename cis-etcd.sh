#!/bin/bash
# cis-etcd.sh

# Ensure kubeconfig path is passed as an environment variable
if [[ -z "$KUBECONFIG_PATH" ]]; then
    echo "KUBECONFIG_PATH environment variable not set. Exiting."
    exit 1
fi

export KUBECONFIG=$KUBECONFIG_PATH

# Run kube-bench in a Docker container targeting etcd and capture the total number of failures
docker run --rm \
    --pid=host \
    -v /etc:/etc:ro \
    -v /var:/var:ro \
    -v $(which kubectl):/usr/local/mount-from-host/bin/kubectl \
    -v $KUBECONFIG_PATH:/root/.kube/config \
    -e KUBECONFIG=/root/.kube/config \
    -t aquasec/kube-bench:latest \
    run --targets etcd \
        --version 1.15 \
        --check 2.2 \
        --json > etcd-bench-report.json

# Extract the number of failures from the JSON report
total_fail=$(jq .Totals.total_fail < etcd-bench-report.json)
# Append results to the combined report
jq '. | .target="etcd"' etcd-bench-report.json >> combined-bench-report.json

# Check if there are any failures
if [[ "$total_fail" -ne 0 ]]; then
    echo "CIS Benchmark Failed ETCD while testing for 2.2"
    exit 1
else
    echo "CIS Benchmark Passed for ETCD - 2.2"
fi
