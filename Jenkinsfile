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
        sh 'whoami'
        
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
          withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
            sh 'printenv'
            sh "docker build -t mafike1/numeric-app:${GIT_COMMIT} ."
            sh "docker push mafike1/numeric-app:${GIT_COMMIT}"

      }
     }
    }
  } 
}

