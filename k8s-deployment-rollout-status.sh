#!/bin/bash

# Rollout Monitoring Script: k8s-deployment-rollout-status.sh

set -e  # Exit immediately if a command exits with a non-zero status

# Ensure required variables are set
if [[ -z "${deploymentName}" ]]; then
  echo "Error: Required environment variables (deploymentName) are not set."
  exit 1
fi

# Initial delay to ensure deployment starts properly
sleep 10s

# Rollout status check
timeout=300s  # Timeout for rollout monitoring
echo "Checking rollout status for deployment: ${deploymentName} in namespace: ${namespace}"

rollout_status=$(kubectl -n "${namespace}" rollout status deployment/${deploymentName} --timeout=${timeout} || true)

if [[ "$rollout_status" != *"successfully rolled out"* ]]; then
  echo "Deployment ${deploymentName} rollout has failed."
  echo "Fetching details for troubleshooting..."
  kubectl -n "${namespace}" describe deployment ${deploymentName}
  kubectl -n "${namespace}" get pods -l app=${deploymentName} -o wide
  kubectl -n "${namespace}" logs -l app=${deploymentName} --tail=50
  echo "Undoing the failed deployment..."
  kubectl -n "${namespace}" rollout undo deployment/${deploymentName}
  exit 1
else
  echo "Deployment ${deploymentName} rollout is successful."
fi

