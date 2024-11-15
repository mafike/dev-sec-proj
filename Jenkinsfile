@Library('slack') _
pipeline {
  agent any
  
environment {
    KUBE_BENCH_SCRIPT = "cis-master.sh"
    deploymentName = "devsecops"
    containerName = "devsecops-container"
    serviceName = "devsecops-svc"
    imageName = "mafike1/numeric-app:${GIT_COMMIT}"
    applicationURL = "http://192.168.33.11"
    applicationURI = "/increment/99"
  
}

  stages {
     stage('Build my Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //so tfhat they can be downloaded later
            }
        }   
   /*   stage('Unit Tests - JUnit and Jacoco') {
       steps {
        sh "mvn test"
        
       }
      } 
     stage('Mutation Tests - PIT') {
      steps {
        sh "mvn org.pitest:pitest-maven:mutationCoverage"
      }
    } 
    /* stage('SonarQube - SAST') {
      steps {
        withSonarQubeEnv('sonarqube') {
        sh "mvn clean verify sonar:sonar \
            -Dsonar.projectKey=numeric_app \
            -Dsonar.projectName='numeric_app' \
            -Dsonar.host.url=http://192.168.33.10:9000 "
      }
        timeout(time: 2, unit: 'MINUTES') {
          script {
            waitForQualityGate abortPipeline: true
          }
        }
      }   
     }  

     stage('Vulnerability Scan - Docker ') {
      steps {
        parallel(
          "Dependency Scan": {
            sh "mvn dependency-check:check"
          },
          "Trivy Scan": {
            sh "bash trivy-docker-image-scan.sh"
          },
          "OPA Conftest": {
            sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy dockerfile_security.rego Dockerfile'
          }
        )
      }
    } 
        stage('Docker Build and Push') {
            steps {
                // Use withCredentials to access Docker credentials
                withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    script {
                        // Print environment variables for debugging
                        sh 'printenv'
                        
                        // Log in to Docker
                        sh "echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin"
                        
                        // Build the Docker image
                        sh "docker build -t mafike1/numeric-app:${GIT_COMMIT} ."
                        
                        // Push the Docker image
                        sh "docker push mafike1/numeric-app:${GIT_COMMIT}"
                    }
                }
            }
        }  
    /* stage('Vulnerability Scan - Kubernetes') {
      steps {
        parallel(
          "OPA Scan": {
            sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
          },
          "Kubesec Scan": {
            sh "bash kubesec-scan.sh"
          },
          "Trivy Scan": {
            sh "bash trivy-k8s-scan.sh"
          }
        )
      }
    }
   /* stage('Kubernetes Deployment - DEV') {
      steps {
        withKubeConfig([credentialsId: 'kubeconfig']) {
          sh "sed -i 's#replace#mafike1/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
          sh "kubectl apply -f k8s_deployment_service.yaml --validate=false"
        }
      }
    }
  } */
     /* stage('K8S Deployment - DEV') {
      steps {
        parallel(
          "Deployment": {
            withKubeConfig([credentialsId: 'kubeconfig']) {
              sh "bash k8s-deployment.sh"
            }
          },
          "Rollout Status": {
            withKubeConfig([credentialsId: 'kubeconfig']) {
              sh "bash k8s-deployment-rollout-status.sh"
            }
          }
        )
      }
    } 
   /* stage('Integration Tests - DEV') {
      steps {
        script {
          try {
            withKubeConfig([credentialsId: 'kubeconfig']) {
              sh "bash integration-test.sh"
            }
          } catch (e) {
            withKubeConfig([credentialsId: 'kubeconfig']) {
              sh "kubectl -n default rollout undo deploy ${deploymentName}"
            }
            throw e
          }
        }
      }
    } 

  stage('OWASP ZAP - DAST') {
      steps {
        withKubeConfig([credentialsId: 'kubeconfig']) {
          sh 'bash zap.sh'
        }
      }
    }
  stage('Prompte to PROD?') {
  steps {
    timeout(time: 2, unit: 'DAYS') {
      input 'Do you want to Approve the Deployment to Production Environment/Namespace?'
    }
   }
  } */
       stage('Run CIS Benchmark') {
            steps {
        script {
            // Use the kubeconfig file credential once for all parallel tasks
            withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
                parallel(
                    "Run Master Benchmark": {
                        sh """
                        chmod +x cis-master.sh
                        KUBECONFIG_PATH=\$KUBECONFIG_FILE ./cis-master.sh
                        """
                    },
                    "Run ETCD Benchmark": {
                        sh """
                        chmod +x cis-etcd.sh
                        KUBECONFIG_PATH=\$KUBECONFIG_FILE ./cis-etcd.sh
                        """
                    },
                    "Run Kubelet Benchmark": {
                        sh """
                        chmod +x cis-kubelet.sh
                        KUBECONFIG_PATH=\$KUBECONFIG_FILE ./cis-kubelet.sh
                        """
                    },
                    "Generate HTML Report": {
                        // Run the Python script to generate the combined HTML report
                        sh """
                        if [ -f combined-bench-report.json ]; then
                            python3 generate_combined_kube_bench_report.py
                        else
                            echo "combined-bench-report.json not found. Skipping HTML report generation."
                        fi
                        """
                    }
                )
            }
        }
    }
   } 
}
    post {
     always {
     // junit 'target/surefire-reports/*.xml'
     // jacoco execPattern: 'target/jacoco.exec'
     // pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
     // dependencyCheckPublisher pattern: 'target/dependency-check-report.xml',
     // publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: 'owasp-zap-report', reportFiles: 'zap_report.html', reportName: 'OWASP ZAP HTML Report', reportTitles: 'OWASP ZAP HTML Report'])
      publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: '.', reportFiles: 'combined-kube-bench-report.html', reportName: 'Kube-Bench HTML Report', reportTitles: 'Kube-Bench HTML Report'])
      sendNotification currentBuild.result
    }
     }
    } 
    /*
    // success {

    // }

    // failure {

    // } 
  
} */
   
