############### trivy-k8s-scan.sh ############### 

#!/bin/bash

echo "Image Name: $imageName" # Getting Image name from the environment variable

# Set the cache directory
TRIVY_CACHE_DIR="$WORKSPACE/trivy-cache"
mkdir -p "$TRIVY_CACHE_DIR"
chown -R $(id -u jenkins):$(id -g jenkins) "$TRIVY_CACHE_DIR"

# Run Trivy scans
docker run --rm \
  -v "$WORKSPACE:/root/.cache/" \
  -e "TRIVY_CACHE_DIR=/root/.cache/trivy-cache" \
  aquasec/trivy:0.17.2 -q image --exit-code 0 --severity LOW,MEDIUM,HIGH --light "$imageName"

docker run --rm \
  -v "$WORKSPACE:/root/.cache/" \
  -e "TRIVY_CACHE_DIR=/root/.cache/trivy-cache" \
  aquasec/trivy:0.17.2 -q image --exit-code 1 --severity CRITICAL --light "$imageName"

# Trivy scan result processing
exit_code=$?
echo "Exit Code: $exit_code"

# Check scan results
if [[ "${exit_code}" == 1 ]]; then
    echo "Image scanning failed. Vulnerabilities found."
    exit 1
else
    echo "Image scanning passed. No vulnerabilities found."
fi

############### trivy-k8s-scan.sh ###############
