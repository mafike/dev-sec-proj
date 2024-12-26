#!/bin/bash

set -eo pipefail

JENKINS_URL='http://jenkins-alb-722316857.us-east-1.elb.amazonaws.com/'

JENKINS_CRUMB=$(curl -s --cookie-jar /tmp/cookies -u mafike:mafike ${JENKINS_URL
}/crumbIssuer/api/json | jq .crumb -r)

JENKINS_TOKEN=$(curl -s -X POST -H "Jenkins-Crumb:${JENKINS_CRUMB}" --cookie /tm
p/cookies "${JENKINS_URL}/me/descriptorByName/jenkins.security.ApiTokenProperty/
generateNewToken?newTokenName=demo-token66" -u mafike:mafike | jq .data.tokenVal
ue -r)

echo $JENKINS_URL
echo $JENKINS_CRUMB
echo $JENKINS_TOKEN

while read plugin; do
   echo "........Installing ${plugin} .."
   curl -s POST --data "<jenkins><install plugin='${plugin}' /></jenkins>" -H 'C
ontent-Type: text/xml' "$JENKINS_URL/pluginManager/installNecessaryPlugins" --us
er "mafike:$JENKINS_TOKEN"
done < plugins.txt