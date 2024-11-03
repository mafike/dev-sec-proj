pipeline {
  agent any
  environment {
        SONAR_HOST_URL = 'http://192.168.33.10:9000' // Define the environment variable
    }
  stages {
      stage('Build m Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //so tfhat they can be downloaded later
            }
        }   
      stage('Unit Tests - JUnit and Jacoco') {
       steps {
        sh "mvn test"
        
       }
       post {
        always {
          junit 'target/surefire-reports/*.xml'
          jacoco execPattern: 'target/jacoco.exec'
          }
        }
      } 
      stage('Mutation Tests - PIT') {
      steps {
        sh "mvn org.pitest:pitest-maven:mutationCoverage"
      }
      post {
        always {
          pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
        }
      }
    }
     tages {
        stage('SonarQube - SAST') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    timeout(time: 2, unit: 'MINUTES') {
                        sh """
                            mvn clean verify sonar:sonar \
                                -Dsonar.projectKey=numeric_app \
                                -Dsonar.projectName="numeric_app" \
                                -Dsonar.host.url=${SONAR_HOST_URL} // Use the environment variable
                        """
                    }
                }
                script {
                    waitForQualityGate abortPipeline: true
                }
            }   
        }
    }
      /*  stage('Docker Build and Push') {
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
        } */
    }
   }
