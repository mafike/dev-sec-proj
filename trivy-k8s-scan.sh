#!/bin/bash

# Ensure imageName is set
if [[ -z "$imageName" ]]; then
    echo "Error: imageName environment variable is not set."
    exit 1
fi

echo "Scanning image: $imageName"

# Pre-create Trivy cache directory with correct ownership
CACHE_DIR="$WORKSPACE/trivy"
mkdir -p "$CACHE_DIR"
chown -R jenkins:jenkins "$CACHE_DIR" # Recursively change ownership of the directory

# Run Trivy scans
echo "Running Trivy scan for LOW, MEDIUM, and HIGH severity vulnerabilities..."
docker run --rm -v "$CACHE_DIR:/root/.cache/" aquasec/trivy:0.17.2 -q image --exit-code 0 --severity LOW,MEDIUM,HIGH --light "$imageName"

echo "Running Trivy scan for CRITICAL severity vulnerabilities..."
docker run --rm -v "$CACHE_DIR:/root/.cache/" aquasec/trivy:0.17.2 -q image --exit-code 1 --severity CRITICAL --light "$imageName"

# Trivy scan result processing
exit_code=$?
echo "Exit Code: $exit_code"

# Check scan results
if [[ $exit_code -eq 1 ]]; then
    echo "Image scanning failed. Vulnerabilities found."
    exit 1
else
    echo "Image scanning passed. No vulnerabilities found."
fi

# Ensure all subdirectories and files in the cache directory are owned by Jenkins
echo "Ensuring proper ownership of the cache directory..."
chown -R jenkins:jenkins "$CACHE_DIR"

# Cleanup cache directory
echo "Cleaning up Trivy cache directory..."
rm -rf "$CACHE_DIR"
