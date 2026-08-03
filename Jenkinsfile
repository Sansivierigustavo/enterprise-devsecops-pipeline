pipeline {

    agent any

    environment {
        IMAGE_NAME = "enterprise-devsecops-app"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }


        stage('Python Tests') {
            steps {
                sh '''
                python3 --version
                pip3 install -r requirements.txt
                pytest -v
                '''
            }
        }


        stage('Security - Semgrep') {
            steps {
                sh '''
                docker run --rm \
                -v $(pwd):/src \
                semgrep/semgrep \
                semgrep scan --config auto /src
                '''
            }
        }


        stage('Security - Gitleaks') {
            steps {
                sh '''
                docker run --rm \
                -v $(pwd):/repo \
                zricethezav/gitleaks:latest \
                detect --source=/repo
                '''
            }
        }


        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t ${IMAGE_NAME}:latest .
                '''
            }
        }


        stage('Container Security - Trivy') {
            steps {
                sh '''
                docker run --rm \
                -v /var/run/docker.sock:/var/run/docker.sock \
                aquasec/trivy image \
                --severity HIGH,CRITICAL \
                ${IMAGE_NAME}:latest
                '''
            }
        }

    }


    post {

        success {
            echo 'DevSecOps Pipeline completed successfully'
        }

        failure {
            echo 'Pipeline failed - check logs'
        }

    }

}