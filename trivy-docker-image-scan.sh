#!/bin/bash

# Fetch the Docker image name from the Dockerfile
dockerImageName=$(awk 'NR==1 {print $2}' Dockerfile)
echo "Docker Image Name: $dockerImageName"

# Run Trivy scans
docker run --rm -v "$WORKSPACE:/root/.cache/" aquasec/trivy:0.17.2 -q image --exit-code 0 --severity HIGH --light "$dockerImageName"
docker run --rm -v "$WORKSPACE:/root/.cache/" aquasec/trivy:0.17.2 -q image --exit-code 1 --severity CRITICAL --light "$dockerImageName"

# Trivy scan result processing
exit_code=$?
echo "Exit Code: $exit_code"

# Check scan results
if [[ "${exit_code}" == 1 ]]; then
    echo "Image scanning failed. Vulnerabilities found."
    exit 1
else
    echo "Image scanning passed. No CRITICAL vulnerabilities found."
fi

# Ensure all files and subdirectories in the trivy directory are owned by jenkins
if [[ -d "trivy" ]]; then
    echo "Fixing permissions for the trivy directory..."
    sudo chown -R jenkins:jenkins trivy
    echo "Permissions fixed."
else
    echo "Trivy directory not found. Skipping permission fix."
fi
