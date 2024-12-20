#!/bin/bash

# Check if imageName is set
if [[ -z "$imageName" ]]; then
    echo "Error: imageName environment variable is not set."
    exit 1
fi

echo "Scanning image: $imageName"

# Pre-create the Trivy cache directory
CACHE_DIR="$WORKSPACE/trivy"
mkdir -p "$CACHE_DIR"

# Ensure the Trivy cache directory is owned by Jenkins
chown -R jenkins:jenkins "$CACHE_DIR"

# Run Trivy scans as the Jenkins user
echo "Running Trivy scan for LOW, MEDIUM, and HIGH severity vulnerabilities..."
docker run --rm --user $(id -u):$(id -g) -v "$CACHE_DIR:/root/.cache/" aquasec/trivy:0.17.2 -q image --exit-code 0 --severity LOW,MEDIUM,HIGH --light "$imageName"

echo "Running Trivy scan for CRITICAL severity vulnerabilities..."
docker run --rm --user $(id -u):$(id -g) -v "$CACHE_DIR:/root/.cache/" aquasec/trivy:0.17.2 -q image --exit-code 1 --severity CRITICAL --light "$imageName"

# Trivy scan result processing
exit_code=$?
echo "Exit Code: $exit_code"

# Check scan results
if [[ ${exit_code} == 1 ]]; then
    echo "Image scanning failed. Vulnerabilities found."
    exit 1
else
    echo "Image scanning passed. No vulnerabilities found."
fi

# Cleanup the cache directory
echo "Cleaning up Trivy cache directory..."
rm -rf "$CACHE_DIR"
