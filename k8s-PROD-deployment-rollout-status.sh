#!/bin/bash

# Optimized k8s deployment rollout status check script

# Reduce sleep time for efficiency, relying more on the rollout status check itself
sleep 10s

# Rollout status check with a longer timeout
timeout=300s  # Allow up to 5 minutes for the rollout to complete
echo "Checking rollout status for deployment: ${deploymentName} in namespace 'prod'"

rollout_status=$(kubectl -n prod rollout status deploy ${deploymentName} --timeout=${timeout})

if [[ "$rollout_status" != *"successfully rolled out"* ]]; then
    echo "Deployment ${deploymentName} Rollout has Failed"
    # Provide more details for troubleshooting
    echo "Fetching details for troubleshooting:"
    kubectl -n prod describe deploy ${deploymentName}
    kubectl -n prod get pods -l app=${deploymentName} -o wide
    echo "Undoing the failed deployment..."
    kubectl -n prod rollout undo deploy ${deploymentName}
    exit 1
else
    echo "Deployment ${deploymentName} Rollout is Successful"
fi
