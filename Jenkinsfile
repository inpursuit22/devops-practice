pipeline {
  agent any

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Smoke Test') {
      steps {
        sh 'echo "Jenkins pipeline is running!"'
      }
    }
  }
}
