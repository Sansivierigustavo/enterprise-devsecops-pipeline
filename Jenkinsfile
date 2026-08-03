pipeline {

    agent any

    environment {
        IMAGE_NAME = "enterprise-devsecops-app"
    }

    stages {

        stage('Python Tests') {
            steps {
                sh '''
                echo "=== Python Environment ==="

                python3 --version

                echo "=== Creating Virtual Environment ==="

                python3 -m venv .venv

                . .venv/bin/activate

                echo "=== Installing Dependencies ==="

                pip install --upgrade pip

                pip install -r requirements.txt

                echo "=== Running Tests ==="

                pytest -v
                '''
            }
        }


        stage('Security - Semgrep SAST') {
            steps {
                sh '''
                echo "=== Running Semgrep SAST Scan ==="

                docker run --rm \
                -v $(pwd):/src \
                semgrep/semgrep \
                semgrep scan --config auto /src
                '''
            }
        }


        stage('Security - Gitleaks Secrets Scan') {
            steps {
                sh '''
                echo "=== Running Gitleaks Scan ==="

                docker run --rm \
                -v $(pwd):/repo \
                zricethezav/gitleaks:latest \
                detect \
                --source=/repo
                '''
            }
        }


        stage('Docker Build') {
            steps {
                sh '''
                echo "=== Building Docker Image ==="

                docker build \
                -t ${IMAGE_NAME}:latest .
                '''
            }
        }


        stage('Container Security - Trivy') {
            steps {
                sh '''
                echo "=== Running Trivy Container Scan ==="

                docker run --rm \
                -v /var/run/docker.sock:/var/run/docker.sock \
                aquasec/trivy:latest \
                image \
                --severity HIGH,CRITICAL \
                --ignore-unfixed \
                ${IMAGE_NAME}:latest
                '''
            }
        }


        stage('Pipeline Summary') {
            steps {
                echo '''
                =====================================
                DevSecOps Pipeline Completed
                =====================================

                ✔ Python Tests
                ✔ SAST - Semgrep
                ✔ Secrets Detection - Gitleaks
                ✔ Docker Build
                ✔ Container Security - Trivy

                '''
            }
        }

    }


    post {

        success {
            echo "SUCCESS: Security pipeline passed"
        }


        failure {
            echo "FAILURE: Review pipeline logs"
        }

    }

}