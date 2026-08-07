pipeline {

    agent any

    environment {
        IMAGE_NAME = "enterprise-devsecops-app"
        COVERAGE_THRESHOLD = "80"
    }

    stages {

        stage('Python Tests') {
            steps {
                sh '''
                    set -e

                    echo "====================================="
                    echo "Python Environment"
                    echo "====================================="

                    python3 --version

                    echo "====================================="
                    echo "Creating Virtual Environment"
                    echo "====================================="

                    python3 -m venv .venv
                    . .venv/bin/activate

                    echo "====================================="
                    echo "Installing Dependencies"
                    echo "====================================="

                    python -m pip install --upgrade pip
                    python -m pip install -r requirements.txt

                    echo "====================================="
                    echo "Running Tests"
                    echo "====================================="

                    python -m pytest -v
                '''
            }
        }


        stage('Coverage Quality Gate') {
            steps {
                sh '''
                    set -e

                    echo "====================================="
                    echo "Generating Coverage Report"
                    echo "====================================="

                    . .venv/bin/activate

                    python -m pytest \
                        --cov=app \
                        --cov-report=term-missing \
                        --cov-report=xml:coverage.xml \
                        --cov-fail-under=${COVERAGE_THRESHOLD}

                    echo "====================================="
                    echo "Coverage Quality Gate Passed"
                    echo "Required Coverage: ${COVERAGE_THRESHOLD}%"
                    echo "====================================="
                '''
            }
        }


        stage('Security - Semgrep SAST') {
            steps {
                sh '''
                    set -e

                    echo "====================================="
                    echo "Running Semgrep SAST Scan"
                    echo "====================================="

                    mkdir -p reports

                    docker run --rm \
                        -v "$(pwd):/src" \
                        semgrep/semgrep \
                        semgrep scan \
                        --config auto \
                        --error \
                        --json \
                        --output /src/reports/semgrep.json \
                        /src

                    echo "Semgrep Quality Gate Passed."
                '''
            }
        }


        stage('Security - Gitleaks Secrets Scan') {
            steps {
                sh '''
                    set -e

                    echo "====================================="
                    echo "Running Gitleaks Scan"
                    echo "====================================="

                    mkdir -p reports

                    docker run --rm \
                        -v "$(pwd):/repo" \
                        zricethezav/gitleaks:latest \
                        detect \
                        --source=/repo \
                        --report-format=json \
                        --report-path=/repo/reports/gitleaks.json

                    echo "Gitleaks Quality Gate Passed."
                '''
            }
        }


        stage('Security - Trivy Filesystem') {
            steps {
                sh '''
                    set -e

                    echo "====================================="
                    echo "Running Trivy Filesystem Scan"
                    echo "====================================="

                    mkdir -p reports

                    docker run --rm \
                        -v "$(pwd):/src" \
                        aquasec/trivy:latest \
                        fs \
                        --severity HIGH,CRITICAL \
                        --ignore-unfixed \
                        --exit-code 1 \
                        --format json \
                        --output /src/reports/trivy-fs.json \
                        /src

                    echo "Trivy Filesystem Quality Gate Passed."
                '''
            }
        }


        stage('Security - Checkov IaC') {
            steps {
                sh '''
                    set -e

                    echo "====================================="
                    echo "Running Checkov IaC Scan"
                    echo "====================================="

                    mkdir -p reports

                    docker run --rm \
                        -v "$(pwd):/src" \
                        bridgecrew/checkov:latest \
                        --directory /src \
                        --output json \
                        --output-file-path /src/reports/checkov.json

                    echo "Checkov Quality Gate Passed."
                '''
            }
        }


        stage('Docker Build') {
            steps {
                sh '''
                    set -e

                    echo "====================================="
                    echo "Building Docker Image"
                    echo "====================================="

                    docker build \
                        -t ${IMAGE_NAME}:latest .

                    echo "Docker image built successfully."
                '''
            }
        }


        stage('Container Security - Trivy') {
            steps {
                sh '''
                    set -e

                    echo "====================================="
                    echo "Running Trivy Container Scan"
                    echo "====================================="

                    docker run --rm \
                        -v /var/run/docker.sock:/var/run/docker.sock \
                        -v "$(pwd)/reports:/reports" \
                        aquasec/trivy:latest \
                        image \
                        --severity HIGH,CRITICAL \
                        --ignore-unfixed \
                        --exit-code 1 \
                        --format json \
                        --output /reports/trivy-image.json \
                        ${IMAGE_NAME}:latest

                    echo "Trivy Container Quality Gate Passed."
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
✔ Coverage Quality Gate
✔ SAST - Semgrep
✔ Secrets Detection - Gitleaks
✔ Filesystem Security - Trivy
✔ IaC Security - Checkov
✔ Docker Build
✔ Container Security - Trivy

Security reports generated in:
reports/

=====================================
'''
            }
        }

    }


    post {

        always {
            echo "====================================="
            echo "Archiving Security Reports"
            echo "====================================="

            archiveArtifacts artifacts: 'coverage.xml,reports/*.json',
                             allowEmptyArchive: true,
                             fingerprint: true
        }

        success {
            echo "SUCCESS: DevSecOps pipeline passed all quality gates."
        }

        failure {
            echo "FAILURE: One or more pipeline stages or quality gates failed."
            echo "Review the Jenkins console output and archived reports."
        }

    }

}