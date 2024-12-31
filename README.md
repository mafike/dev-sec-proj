Numeric-App

Welcome to Numeric-App, a DevOps-focused project showcasing advanced infrastructure automation, CI/CD pipelines, Kubernetes deployments, microservices communication, and security integration. This repository highlights professional-grade workflows for deploying and managing containerized applications in production-like environments.

About the Project

Numeric-App consists of a microservice architecture that includes:

Java Microservice: The primary application built using Java.
Node.js Microservice: A secondary service required for the Java app to function properly.
The project demonstrates:

Infrastructure Automation: Terraform for scalable infrastructure provisioning.
CI/CD Pipelines: Automated pipelines built with Jenkins.
Microservice Communication: Kubernetes and Docker setup to establish communication between services.
Security Integration: Automated compliance checks with tools like Trivy, Kube-Bench, and OPA.
Important Note: Before running the Java application pipeline, ensure the Node.js microservice is running. The Java app depends on the Node.js service for its functionality.

Microservice Setup

Node.js Microservice
The Node.js microservice can be run in two ways: using Docker or deploying it to Kubernetes.

Docker Setup

To run the Node.js microservice locally using Docker:

docker run -p 8787:5000 mafike1/node-app:latest
Verify the service is running by executing:

curl localhost:8787/plusone/99
You should see the expected response from the microservice.

Kubernetes Deployment

To deploy the Node.js microservice in Kubernetes:

Create a deployment:
kubectl create deploy node-app --image mafike1/node-app:latest
Expose the service within the cluster:
kubectl expose deploy node-app --name node-service --port 5000 --type ClusterIP
Verify the service is running by obtaining the service IP and querying the endpoint:
# Get the service IP
kubectl get svc node-service

# Replace <node-service-ip> with the ClusterIP from the above command
curl <node-service-ip>:5000/plusone/99
Java Application
Once the Node.js microservice is running, the Java application can be deployed. This repository includes the pipeline for building and deploying the Java microservice.

The pipeline builds the Java app using Maven, creates a Docker image, and deploys it to Kubernetes.
The Java app will communicate with the Node.js microservice to provide its functionality.
Repository Structure

src/: Java microservice source code.
k8s-deployment/: Kubernetes manifests for Java and Node.js deployments.
security-scripts/: Security and compliance scanning scripts.
terraform/: Infrastructure provisioning with Terraform.
integration-tests/: Integration and rollout testing scripts.
Jenkinsfile: CI/CD pipeline configuration for the Java microservice.
Dockerfile: Docker image build configuration for the Java microservice.
Getting Started

Clone the repository:
git clone https://github.com/yourusername/numeric-app.git
cd numeric-app
Ensure the Node.js microservice is running (see instructions above).
Run the pipeline to build and deploy the Java application using the provided Jenkinsfile.
Contribution Guidelines

Contributions are welcome! Here’s how you can get involved:

Raise Issues: Found a bug or have a suggestion? Open an issue.
Submit Pull Requests: Fork the repository, create a branch for your feature, and submit a PR.
Collaborate: Contact me for deeper discussions or to propose larger contributions.
For inquiries, feedback, or collaboration opportunities, feel free to send a message.

Future Enhancements

Full integration of Helm for optimized Kubernetes deployment.
Istio service mesh for advanced traffic management (e.g., circuit breaking, fault injection).
Enhanced monitoring with Prometheus and Grafana.
Additional security integrations with Falco and policy enforcement tools.
Blog Post

For a detailed explanation of this project, its architecture, and the strategies employed, refer to the blog post:
Numeric App Project Overview

Contact

If you'd like to contribute, collaborate, or learn more, don’t hesitate to reach out via email or GitHub Issues.