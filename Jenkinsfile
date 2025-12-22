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
                sh 'echo "Running tests..."'
            }
        }
        stage('Deploy') {
            steps {
                sh 'echo "Deploying to server..."'
            }
        }
    }
    post {
        failure {
            sh 'echo "Rolling back deployment..."'
        }
    }
}

