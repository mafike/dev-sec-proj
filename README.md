<h1>Numeric-App</h1>

<p>
  Welcome to <strong>Numeric-App</strong>, a DevOps-focused project showcasing advanced infrastructure automation, CI/CD pipelines, Kubernetes deployments, microservices communication, and security integration. This repository highlights professional-grade workflows for deploying and managing containerized applications in production-like environments.
</p>
<div style="text-align: center; margin: 30px 0;">
  <img src="./slack-emojis/ms.png" alt="Microservice" style="width:150px; margin: 15px;">
  <img src="./slack-emojis/aws.png" alt="AWS" style="width:150px; margin: 15px;">
  <img src="./slack-emojis/k8.png" alt="Kubernetes" style="width:150px; margin: 15px;">
  <img src="./slack-emojis/kiali.png" alt="Kiali" style="width:150px; margin: 15px;">
</div>
<h2>About the Project</h2>
<p>
  <strong>Numeric-App</strong> consists of a <em>microservice architecture</em> that includes:
  <ol>
    <li><strong>Java Microservice</strong>: The primary application built using Java.</li>
    <li><strong>Node.js Microservice</strong>: A secondary service required for the Java app to function properly.</li>
  </ol>
</p>

<p>
  The project demonstrates:
</p>
<ul>
  <li><strong>Infrastructure Automation:</strong> Terraform for scalable infrastructure provisioning.</li>
  <li><strong>CI/CD Pipelines:</strong> Automated pipelines built with Jenkins.</li>
  <li><strong>Microservice Communication:</strong> Kubernetes and Docker setup to establish communication between services.</li>
  <li><strong>Security Integration:</strong> Automated compliance checks with tools like Trivy, Kube-Bench, and OPA.</li>
</ul>

<div style="border: 1px solid #ddd; padding: 15px; background: #f9f9f9;">
  <strong>Important:</strong> Before running the Java application pipeline, ensure the Node.js microservice is running. The Java app depends on the Node.js service for its functionality.
</div>

<h2>Microservice Setup</h2>
<h3>Node.js Microservice</h3>
<p>
  The Node.js microservice can be run in two ways: using Docker or deploying it to Kubernetes.
</p>

<h4>Docker Setup</h4>
<div style="background-color: #2d2d2d; padding: 10px; color: #f1f1f1; font-family: monospace; border-radius: 5px;">
  <pre><code>docker run -p 8787:5000 mafike1/node-app:latest</code></pre>
</div>
<p>Verify the service is running by executing:</p>
<div style="background-color: #2d2d2d; padding: 10px; color: #f1f1f1; font-family: monospace; border-radius: 5px;">
  <pre><code>curl localhost:8787/plusone/99</code></pre>
</div>

<h4>Kubernetes Deployment</h4>
<p>To deploy the Node.js microservice in Kubernetes:</p>
<ol>
  <li>Create a deployment:
    <div style="background-color: #2d2d2d; padding: 10px; color: #f1f1f1; font-family: monospace; border-radius: 5px;">
      <pre><code>kubectl create deploy node-app --image mafike1/node-app:latest</code></pre>
    </div>
  </li>
  <li>Expose the service within the cluster:
    <div style="background-color: #2d2d2d; padding: 10px; color: #f1f1f1; font-family: monospace; border-radius: 5px;">
      <pre><code>kubectl expose deploy node-app --name node-service --port 5000 --type ClusterIP</code></pre>
    </div>
  </li>
  <li>Verify the service is running:
    <div style="background-color: #2d2d2d; padding: 10px; color: #f1f1f1; font-family: monospace; border-radius: 5px;">
      <pre><code>
kubectl get svc node-service
curl &lt;node-service-ip&gt;:5000/plusone/99
      </code></pre>
    </div>
  </li>
</ol>

<h3>Java Application</h3>
<p>
  Once the Node.js microservice is running, the Java application can be deployed using the provided CI/CD pipeline. The pipeline builds the Java app, creates a Docker image, and deploys it to Kubernetes.
