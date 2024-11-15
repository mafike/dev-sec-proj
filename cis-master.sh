#!/bin/bash
# cis-master-docker.sh

# Ensure kubeconfig path is passed as an environment variable
if [[ -z "$KUBECONFIG_PATH" ]]; then
    echo "KUBECONFIG_PATH environment variable not set. Exiting."
    exit 1
fi

export KUBECONFIG=$KUBECONFIG_PATH

# Run kube-bench in a Docker container and capture the total number of failures
total_fail=$(docker run --rm \
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
        --json | jq .Totals.total_fail)

# Check if there are any failures
if [[ "$total_fail" -ne 0 ]]; then
    echo "CIS Benchmark Failed MASTER while testing for 1.2.7, 1.2.8, 1.2.9"
    exit 1
else
    echo "CIS Benchmark Passed for MASTER - 1.2.7, 1.2.8, 1.2.9"
fi
