pipeline {

    agent any

    parameters {
        booleanParam(
            name: 'DESTROY_INFRA_AFTER_APPLY',
            defaultValue: true,
            description: 'Se marcado, destroi a infraestrutura AWS ao final do build. Desmarque apenas para demonstracoes manuais (ex: gravacao de video) - lembre-se de destruir manualmente depois.'
        )
    }

    environment {
        IMAGE_NAME = "enterprise-devsecops-app"
        COVERAGE_THRESHOLD = "80"

        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION    = "us-east-1"
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
                        semgrep/semgrep:1.171.0 \
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
                        zricethezav/gitleaks:v8.30.1 \
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
                        aquasec/trivy:0.73.0 \
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

                    set +e
                    docker run --rm \
                        -v "$(pwd):/src" \
                        bridgecrew/checkov:3.3.9 \
                        --directory /src \
                        --output json \
                        --output-file-path /src/reports
                    CHECKOV_EXIT=$?
                    
                    set -e

                    mv reports/results_json.json reports/checkov.json

                    if [ $CHECKOV_EXIT -ne 0 ]; then
                        echo "Checkov found failed checks - failing the build."
                        exit 1
                    fi

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
                        --pull \
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
                        aquasec/trivy:0.73.0 \
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

          stage('Terraform Init & Validate') {
            steps {
                dir('infra/terraform') {
                    sh '''
                        set -e
                        terraform init -input=false
                        terraform validate
                    '''
                }
            }
        }


        stage('Infra Security - tfsec') {
            steps {
                dir('infra/terraform') {
                    sh '''
                        mkdir -p ../../reports

                        set +e
                        tfsec . --format json --out ../../reports/tfsec.json
                        TFSEC_EXIT=$?
                        set -e

                        tfsec . || true

                        if [ $TFSEC_EXIT -ne 0 ]; then
                            echo "tfsec found issues in the Terraform code - failing the build."
                            exit 1
                        fi

                        echo "tfsec Quality Gate Passed."
                    '''
                }
            }
        }


        stage('Infra Security - Checkov (Terraform)') {
            steps {
                dir('infra/terraform') {
                    sh '''
                        mkdir -p ../../reports

                        set +e
                        checkov -d . --framework terraform --output cli --output json --output-file-path console,../../reports
                        CHECKOV_TF_EXIT=$?
                        set -e

                        mv ../../reports/results_json.json ../../reports/checkov-terraform.json

                        if [ $CHECKOV_TF_EXIT -ne 0 ]; then
                            echo "Checkov found failed checks in the Terraform code - failing the build."
                            exit 1
                        fi

                        echo "Checkov (Terraform) Quality Gate Passed."
                    '''
                }
            }
        }


        stage('Terraform Plan') {
            steps {
                dir('infra/terraform') {
                    sh '''
                        set -e
                        terraform plan -input=false -out=tfplan
                    '''
                }
            }
        }


        stage('Aprovacao Manual - Infraestrutura AWS') {
            steps {
                input message: 'Scans de infraestrutura revisados e aprovados. Aplicar os recursos na AWS real?', ok: 'Aplicar'
            }
        }


        stage('Terraform Apply (AWS)') {
            steps {
                dir('infra/terraform') {
                    sh '''
                        set -e
                        terraform apply -input=false tfplan

                        echo "====================================="
                        echo "Recursos provisionados na AWS:"
                        echo "====================================="
                        terraform output
                    '''
                }
            }
        }


        stage('Terraform Destroy (AWS)') {
            when {
                expression { return params.DESTROY_INFRA_AFTER_APPLY }
            }
            steps {
                dir('infra/terraform') {
                    sh '''
                        set -e
                        terraform destroy -input=false -auto-approve
                    '''
                }
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
✔ Terraform Init & Validate
✔ Infra Security - tfsec
✔ Infra Security - Checkov (Terraform)
✔ Terraform Plan
✔ Terraform Apply (AWS)

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