</p>

<h2>Repository Structure</h2>
<ul>
  <li><code>src/</code>: Java microservice source code.</li>
  <li><code>efk/</code>: create kubernetes eks stack</li>
  <li><code>generate_kube_bench_report.py/</code>: python json parser script to convert kubench report into proper formatting.</li>
  <li><code>k8s-deployment-service/</code>: Kubernetes manifests for java app deployments for dev environment.</li>
   <li><code>k8s_PROD-deployment-service/</code>: Kubernetes manifests for java app deployments for prod environment.</li>
  <li><code>terraform-setup/</code>: AWS Infrastructure provisioning with Terraform for both eks and jenkins. Please run this commands to create the aws vpc first if intended to have jenkins server running before eks since the jenkins configuration depends on the eks state;
  <div style="background-color: #2d2d2d; padding: 10px; color: #f1f1f1; font-family: monospace; border-radius: 5px;">
      <pre><code>
      terraform apply -var-file=dev.tfvars -target= module.eks.aws_subnet.public-subnet
      terraform apply -var-file=dev.tfvars -target=module.eks.aws_subnet.public-subnet
      terraform plan -var-file=dev.tfvars
      terraform apply -var-file=dev.tfvars -target=module.eks.aws_subnet.private-subnet
      terraform apply -var-file=dev.tfvars -target=module.eks.aws_route_table_association.name
    </code></pre>
  </div>
  </li>
  <li><code>jenkins-plugins</code>: Automatic jenkins plugins installation for this project. </li>
  <li><code>integration-test.sh/</code>: Integration and rollout testing scripts for jenkins DEV/STAGING stage.</li>
  <li><code>integration-test-PROD.sh/</code>: Integration and rollout testing scripts for jenkins production stage.</li>
  <li><code>Jenkinsfile</code>: CI/CD pipeline configuration for the Java microservice.</li>
  <li><code>Dockerfile</code>: Docker image build configuration for the Java microservice.</li>
</ul>
<h2>Prerequisites</h2>
<p>
  Follow these steps to set up the environment in your Kubernetes cluster before deploying the application.
</p>

<h3>1. Install Istio and Add-ons</h3>
<div style="border: 1px solid #ddd; padding: 20px; background: #f9f9f9; border-radius: 8px;">
  <pre><code>
  curl -L https://istio.io/downloadIstio | sh -
  cd istio-1.24.2
  export PATH=$PWD/bin:$PATH
  istioctl install --set profile=demo -y && kubectl apply -f samples/addons
  </code></pre>
</div>

<h3>2. Deploy Vault</h3>
<p><strong>Step 1:</strong> Create a Namespace for Vault</p>
<div style="border: 1px solid #ddd; padding: 20px; background: #f9f9f9; border-radius: 8px;">
  <pre><code>kubectl create ns vault</code></pre>
</div>

<p><strong>Step 2:</strong> Install Vault Using Helm</p>
<div style="border: 1px solid #ddd; padding: 20px; background: #f9f9f9; border-radius: 8px;">
  <pre><code>helm install vault hashicorp/vault --namespace vault \
    --set "injector.enabled=true" \
    --set "injector.agentSidecarImagePullPolicy=Always"</code></pre>
</div>

<p><strong>Step 3:</strong> Initialize and Unseal Vault</p>
<div style="border: 1px solid #ddd; padding: 20px; background: #f9f9f9; border-radius: 8px;">
  <pre><code>kubectl exec vault-0 -n vault -- vault operator init -key-shares=1 -key-threshold=1 -format=json > init-keys.json
VAULT_UNSEAL_KEY=$(cat init-keys.json | jq -r ".unseal_keys_b64[]")
kubectl exec vault-0 -n vault -- vault operator unseal $VAULT_UNSEAL_KEY
VAULT_ROOT_TOKEN=$(cat init-keys.json | jq -r ".root_token")
kubectl exec vault-0 -n vault -- vault login $VAULT_ROOT_TOKEN</code></pre>
</div>

