#!/bin/bash

dockerImageName=$(awk 'NR==1 {print $2}' Dockerfile)
echo "Docker Image Name: $dockerImageName"

# Set the cache directory
TRIVY_CACHE_DIR="$WORKSPACE/trivy-cache"
mkdir -p "$TRIVY_CACHE_DIR"
chown -R $(id -u jenkins):$(id -g jenkins) "$TRIVY_CACHE_DIR"

# Run Trivy scans
docker run --rm \
  -v "$WORKSPACE:/root/.cache/" \
  -e "TRIVY_CACHE_DIR=/root/.cache/trivy-cache" \
  aquasec/trivy:0.17.2 -q image --exit-code 0 --severity HIGH --light "$dockerImageName"

docker run --rm \
  -v "$WORKSPACE:/root/.cache/" \
  -e "TRIVY_CACHE_DIR=/root/.cache/trivy-cache" \
  aquasec/trivy:0.17.2 -q image --exit-code 1 --severity CRITICAL --light "$dockerImageName"

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
