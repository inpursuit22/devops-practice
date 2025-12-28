pipeline {
  agent any

  options {
    timestamps()
    disableConcurrentBuilds()
  }

  parameters {
    choice(name: 'RELEASE_VERSION', choices: ['v1', 'v2'], description: 'Version to deploy')
    booleanParam(name: 'INJECT_FAILURE', defaultValue: true, description: 'Simulate a production failure after deploy')
  }

  environment {
    // If you use AWS credentials or profile, keep it consistent with your Terraform setup.
    TF_IN_AUTOMATION = "true"
    TF_INPUT = "false"

    // Where we store "last known good" version in the workspace.
    LAST_GOOD_FILE = "last_known_good_version.txt"
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Terraform Init/Plan') {
      steps {
        sh '''
          terraform init
          terraform plan -out=tfplan
        '''
      }
    }

    stage('Manual Approval') {
      steps {
        input message: "Approve infra/app deploy?", ok: "Deploy"
      }
    }

    stage('Terraform Apply') {
      steps {
        sh 'terraform apply -auto-approve tfplan'
      }
    }

    stage('Discover Instance IP') {
      steps {
        script {
          // You need an output like `output "public_ip" { value = aws_instance.web.public_ip }`
          // If you don't have it yet, add it (I’ll show you below).
          env.INSTANCE_IP = sh(script: "terraform output -raw public_ip", returnStdout: true).trim()
          echo "Target instance IP: ${env.INSTANCE_IP}"
        }
      }
    }

    stage('Deploy Release') {
      steps {
        script {
          // Read last good version if it exists; default to v1
          def lastGood = fileExists(env.LAST_GOOD_FILE) ? readFile(env.LAST_GOOD_FILE).trim() : "v1"
          echo "Last known good: ${lastGood}"

          // Deploy selected version
          echo "Deploying ${params.RELEASE_VERSION}..."
          sh """
            ssh -o StrictHostKeyChecking=no ec2-user@${env.INSTANCE_IP} 'sudo bash -lc "
              if [ \\"${params.RELEASE_VERSION}\\" = \\"v1\\" ]; then
                echo Version 1 | sudo tee /usr/share/nginx/html/index.html >/dev/null
              else
                echo Version 2 | sudo tee /usr/share/nginx/html/index.html >/dev/null
              fi
              sudo systemctl restart nginx
            "'
          """
        }
      }
    }

    stage('Health Check') {
      steps {
        script {
          // Basic health check: ensure page contains expected version
          def expected = (params.RELEASE_VERSION == 'v1') ? "Version 1" : "Version 2"

          // Optional failure injection
          if (params.INJECT_FAILURE) {
            echo "FAILURE INJECTION enabled: simulating outage"
            sh "exit 1"
          }

          // If not injecting failure, do the real check
          sh """
            curl -s http://${env.INSTANCE_IP}/ | grep -q '${expected}'
          """
          echo "Health check passed."
        }
      }
    }
  }

  post {
    failure {
      script {
        echo "INCIDENT: Deployment failed or health check failed. Starting automatic rollback..."

        // Determine rollback target
        def rollbackTarget = fileExists(env.LAST_GOOD_FILE) ? readFile(env.LAST_GOOD_FILE).trim() : "v1"
        echo "Rolling back to: ${rollbackTarget}"

        // Rollback action
        sh """
          ssh -o StrictHostKeyChecking=no ec2-user@${env.INSTANCE_IP} 'sudo bash -lc "
            if [ \\"${rollbackTarget}\\" = \\"v1\\" ]; then
              echo Version 1 | sudo tee /usr/share/nginx/html/index.html >/dev/null
            else
              echo Version 2 | sudo tee /usr/share/nginx/html/index.html >/dev/null
            fi
            sudo systemctl restart nginx
          "'
        """

        // Notification (echo-style)
        echo "[NOTIFY] Deployment incident detected. Rolled back to ${rollbackTarget}. Please review Jenkins logs for timeline and root cause."
      }
    }

    success {
      script {
        // Update last known good version after a successful run
        writeFile file: env.LAST_GOOD_FILE, text: "${params.RELEASE_VERSION}\n"
        archiveArtifacts artifacts: env.LAST_GOOD_FILE, allowEmptyArchive: false
        echo "Updated last known good version to ${params.RELEASE_VERSION}"
      }
    }

    always {
      echo "Run complete."
    }
  }
}