<p><strong>Step 4:</strong> Enable and Configure Database Secrets</p>
<div style="border: 1px solid #ddd; padding: 20px; background: #f9f9f9; border-radius: 8px;">
  <pre><code>vault secrets enable database
vault write database/config/mysql \
    plugin_name=mysql-database-plugin \
    connection_url="{{username}}:{{password}}@tcp(mysql-service.default.svc.cluster.local:3306)/" \
    allowed_roles="devsecops-role" \
    username="root" \
    password="rootpassword"
vault write database/roles/devsecops-role \
    db_name=mysql \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}'; GRANT ALL PRIVILEGES ON mysql.* TO '{{name}}'@'%';" \
    default_ttl="1h" \
    max_ttl="24h"</code></pre>
</div>

<h3>3. Configure PKI in Vault</h3>
<p><strong>Step 1:</strong> Enable PKI and Generate Certificates</p>
<div style="border: 1px solid #ddd; padding: 20px; background: #f9f9f9; border-radius: 8px;">
  <pre><code>vault secrets enable pki
vault secrets tune -max-lease-ttl=8760h pki
vault write pki/root/generate/internal \
    common_name=mydevsecopapp.com \
    ttl=8760h</code></pre>
</div>

<p><strong>Step 2:</strong> Configure Certificate Issuing URLs</p>
<div style="border: 1px solid #ddd; padding: 20px; background: #f9f9f9; border-radius: 8px;">
  <pre><code>vault write pki/config/urls \
    issuing_certificates="http://vault.vault.svc.cluster.local:8200/v1/pki/ca" \
    crl_distribution_points="http://vault.vault.svc.cluster.local:8200/v1/pki/crl"</code></pre>
</div>
<h3>4. Install Cert-Manager</h3>
<p><strong>Step 1:</strong> Install CRDs</p>
<div style="border: 1px solid #ddd; padding: 20px; background: #f9f9f9; border-radius: 8px;">
  <pre><code>kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.12.3/cert-manager.crds.yaml</code></pre>
</div>

<p><strong>Step 2:</strong> Install Cert-Manager Using Helm</p>
<div style="border: 1px solid #ddd; padding: 20px; background: #f9f9f9; border-radius: 8px;">
  <pre><code>helm install cert-manager --namespace cert-manager --version v1.12.3 jetstack/cert-manager</code></pre>
</div>

<h3>4. Configure Vault-Issuer and Certificates</h3>
<p><strong>Step 1:</strong> Create Service Account and Secret</p>
<div style="border: 1px solid #ddd; padding: 20px; background: #f9f9f9; border-radius: 8px;">
  <pre><code>kubectl create serviceaccount issuer -n istio-system
cat > issuer-secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  namespace: istio-system
  name: issuer-token-lmzpj
  annotations:
    kubernetes.io/service-account.name: issuer
type: kubernetes.io/service-account-token
EOF
kubectl apply -f issuer-secret.yaml</code></pre>
</div>

<p><strong>Step 2:</strong> Create and Apply Vault Issuer</p>
<div style="border: 1px solid #ddd; padding: 20px; background: #f9f9f9; border-radius: 8px;">
  <pre><code>cat > vault-issuer.yaml <<EOF
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  namespace: istio-system
  name: vault-issuer
spec:
  vault:
    server: http://vault.vault.svc:8200
    path: pki/sign/mydev
    auth:
      kubernetes:
        mountPath: /v1/auth/kubernetes
        role: devsecops-role
        secretRef:
          name: issuer-token-lmzpj
          key: token
EOF
kubectl apply --filename vault-issuer.yaml</code></pre>
</div>

<p><strong>Step 3:</strong> Create Certificate</p>
<div style="border: 1px solid #ddd; padding: 20px; background: #f9f9f9; border-radius: 8px;">
  <pre><code>cat > devsecops-cert.yaml <<EOF
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  namespace: istio-system
  name: mydevsecopapp.com
