#!/bin/bash
# cis-master-docker.sh

# Ensure kubeconfig content is passed as an environment variable
if [[ -z "$KUBECONFIG_CONTENT" ]]; then
    echo "KUBECONFIG_CONTENT environment variable not set. Exiting."
    exit 1
fi

# Create a temporary kubeconfig file
echo "$KUBECONFIG_CONTENT" > kubeconfig
export KUBECONFIG=$(pwd)/kubeconfig

# Run kube-bench in a Docker container and capture the total number of failures
total_fail=$(docker run --rm \
    --pid=host \
    -v /etc:/etc:ro \
    -v /var:/var:ro \
    -v $(which kubectl):/usr/local/mount-from-host/bin/kubectl \
    -v $(pwd)/kubeconfig:/root/.kube/config \
    -e KUBECONFIG=/root/.kube/config \
    -t aquasec/kube-bench:latest \
    run --targets master \
        --version 1.19 \
        --check 1.2.7,1.2.8,1.2.9 \
        --json | jq .Totals.total_fail)

# Clean up the temporary kubeconfig file
rm -f kubeconfig

# Check if there are any failures
if [[ "$total_fail" -ne 0 ]]; then
    echo "CIS Benchmark Failed MASTER while testing for 1.2.7, 1.2.8, 1.2.9"
    exit 1
else
    echo "CIS Benchmark Passed for MASTER - 1.2.7, 1.2.8, 1.2.9"
fi
