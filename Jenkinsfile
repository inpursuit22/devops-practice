pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/inpursuit22/devops-practice.git'
            }
        }
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