spec:
  secretName: devsecops
  issuerRef:
    name: vault-issuer
  commonName: www.mydevsecopapp.com
  dnsNames:
  - www.mydevsecopapp.com
EOF
kubectl apply --filename devsecops-cert.yaml</code></pre>
</div>

<p><strong>Step 4:</strong> Verify Certificate</p>
<div style="border: 1px solid #ddd; padding: 20px; background: #f9f9f9; border-radius: 8px;">
  <pre><code>kubectl describe certificate.cert-manager mydevsecopapp.com -n istio-system</code></pre>
</div>
<h3>5. Install Falco for Runtime Security</h3>
<p><strong>Step 1:</strong> Install Helm (if not installed)</p>
<div style="border: 1px solid #ddd; padding: 20px; background: #f9f9f9; border-radius: 8px;">
  <pre><code>export VERIFY_CHECKSUM=false
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
helm version</code></pre>
</div>

<p><strong>Step 2:</strong> Install Falco Using Helm</p>
<div style="border: 1px solid #ddd; padding: 20px; background: #f9f9f9; border-radius: 8px;">
  <pre><code>helm repo add falcosecurity https://falcosecurity.github.io/charts
helm install --replace falco --namespace falco --create-namespace falcosecurity/falco \
    --set falcosidekick.enabled=true \
    --set falcosidekick.webui.enabled=true \
    --set falcosidekick.config.slack.webhookurl="<YOUR_SLACK_WEBHOOK_URL>" \
    --set falcosidekick.config.customfields="environment:production, datacenter:us-east-2"</code></pre>
</div>

Jenkins Integration: Slack Notifications

The Jenkins pipeline in this project includes Slack notifications to keep you updated on pipeline status. Follow these steps to enable Slack integration:

1. Slack Setup
Workspace and Channel: Create a Slack workspace and a dedicated channel (e.g., #jenkins-alerts).
Bot Setup:
Visit the Slack API and create a new app.
Assign permissions under OAuth & Permissions:
chat:write
channels:read
groups:read
channels:join
Add the bot to your Slack channel and note the Bot User OAuth Token.
2. Jenkins Configuration
Under Manage Jenkins, configure:
Global Slack Notifier: Use the token and workspace/channel details.
Shared Library: Add the shared library named slack in Global Pipeline Libraries.
Jenkinsfile: Environment Variables

The pipeline is pre-configured with critical environment variables:

@Library('slack') _
pipeline {
  agent any
  
  environment {
    // Kubernetes Deployment Variables
    KUBE_BENCH_SCRIPT = "cis-master.sh"
    deploymentName = "devsecops"
    containerName = "devsecops-container"
    serviceName = "devsecops-svc"
    imageName = "mafike1/numeric-app:${GIT_COMMIT}"
    applicationURI = "/increment/99"
    CLUSTER_NAME = "dev-medium-eks-cluster"
    
Precautions:

Replace slack-credentials-id with your Jenkins Slack token credentials.
Modify the imageName and CLUSTER_NAME if necessary to match your environment.
<h2>Contribution Guidelines</h2>
<p>Contributions are welcome! Here’s how you can get involved:</p>
<ul>
  <li><strong>Raise Issues:</strong> Found a bug or have a suggestion? <a href="https://github.com/mafike/dev-sec-proj/issues/new">Open an issue</a>.</li>
  <li><strong>Submit Pull Requests:</strong> Fork the repository, create a branch for your feature, and submit a PR.</li>
  <li><strong>Collaborate:</strong> Contact me for deeper discussions or to propose larger contributions.</li>
</ul>

<h2>Blog Post</h2>
<p>
  For a detailed explanation of this project, its architecture, and the strategies employed, refer to the blog post: <a href="https://mafike.com/projects/">Numeric App Project Overview</a>.
</p>

<h2>Contact</h2>
<p>If you'd like to contribute, collaborate, or learn more, don’t hesitate to reach out via email or GitHub Issues.</p>
