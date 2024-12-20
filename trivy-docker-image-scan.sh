#!/bin/bash

# Extract the Docker image name from the Dockerfile
dockerImageName=$(awk 'NR==1 {print $2}' Dockerfile)
echo "Docker Image Name: $dockerImageName"

# Pre-create the Trivy cache directory
CACHE_DIR="$WORKSPACE/trivy"
mkdir -p "$CACHE_DIR"

# Ensure the Trivy cache directory and its contents are owned by Jenkins
chown -R jenkins:jenkins "$CACHE_DIR"

# Run Trivy scans
echo "Running Trivy scan for HIGH severity vulnerabilities..."
docker run --rm -v "$CACHE_DIR:/root/.cache/" aquasec/trivy:0.17.2 -q image --exit-code 0 --severity HIGH --light "$dockerImageName"

echo "Running Trivy scan for CRITICAL severity vulnerabilities..."
docker run --rm -v "$CACHE_DIR:/root/.cache/" aquasec/trivy:0.17.2 -q image --exit-code 1 --severity CRITICAL --light "$dockerImageName"

# Trivy scan result processing
exit_code=$?
echo "Exit Code: $exit_code"

# Check scan results
if [[ "${exit_code}" == 1 ]]; then
    echo "Image scanning failed. Vulnerabilities found"
    # Ensure all files are owned by Jenkins before exiting
    chown -R jenkins:jenkins "$CACHE_DIR"
    exit 1
else
    echo "Image scanning passed. No CRITICAL vulnerabilities found"
fi

# Ensure all subdirectories and files are owned by Jenkins post-scan
echo "Ensuring proper ownership of the cache directory..."
chown -R jenkins:jenkins "$CACHE_DIR"

# Cleanup the cache directory
echo "Cleaning up Trivy cache directory..."
rm -rf "$CACHE_DIR"
