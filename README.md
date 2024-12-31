<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Numeric-App</title>
</head>
<body>
    <h1>Numeric-App</h1>
    <p>
        Welcome to <strong>Numeric-App</strong>, a DevOps-focused project showcasing advanced infrastructure automation, CI/CD pipelines, Kubernetes deployments, microservices communication, and security integration. This repository highlights professional-grade workflows for deploying and managing containerized applications in production-like environments.
    </p>

    <h2>About the Project</h2>
    <p>
        <strong>Numeric-App</strong> consists of a <em>microservice architecture</em> that includes:
        <ol>
            <li><strong>Java Microservice</strong>: The primary application built using Java.</li>
            <li><strong>Node.js Microservice</strong>: A secondary service required for the Java app to function properly.</li>
        </ol>
    </p>
    <p>The project demonstrates:</p>
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
    <p>The Node.js microservice can be run in two ways: using Docker or deploying it to Kubernetes.</p>

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
                <pre><code>kubectl get svc node-service
curl &lt;node-service-ip&gt;:5000/plusone/99</code></pre>
            </div>
        </li>
    </ol>

    <h2>Jenkins Integration: Slack Notifications</h2>
    <p>The Jenkins pipeline in this project includes Slack notifications to keep you updated on pipeline status. Follow these steps to enable Slack integration:</p>
    <h3>1. Slack Setup</h3>
    <ul>
        <li><strong>Workspace and Channel:</strong> Create a Slack workspace and a dedicated channel (e.g., #jenkins-alerts).</li>
        <li><strong>Bot Setup:</strong>
            <ol>
                <li>Visit the <a href="https://api.slack.com/apps" target="_blank">Slack API</a> and create a new app.</li>
                <li>Assign permissions under <strong>OAuth & Permissions</strong>:
                    <ul>
                        <li>chat:write</li>
                        <li>channels:read</li>
                        <li>groups:read</li>
                        <li>channels:join</li>
                    </ul>
                </li>
                <li>Add the bot to your Slack channel and note the <strong>Bot User OAuth Token</strong>.</li>
            </ol>
        </li>
    </ul>
    <h3>2. Jenkins Configuration</h3>
    <ul>
        <li><strong>Global Slack Notifier:</strong> Use the token and workspace/channel details.</li>
        <li><strong>Shared Library:</strong> Add the shared library named <code>slack</code> in <strong>Global Pipeline Libraries</strong>.</li>
    </ul>

    <h2>Jenkinsfile: Environment Variables</h2>
    <div style="background-color: #2d2d2d; padding: 10px; color: #f1f1f1; font-family: monospace; border-radius: 5px;">
        <pre><code>@Library('slack') _
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

    // Slack Notification Variables
    SLACK_CHANNEL = "#jenkins-alerts"
    SLACK_CREDENTIAL_ID = "slack-credentials-id"
  }
}</code></pre>
    </div>
    <h3>Precautions:</h3>
    <ul>
        <li>Replace <code>slack-credentials-id</code> with your Jenkins Slack token credentials.</li>
        <li>Modify the <code>imageName</code> and <code>CLUSTER_NAME</code> if necessary to match your environment.</li>
    </ul>

    <h2>Contribution Guidelines</h2>
    <p>Contributions are welcome! Here’s how you can get involved:</p>
    <ul>
        <li><strong>Raise Issues:</strong> Found a bug or have a suggestion? <a href="https://github.com/mafike/dev-sec-proj/issues/new" target="_blank">Open an issue</a>.</li>
        <li><strong>Submit Pull Requests:</strong> Fork the repository, create a branch for your feature, and submit a PR.</li>
        <li><strong>Collaborate:</strong> Contact me for deeper discussions or to propose larger contributions.</li>
    </ul>

    <h2>Blog Post</h2>
    <p>For a detailed explanation of the project, its architecture, and strategies employed, refer to the blog post: <a href="https://mafike.com/projects/" target="_blank">Numeric App Project Overview</a>.</p>

    <h2>Contact</h2>
    <p>If you'd like to contribute, collaborate, or learn more, don’t hesitate to reach out via email or GitHub Issues.</p>
</body>
</html>

