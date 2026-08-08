# Enterprise DevSecOps Pipeline

A hands-on DevSecOps project demonstrating the integration of automated software testing, security controls, quality gates, containerization, and CI/CD orchestration using Jenkins.

The project implements security validation throughout the software delivery lifecycle, combining application testing, static analysis, secrets detection, vulnerability scanning, Dockerfile security analysis, containerization, and container vulnerability assessment.

The primary goal is to demonstrate how security controls can be integrated into an automated CI/CD pipeline rather than being performed only after application development.

---

## Overview

The pipeline follows a security-oriented software delivery workflow:

```text
Developer
    |
    v
Git Repository
    |
    v
Jenkins CI/CD
    |
    +--------------------------+
    | Automated Validation     |
    +--------------------------+
               |
               +--> Python Tests
               |
               +--> Coverage Quality Gate
               |
               +--> SAST - Semgrep
               |
               +--> Secrets Detection - Gitleaks
               |
               +--> Filesystem Security - Trivy
               |
               +--> IaC / Dockerfile Security - Checkov
               |
               v
          Docker Build
               |
               v
       Container Security
          Trivy Image
               |
               v
        Secure Container
```

The pipeline is designed around the principle of **Shift Left Security**, moving security validation as close as possible to the development and build process.

---

# Architecture

```text
                         +-------------------+
                         |     Developer     |
                         +---------+---------+
                                   |
                                   v
                         +-------------------+
                         |   Git Repository  |
                         +---------+---------+
                                   |
                                   v
                         +-------------------+
                         |      Jenkins      |
                         |      CI/CD        |
                         +---------+---------+
                                   |
              +--------------------+--------------------+
              |                    |                    |
              v                    v                    v
       Python Tests         Security Scanning      Quality Gates
              |                    |                    |
              |          +---------+---------+          |
              |          |         |         |          |
              |          v         v         v          |
              |       Semgrep   Gitleaks   Trivy       |
              |                                |
              |                              Checkov
              |                                |
              +----------------+---------------+
                               |
                               v
                        +-------------+
                        | Docker Build |
                        +------+------+
                               |
                               v
                     +--------------------+
                     |  Trivy Image Scan  |
                     +---------+----------+
                               |
                               v
                     +--------------------+
                     | Containerized App  |
                     +--------------------+
```

---

# Technology Stack

| Category                          | Technology     |
| --------------------------------- | -------------- |
| Application                       | Python 3.12    |
| Web Framework                     | Flask          |
| Testing                           | Pytest         |
| Coverage                          | Pytest-Cov     |
| Version Control                   | Git            |
| Repository                        | GitHub         |
| CI/CD                             | Jenkins        |
| Containerization                  | Docker         |
| SAST                              | Semgrep        |
| Secrets Detection                 | Gitleaks       |
| Filesystem Vulnerability Scanning | Trivy          |
| Container Vulnerability Scanning  | Trivy          |
| IaC / Dockerfile Security         | Checkov        |
| Operating System                  | Linux / Ubuntu |

---

# Application

The application is implemented using Python and Flask.

The main application is located at:

```text
app/main.py
```

Tests are located at:

```text
tests/test_app.py
```

The application exposes HTTP endpoints used for basic application and runtime validation.

## Application Status

```http
GET /
```

Example response:

```json
{
  "application": "Enterprise DevSecOps Pipeline",
  "status": "running",
  "version": "1.0.0"
}
```

## Health Check

```http
GET /health
```

Example response:

```json
{
  "status": "healthy"
}
```

---

# CI/CD Pipeline

Jenkins is responsible for orchestrating the complete security pipeline.

The current pipeline contains the following stages:

```text
1. Python Tests
2. Coverage Quality Gate
3. Security - Semgrep SAST
4. Security - Gitleaks Secrets Scan
5. Security - Trivy Filesystem
6. Security - Checkov IaC
7. Docker Build
8. Container Security - Trivy
9. Pipeline Summary
```

Each stage has a specific responsibility and can prevent the pipeline from progressing when its quality or security requirements are not satisfied.

---

# Security Controls

## 1. Python Tests

Pytest is used to validate application behavior before security scanning and containerization.

The pipeline executes:

```bash
python -m pytest -v
```

Current test suite:

```text
2 tests
2 passed
```

