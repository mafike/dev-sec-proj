#!/bin/bash

# Print the image name
echo "Scanning image: $imageName"

# Verify the Docker daemon is accessible
if ! docker info >/dev/null 2>&1; then
    echo "Error: Cannot connect to the Docker daemon. Please ensure Docker is running."
    exit 1
fi

# Ensure the image exists in the registry
if ! docker pull "$imageName"; then
    echo "Error: Image '$imageName' not found in the registry. Ensure it is pushed correctly."
    exit 1
fi

# Run Trivy scans
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $WORKSPACE:/root/.cache/ \
  aquasec/trivy:0.17.2 -q image \
  --skip-update \
  --severity LOW,MEDIUM,HIGH,CRITICAL \
  --light "$imageName"

# Capture the exit code
exit_code=$?
echo "Exit Code: $exit_code"

# Handle results
if [[ $exit_code == 1 ]]; then
    echo "Image scanning failed. Vulnerabilities found."
    exit 1
else
    echo "Image scanning passed. No vulnerabilities found."
fi
