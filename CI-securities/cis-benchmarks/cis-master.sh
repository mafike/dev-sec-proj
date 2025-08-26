#!/bin/bash
# cis-master.sh

# Ensure kubeconfig path is passed as an environment variable
if [[ -z "$KUBECONFIG_PATH" ]]; then
    echo "KUBECONFIG_PATH environment variable not set. Exiting."
    exit 1
fi

export KUBECONFIG=$KUBECONFIG_PATH

# Run kube-bench and log output
echo "Running kube-bench..."
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
        --json > kube-bench-report.json

if [[ ! -f kube-bench-report.json ]]; then
    echo "Failed to generate kube-bench report. Exiting."
    exit 1
fi

echo "kube-bench report generated: kube-bench-report.json"
# Check if there are any failures
if [[ "$total_fail" -ge 3 ]]; then
    echo "CIS Benchmark Failed MASTER while testing for 1.2.7, 1.2.8, 1.2.9"
    echo "Check the detailed report in kube-bench-report.json for more information."
    exit 1
else
    echo "CIS Benchmark Passed for MASTER - 1.2.7, 1.2.8, 1.2.9"
fi
