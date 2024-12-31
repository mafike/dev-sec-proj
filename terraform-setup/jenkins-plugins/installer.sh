#!/bin/bash

set -eo pipefail

JENKINS_URL=''

# Fetch Jenkins Crumb
JENKINS_CRUMB=$(curl -s --cookie-jar /tmp/cookies -u mafike:mafike "${JENKINS_URL}crumbIssuer/api/json" | jq .crumb -r)

# Generate Jenkins API Token
JENKINS_TOKEN=$(curl -s -X POST -H "Jenkins-Crumb:${JENKINS_CRUMB}" --cookie /tmp/cookies "${JENKINS_URL}me/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken?newTokenName=demo-token66" -u mafike:mafike | jq .data.tokenValue -r)

# Output Jenkins URL, Crumb, and Token for debugging
echo "Jenkins URL: $JENKINS_URL"
echo "Jenkins Crumb: $JENKINS_CRUMB"
echo "Jenkins Token: $JENKINS_TOKEN"

# Install Plugins from plugins.txt
while read -r plugin; do
    echo "........Installing ${plugin} .."
    curl -s -X POST --data "<jenkins><install plugin='${plugin}' /></jenkins>" -H 'Content-Type: text/xml' "${JENKINS_URL}pluginManager/installNecessaryPlugins" --user "mafike:$JENKINS_TOKEN"
done < plugins.txt