---

## 2. Coverage Quality Gate

The project uses Pytest-Cov to enforce a minimum code coverage threshold.

Current threshold:

```text
80%
```

The pipeline executes:

```bash
python -m pytest \
    --cov=app \
    --cov-report=term-missing \
    --cov-report=xml:coverage.xml \
    --cov-fail-under=${COVERAGE_THRESHOLD}
```

The pipeline will fail if coverage falls below the defined threshold.

This prevents a reduction in test coverage from silently reaching subsequent stages.

---

## 3. Semgrep — SAST

Semgrep performs Static Application Security Testing against the application source code.

Purpose:

* Detect insecure coding patterns
* Identify potential security vulnerabilities
* Integrate source-code security analysis into CI/CD

The scan generates:

```text
reports/semgrep.json
```

The pipeline uses Semgrep as a security quality gate.

---

## 4. Gitleaks — Secrets Detection

Gitleaks scans the repository for potentially exposed credentials and secrets.

The scan is designed to detect accidental exposure of sensitive information such as:

* API keys
* Access tokens
* Passwords
* Credentials
* Private keys

The report is generated at:

```text
reports/gitleaks.json
```

A detected secret can prevent the pipeline from continuing.

---

## 5. Trivy — Filesystem Security

Trivy scans the project filesystem for known vulnerabilities.

The pipeline evaluates:

```text
HIGH
CRITICAL
```

and ignores vulnerabilities that currently have no available fix.

Configuration:

```bash
--severity HIGH,CRITICAL
--ignore-unfixed
--exit-code 1
```

The generated report is:

```text
reports/trivy-fs.json
```

---

## 6. Checkov — Dockerfile Security

Checkov is used to evaluate infrastructure and container configuration security.

In this project, the Dockerfile is an important security boundary.

The analysis validates controls such as:

* Non-root container execution
* Secure user configuration
* Safe working directory
* Avoidance of unnecessary privileged configuration
* Avoidance of insecure base-image practices
* Network exposure considerations
* Secure container configuration

The generated report is:

```text
reports/checkov.json
```

Checkov is integrated into the CI/CD pipeline as a security quality gate.

---

## 7. Docker Build

After application and security validation, Jenkins builds the application image.

Image:

```text
enterprise-devsecops-app:latest
```

Build command:

```bash
docker build \
    -t enterprise-devsecops-app:latest .
```

The Docker build represents the transition from source code to the deployable application artifact.

---

## 8. Trivy — Container Security

After the Docker image is built, Trivy scans the final container image.

The scan evaluates:

```text
HIGH
CRITICAL
```

vulnerabilities and ignores currently unfixed findings.

The report is generated at:

```text
reports/trivy-image.json
```

This creates an additional security control after containerization.

The distinction is important:

```text
Filesystem Scan
       |
       v
Source / project dependencies
       |
       v
Docker Build
       |
       v
Container Image
       |
       v
Container Image Scan
```

This allows the pipeline to validate both the project before build and the final artifact after build.

---

# Container Security

The Docker image follows container security best practices.

The Dockerfile uses:

```dockerfile
FROM python:3.12-slim
```

A dedicated application user is created:

```dockerfile
RUN useradd --create-home appuser
```

The container switches away from root:

```dockerfile
USER appuser
```

The application uses:

```text
WORKDIR /app
```

and exposes:

```text
5000
```

The goal is to follow the principle of least privilege and avoid running the application as root.

---

# Dockerfile

The Dockerfile is intentionally minimal:

```dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY app/ .

RUN useradd --create-home appuser

USER appuser

EXPOSE 5000
```

Security considerations include:

* Slim base image
* Non-root execution
* Dedicated application user
* Absolute working directory
* Minimal runtime footprint
* No unnecessary privileged user
* Dockerfile security validation through Checkov

---

# Quality Gates

The pipeline uses security and quality gates to prevent vulnerable or invalid artifacts from progressing.

```text
                 Pipeline
                    |
                    v
              Python Tests
                    |
                 PASS?
                 /    \
               NO      YES
               |        |
             STOP       v
                  Coverage Gate
                       |
                    PASS?
                    /    \
                  NO      YES
                  |        |
                STOP       v
                      Security Scans
                           |
                    +------+------+
                    |             |
                  FAIL          PASS
                    |             |
                  STOP            v
                         Docker Build
                              |
                              v
                       Container Scan
                              |
                           PASS?
                         /       \
                       NO         YES
                       |           |
                     STOP        SUCCESS
```

