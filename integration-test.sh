#!/bin/bash

# integration-test.sh

sleep 5s

# Get the LoadBalancer's external IP
EXTERNAL_IP=$(kubectl -n default get svc ${serviceName} -o json | jq -r '.status.loadBalancer.ingress[0].hostname')

# Get the LoadBalancer's port
PORT=$(kubectl -n default get svc ${serviceName} -o json | jq -r '.spec.ports[0].port')

echo "Resolved External IP: $EXTERNAL_IP"
echo "Resolved Port: $PORT"
echo "Resolved Application URI: $applicationURI"

if [[ ! -z "$EXTERNAL_IP" && "$EXTERNAL_IP" != "null" && ! -z "$PORT" ]]; then

    # Construct the full URL
    FULL_URL="http://$EXTERNAL_IP:$PORT$applicationURI"

    # Test the application endpoint
    response=$(curl -s $FULL_URL)
    http_code=$(curl -s -o /dev/null -w "%{http_code}" $FULL_URL)

    # Debugging output
    echo "Testing URL: $FULL_URL"
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

