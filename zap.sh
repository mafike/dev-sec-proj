#!/bin/bash

# Wait for service to be ready
sleep 5s

# Retrieve the LoadBalancer external IP
EXTERNAL_IP=$(kubectl -n default get svc ${serviceName} -o json | jq -r '.status.loadBalancer.ingress[0].hostname')

# Retrieve the service port (for HTTP)
PORT=$(kubectl -n default get svc ${serviceName} -o json | jq -r '.spec.ports[] | select(.port == 80) | .port')

# Check if the LoadBalancer IP and Port are resolved
if [[ -z "$EXTERNAL_IP" || "$EXTERNAL_IP" == "null" || -z "$PORT" ]]; then
  echo "Error: Unable to resolve EXTERNAL_IP or PORT. Ensure the service is running and has a LoadBalancer IP."
  exit 1
fi

# Construct the testing URL
TEST_URL="http://$EXTERNAL_IP:$PORT/v3/api-docs"
echo "Resolved Test URL: $TEST_URL"

# Dynamically generate the ZAP rule configuration file
cat <<EOF > zap_rules
# Dynamic ZAP API Scan Rule Configuration
# Change WARN to IGNORE or FAIL as needed
100001 IGNORE $TEST_URL
100000 IGNORE $TEST_URL
40042 IGNORE $TEST_URL
EOF

echo "Generated zap_rules file:"
cat zap_rules

# Set permissions for the current directory
chmod 777 $(pwd)
echo $(id -u):$(id -g)

# Run OWASP ZAP scan with dynamically generated rules
docker run -v $(pwd):/zap/wrk/:rw -t zaproxy/zap-weekly zap-api-scan.py -t $TEST_URL -f openapi -c zap_rules -r zap_report.html

exit_code=$?

# Move the HTML report to a dedicated directory
sudo mkdir -p owasp-zap-report
sudo mv zap_report.html owasp-zap-report

echo "Exit Code: $exit_code"

# Check the exit code and display the appropriate message
if [[ ${exit_code} -ne 0 ]]; then
  echo "OWASP ZAP Report has identified risks (Low/Medium/High). Please check the HTML Report in the 'owasp-zap-report' directory."
  exit 1
else
  echo "OWASP ZAP did not report any risks."
fi

# Optional: Generate configuration file for further use
# Uncomment the following line to generate a config file:
# docker run -v $(pwd):/zap/wrk/:rw -t zaproxy/zap-weekly zap-api-scan.py -t $TEST_URL -f openapi -g gen_file
