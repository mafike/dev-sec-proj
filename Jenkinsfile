pipeline {
  agent any

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
    stage('Docker Build and Push') {
      steps {
          withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
            sh 'echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin docker.io'
            sh 'printenv'
            sh 'whoami'
            sh "docker build -t mafike1/numeric-app:${GIT_COMMIT} ."
            sh "docker push mafike1/numeric-app:${GIT_COMMIT}"

      }
     }
    }
  } 
}