This ensures that later stages depend on the success of previous controls.

---

# Security Reports

The pipeline generates machine-readable reports.

Expected reports:

```text
coverage.xml
reports/
├── semgrep.json
├── gitleaks.json
├── trivy-fs.json
├── checkov.json
└── trivy-image.json
```

Jenkins archives the generated reports after the pipeline execution.

These reports provide traceability for the security controls executed during the build.

---

# Project Structure

```text
enterprise-devsecops-pipeline/
│
├── .github/
│   └── workflows/
│       └── security-pipeline.yml
│
├── app/
│   └── main.py
│
├── tests/
│   └── test_app.py
│
├── reports/
│
├── .gitignore
├── Dockerfile
├── Jenkinsfile
├── pytest.ini
├── requirements.txt
└── README.md
```

> The GitHub Actions workflow is retained as part of the project's development history, while the current CI/CD orchestration is performed by Jenkins.

---

# Running Locally

## Create the virtual environment

Windows PowerShell:

```powershell
python -m venv .venv
```

Activate:

```powershell
.\.venv\Scripts\Activate.ps1
```

Install dependencies:

```powershell
python -m pip install -r requirements.txt
```

Run tests:

```powershell
python -m pytest -v
```

Run coverage:

```powershell
python -m pytest --cov=app --cov-report=term-missing
```

---

# Running with Docker

Build the image:

```bash
docker build -t enterprise-devsecops-app:latest .
```

Run the container:

```bash
docker run -d \
    --name enterprise-devsecops-app \
    -p 5000:5000 \
    enterprise-devsecops-app:latest
```

Verify the container:

```bash
docker ps
```

Validate the application:

```bash
curl http://localhost:5000/
```

Health endpoint:

```bash
curl http://localhost:5000/health
```

---

# Running the CI/CD Pipeline

The pipeline is executed through Jenkins.

The Jenkinsfile orchestrates:

```text
Tests
  ↓
Coverage
  ↓
SAST
  ↓
Secrets Detection
  ↓
Filesystem Security
  ↓
Dockerfile Security
  ↓
Docker Build
  ↓
Container Security
```

The pipeline should only be considered successful when all required quality gates pass.

Expected final state:

```text
Finished: SUCCESS
```

---

# Engineering Decisions

Several implementation decisions were made to keep the project focused on practical DevSecOps engineering.

### Security gates instead of passive scanning

Security tools are integrated directly into the CI/CD flow instead of being executed manually after development.

### Non-root container

The application does not run as root inside the container.

### Multiple security layers

Different scanners address different attack surfaces:

```text
Source Code
    → Semgrep

Repository Secrets
    → Gitleaks

Filesystem / Dependencies
    → Trivy

Dockerfile Configuration
    → Checkov

Final Container Image
    → Trivy
```

### Automated quality control

Pytest and coverage prevent security automation from becoming detached from application quality.

---

# Lessons Demonstrated

This project demonstrates practical experience with:

* DevSecOps pipeline design
* CI/CD security integration
* SAST implementation
* Secrets detection
* Vulnerability management
* Docker security
* Container security
* Security quality gates
* Automated testing
* Code coverage enforcement
* Jenkins pipeline orchestration
* Security report generation
* Least privilege
* Shift Left Security

---

# Known Limitations

This project intentionally focuses on the CI/CD and application security lifecycle.

It does not currently implement:

* Kubernetes orchestration
* Terraform infrastructure provisioning
* Cloud deployment
* Production secrets management
* Full observability stack
* Enterprise artifact repository
* Production-grade deployment strategy

These are outside the current scope of the portfolio project.

---

# Project Status

The project is considered a **completed portfolio implementation** of a DevSecOps security pipeline.

The focus is on demonstrating the integration of security controls into the software delivery process rather than reproducing an entire enterprise production environment.

---

# Author

**Gustavo Sansivieri**

Cybersecurity Analyst | DevSecOps

Areas of interest:

* DevSecOps
* Application Security
* Cloud Security
* Security Automation
* Blue Team Engineering
* CI/CD Security
* Container Security
