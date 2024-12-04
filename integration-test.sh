################################## integration-test.sh ################################## 
#!/bin/bash

# integration-test.sh

sleep 5s

PORT=$(kubectl -n default get svc ${serviceName} -o json | jq .spec.ports[].nodePort)

echo $PORT
echo $applicationURL:$PORT$applicationURI

if [[ ! -z "$PORT" ]]; then

    # Get the full response from the /increment endpoint
    response=$(curl -s $applicationURL:$PORT$applicationURI)
    http_code=$(curl -s -o /dev/null -w "%{http_code}" $applicationURL:$PORT$applicationURI)

    # Check if the response is in JSON format
    if jq -e . >/dev/null 2>&1 <<<"$response"; then
        echo "Response is in valid JSON format"
        incremented_value=$(echo "$response" | jq -r '.incrementedValue')

        if [[ "$incremented_value" == 100 ]]; then
            echo "Increment Test Passed"
        else
            echo "Increment Test Failed"
            exit 1
        fi
    else
        echo "Response is not in valid JSON format"
        exit 1
    fi

    # Check HTTP status code
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


################################## integration-test.sh ################################## 
