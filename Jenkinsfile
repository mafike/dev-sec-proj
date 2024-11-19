/////// ******************************* Code for fectching Failed Stage Name ******************************* ///////
import io.jenkins.blueocean.rest.impl.pipeline.PipelineNodeGraphVisitor
import io.jenkins.blueocean.rest.impl.pipeline.FlowNodeWrapper
import org.jenkinsci.plugins.workflow.support.steps.build.RunWrapper
import org.jenkinsci.plugins.workflow.actions.ErrorAction

// Get information about all stages, including the failure cases
// Returns a list of maps: [[id, failedStageName, result, errors]]
@NonCPS
List < Map > getStageResults(RunWrapper build) {

  // Get all pipeline nodes that represent stages
  def visitor = new PipelineNodeGraphVisitor(build.rawBuild)
  def stages = visitor.pipelineNodes.findAll {
    it.type == FlowNodeWrapper.NodeType.STAGE
  }

  return stages.collect {
    stage ->

      // Get all the errors from the stage
      def errorActions = stage.getPipelineActions(ErrorAction)
    def errors = errorActions?.collect {
      it.error
    }.unique()

    return [
      id: stage.id,
      failedStageName: stage.displayName,
      result: "${stage.status.result}",
      errors: errors
    ]
  }
}

// Get information of all failed stages
@NonCPS
List < Map > getFailedStages(RunWrapper build) {
  return getStageResults(build).findAll {
    it.result == 'FAILURE'
  }
}

