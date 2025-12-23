pipeline {
  agent any

  stages {
    stage('Build') {
      steps {
        sh 'echo "Building application..."'
      }
    }

    stage('Test') {
      steps {
        sh '''
          echo "Running tests..."
          test -f app/index.html
        '''
      }
    }

    stage('Deploy (Blue/Green)') {
      steps {
        sh '''
          echo "Deploying with blue/green..."
          chmod +x scripts/deploy_blue_green.sh scripts/rollback.sh
          ./scripts/deploy_blue_green.sh
        '''
      }
    }
  }

  post {
    failure {
      sh '''
        echo "Rolling back deployment..."
        chmod +x scripts/rollback.sh
        ./scripts/rollback.sh || true
      '''
    }
  }
}
