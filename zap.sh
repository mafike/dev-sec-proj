#!/bin/bash

# Wait for the LoadBalancer to be ready
sleep 5s

# Retrieve the LoadBalancer's external IP/hostname
EXTERNAL_IP=$(kubectl -n default get svc ${serviceName} -o json | jq -r '.status.loadBalancer.ingress[0].hostname')

# Retrieve the service port
PORT=$(kubectl -n default get svc ${serviceName} -o json | jq -r '.spec.ports[0].port')

# Validate the retrieved values
if [[ -z "$EXTERNAL_IP" || "$EXTERNAL_IP" == "null" || -z "$PORT" ]]; then
  echo "Error: Unable to resolve EXTERNAL_IP or PORT. Ensure the service is running and has a LoadBalancer IP."
  exit 1
fi

echo "Resolved External IP: $EXTERNAL_IP"
echo "Resolved Port: $PORT"

# Construct the application URL
applicationURL="http://$EXTERNAL_IP"

# Dynamically generate zap_rules file with tabs
cat <<-EOF > zap_rules
100001	IGNORE	$applicationURL/
100000	IGNORE	$applicationURL/
40042	IGNORE	$applicationURL/
EOF

echo "Generated zap_rules file:"
cat zap_rules | cat -A  # Display special characters for debugging

# Set permissions for the current directory
chmod 777 $(pwd)
echo $(id -u):$(id -g)

# Run OWASP ZAP scan with the dynamically generated rules
docker run -v $(pwd):/zap/wrk/:rw -t zaproxy/zap-weekly zap-api-scan.py -t $applicationURL:$PORT/v3/api-docs -f openapi -c zap_rules -r zap_report.html

exit_code=$?

# Move the HTML report to a dedicated directory without sudo
mkdir -p owasp-zap-report
mv zap_report.html owasp-zap-report

echo "Exit Code : $exit_code"

if [[ ${exit_code} -ne 0 ]]; then
  echo "OWASP ZAP Report has either Low/Medium/High Risk. Please check the HTML Report"
  exit 0
else
  echo "OWASP ZAP did not report any Risk"
fi
