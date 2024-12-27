#!/bin/bash

# integration-test.sh

# Wait for the Service to be provisioned
sleep 5s

# Retrieve the LoadBalancer external URL
EXTERNAL_IP=$(kubectl -n default get svc ${serviceName} -o json | jq -r '.status.loadBalancer.ingress[0].hostname')

echo "Resolved External IP: $EXTERNAL_IP"
echo "Resolved Application URI: $applicationURI"

if [[ ! -z "$EXTERNAL_IP" && "$EXTERNAL_IP" != "null" ]]; then
    # Test the application endpoint
    response=$(curl -s http://$EXTERNAL_IP$applicationURI)
    http_code=$(curl -s -o /dev/null -w "%{http_code}" http://$EXTERNAL_IP$applicationURI)

    # Debugging output
    echo "Raw Response: $response"
    echo "HTTP Code: $http_code"

    # Extract the incremented value from the HTML response
    incremented_value=$(echo "$response" | grep -oP '(?<=<span class="highlight" id="incrementedValue">)\d+(?=</span>)')

    echo "Extracted Incremented Value: $incremented_value"

    # Validate the extracted value
    if [[ "$incremented_value" == 100 ]]; then
        echo "Increment Test Passed"
    else
        echo "Increment Test Failed"
        exit 1
    fi

    # Validate the HTTP status code
    if [[ "$http_code" == 200 ]]; then
        echo "HTTP Status Code Test Passed"
    else
        echo "HTTP Status Code Test Failed"
        exit 1
    fi

else
    echo "The Service does not have an External IP or LoadBalancer is not ready"
    exit 1
fi