/////// ******************************* Code for fectching Failed Stage Name ******************************* ///////

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
              try{
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //so tfhat they can be downloaded later
            }
            catch (e){
              echo "Error building artifact: ${e.message}"
            }
        }   
        }
     stage('Unit Tests - JUnit and Jacoco') {
       steps {
        try{
        sh "mvn test"
        }
        catch (e) {
          echo "Error running unit tests: ${e.message}"
        }
       }
      } 
     stage('Mutation Tests - PIT') {
      steps {
        try {
        sh "mvn org.pitest:pitest-maven:mutationCoverage"
      }
      catch (e) {
        echo "Error running mutation tests: ${e.message}"
      }
      }
    } 
     /* stage('SonarQube - SAST') {
      steps {
      try {
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
        catch (e) {
        echo "Error running SAST Analysis test: ${e.message}"
        }
      }   
       } 
      } */

     stage('Vulnerability Scan - Docker') {
    steps {
        script {
            def errors = [:]
            parallel(
                "Dependency Scan": {
                    try {
                        sh "mvn dependency-check:check"
                    } catch (e) {
                        errors["Dependency Scan"] = e.message
                    }
                },
                "Trivy Scan": {
                    try {
                        timeout(time: 10, unit: 'MINUTES') {
                            sh "bash trivy-docker-image-scan.sh"
                        }
                    } catch (e) {
                        errors["Trivy Scan"] = e.message
                    }
                },
                "OPA Conftest": {
                    try {
                        sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy dockerfile_security.rego Dockerfile'
                    } catch (e) {
                        errors["OPA Conftest"] = e.message
                    }
                }
            )
            if (errors) {
                errors.each { key, value ->
                    echo "Error in ${key}: ${value}"
                }
                error "One or more Docker vulnerability scans failed. See logs above."
            }
        }
    }
}
        stage('Docker Build and Push') {
            steps {
                // Use withCredentials to access Docker credentials
                withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    script {
                      try {
                        // Print environment variables for debugging
                        sh 'printenv'
                        
                        // Log in to Docker
                        sh "echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin"
                        
                        // Build the Docker image
                        sh "docker build -t mafike1/numeric-app:${GIT_COMMIT} ."
                        
                        // Push the Docker image
                        sh "docker push mafike1/numeric-app:${GIT_COMMIT}"
                    }
                    catch (e) {
                      echo "Error building and pushing Docker image: ${e.message}"
                      }
                }
            }
        }  
      }
    stage('Vulnerability Scan - Kubernetes') {
    steps {
        script {
            def errors = [:]
            parallel(
                "OPA Scan": {
                    try {
                        sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
                    } catch (e) {
                        errors["OPA Scan"] = e.message
                    }
                },
                "Kubesec Scan": {
                    try {
                        timeout(time: 10, unit: 'MINUTES') {
                            sh "bash kubesec-scan.sh"
                        }
                    } catch (e) {
                        errors["Kubesec Scan"] = e.message
                    }
                },
                "Trivy Scan": {
                    try {
                        sh "bash trivy-k8s-scan.sh"
                    } catch (e) {
                        errors["Trivy Scan"] = e.message
                    }
                }
            )
            if (errors) {
                errors.each { key, value ->
                    echo "Error in ${key}: ${value}"
                }
                error "One or more Kubernetes vulnerability scans failed. See logs above."
            }
        }
    }
}
   /*stage('Kubernetes Deployment - DEV') {
      steps {
        withKubeConfig([credentialsId: 'kubeconfig']) {
          sh "sed -i 's#replace#mafike1/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
          sh "kubectl apply -f k8s_deployment_service.yaml --validate=false"
        }
      }
    } */
  
     stage('K8S Deployment - DEV') {
    steps {
        script {
            def errors = [:]
            parallel(
                "Deployment": {
                    try {
                        withKubeConfig([credentialsId: 'kubeconfig']) {
                            sh "bash k8s-deployment.sh"
                        }
                    } catch (e) {
                        errors["Deployment"] = e.message
                    }
                },
                "Rollout Status": {
                    try {
                        withKubeConfig([credentialsId: 'kubeconfig']) {
                            sh "bash k8s-deployment-rollout-status.sh"
                        }
                    } catch (e) {
                        errors["Rollout Status"] = e.message
                    }
                }
            )
            if (errors) {
                errors.each { key, value ->
                    echo "Error in ${key}: ${value}"
                }
                error "K8S Deployment - DEV stage failed. See logs above."
            }
        }
    }
}
    stage('Integration Tests - DEV') {
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
  } 
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
                        sleep 5  # Allow time for kube-bench to create the report
                            chmod +x ./combine_kube_bench_json.sh
                            ./combine_kube_bench_json.sh
                            if [ ! -s combined-bench.json ]; then
                                echo "{}" > combined-bench.json  # Generate an empty report if kube-bench fails
                            fi
                            python3 generate_kube_bench_report.py
                        """
                    }
                )
            }
        }
    }
   } 
   stage('K8S Deployment - PROD') {
    steps {
        script {
            def errors = [:]
            parallel(
                "Deployment": {
                    try {
                        withKubeConfig([credentialsId: 'kubeconfig']) {
                            sh "sed -i 's#replace#${imageName}#g' k8s_PROD-deployment_service.yaml"
                            sh "kubectl -n prod apply -f k8s_PROD-deployment_service.yaml"
                        }
                    } catch (e) {
                        errors["Deployment"] = e.message
                    }
                },
                "Rollout Status": {
                    try {
                        withKubeConfig([credentialsId: 'kubeconfig']) {
                            sh "bash k8s-PROD-deployment-rollout-status.sh"
                        }
                    } catch (e) {
                        errors["Rollout Status"] = e.message
                    }
                }
            )
            if (errors) {
                errors.each { key, value ->
                    echo "Error in ${key}: ${value}"
                }
                error "K8S Deployment - PROD stage failed. See logs above."
            }
        }
    }
}
    stage('Integration Tests - PROD') {
      steps {
        script {
          try {
            withKubeConfig([credentialsId: 'kubeconfig']) {
              sh "bash integration-test-PROD.sh"
            }
          } catch (e) {
            withKubeConfig([credentialsId: 'kubeconfig']) {
              sh "kubectl -n prod rollout undo deploy ${deploymentName}"
            }
            throw e
          }
        }
      }
    }
  }
    post {
     always {
      junit 'target/surefire-reports/*.xml'
      jacoco execPattern: 'target/jacoco.exec'
      pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
      dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
      publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: 'owasp-zap-report', reportFiles: 'zap_report.html', reportName: 'OWASP ZAP HTML Report', reportTitles: 'OWASP ZAP HTML Report'])
      publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: '.', reportFiles: 'kube-bench-combined-report.html', reportName: 'Kube-Bench HTML Report', reportTitles: 'Kube-Bench HTML Report'])
    } 
    
    
   success {
     script {
        /* Use slackNotifier.groovy from shared library and provide current build result as parameter */
        env.failedStage = "none"
        env.emoji = ":white_check_mark: :tada: :thumbsup_all:"
        sendNotification currentBuild.result
      }
    }

   failure {
      script {
        //Fetch information about  failed stage
        def failedStages = getFailedStages(currentBuild)
        env.failedStage = failedStages.failedStageName
        env.emoji = ":x: :red_circle: :sos:"
        sendNotification currentBuild.result
      }
    }
  }
}



