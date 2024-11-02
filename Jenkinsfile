pipeline {
  agent any

  stages {
      stage('Build m Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //so tfhat they can be downloaded later
            }
        }   
   /*   stage('Unit Tests - JUnit and Jacoco') {
       steps {
        sh "mvn test"
        sh 'whoami'
        
       }
       post {
        always {
          junit 'target/surefire-reports/*.xml'
          jacoco execPattern: 'target/jacoco.exec'
        }
      }
    } */
    stage('Docker Build and Push') {
    steps {
                // Print environment variables for debugging
                sh 'printenv'
                
                // Build the Docker image
                sh "docker build -t mafike1/numeric-app:${GIT_COMMIT} ."
                
                // Push the Docker image
                sh "docker push mafike1/numeric-app:${GIT_COMMIT}"
            }
        }
     
   
  }
}
