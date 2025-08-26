#!/bin/bash
sleep 5s

# Retrieve the Istio Ingress Gateway's external IP or hostname
EXTERNAL_IP=$(kubectl -n istio-system get svc istio-ingressgateway -o json | jq -r '.status.loadBalancer.ingress[0].hostname')

# Retrieve the port for HTTP (port 80)
PORT=$(kubectl -n istio-system get svc istio-ingressgateway -o json | jq -r '.spec.ports[] | select(.port == 80) | .port')

echo "Resolved External IP: $EXTERNAL_IP"
echo "Resolved Port: $PORT"
echo "Resolved Application URI: $applicationURI"

if [[ ! -z "$EXTERNAL_IP" && "$EXTERNAL_IP" != "null" && ! -z "$PORT" ]]; then

    # Construct the full URL
    FULL_URL="http://$EXTERNAL_IP:$PORT$applicationURI"

    # Get the full response from the /increment endpoint
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
    echo "The Istio Ingress Gateway does not have an External IP or is not ready"
    exit 1
fi
