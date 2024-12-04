############### k8s-deployment-rollout-status.sh ###############
#!/bin/bash

# k8s-deployment-rollout-status.sh

# Increase sleep to ensure that the deployment has started properly
sleep 10s

# Rollout status check with a longer timeout
timeout=300s  # Allow up to 5 minutes for the rollout to complete
echo "Checking rollout status for deployment: ${deploymentName}"

rollout_status=$(kubectl -n default rollout status deploy ${deploymentName} --timeout=${timeout})

if [[ "$rollout_status" != *"successfully rolled out"* ]]; then
    echo "Deployment ${deploymentName} Rollout has Failed"
    # Provide more details on why the deployment might have failed
    echo "Fetching details for troubleshooting:"
    kubectl -n default describe deploy ${deploymentName}
    kubectl -n default get pods -l app=${deploymentName} -o wide
    echo "Undoing the failed deployment..."
    kubectl -n default rollout undo deploy ${deploymentName}
    exit 1
else
    echo "Deployment ${deploymentName} Rollout is Successful"
fi
############### k8s-deployment-rollout-status.sh ###############
