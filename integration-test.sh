#!/bin/bash

# integration-test.sh

sleep 5s

PORT=$(kubectl -n default get svc ${serviceName} -o json | jq .spec.ports[].nodePort)

echo "Resolved Port: $PORT"
echo "Resolved Application URL: $applicationURL"
echo "Resolved URI: $applicationURI"

if [[ ! -z "$PORT" ]]; then

    response=$(curl -s $applicationURL:$PORT$applicationURI)
    http_code=$(curl -s -o /dev/null -w "%{http_code}" $applicationURL:$PORT$applicationURI)

    # Debugging output
    echo "Raw Response: $response"
    echo "HTTP Code: $http_code"

    # Extract the incremented value from the HTML response
    incremented_value=$(echo "$response" | grep -oP '(?<=<span class="highlight" id="incrementedValue">)\d+(?=</span>)')

    echo "Extracted Incremented Value: $incremented_value"

    if [[ "$incremented_value" == 100 ]]; then
        echo "Increment Test Passed"
    else
        echo "Increment Test Failed"
        exit 1
    fi

    if [[ "$http_code" == 200 ]]; then
        echo "HTTP Status Code Test Passed"
    else
        echo "HTTP Status code is not 200"
        exit 1
    fi

else
    echo "The Service does not have a NodePort"
    exit 1
fi

