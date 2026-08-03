# Day 05 - Jenkins CI/CD Pipeline Integration

## Objective

Integrate Jenkins into the Enterprise DevSecOps Pipeline, creating a self-hosted CI/CD environment capable of automatically executing security validations.

## Environment

Server:
- Ubuntu 24.04 LTS

Tools:
- Jenkins 2.568.1
- Java 21
- Docker Engine
- Python 3.12
- Git

## Architecture

Developer
    |
    v
GitHub Repository
    |
    v
Jenkins Pipeline
    |
    +--> Python Tests
    |
    +--> Semgrep SAST
    |
    +--> Gitleaks Secret Detection
    |
    +--> Docker Build
    |
    +--> Trivy Container Scan


## Jenkins Pipeline Stages

### Python Tests

The pipeline creates an isolated Python virtual environment:

- python3 -m venv
- pip install requirements
- pytest execution

Result:

2 tests passed successfully.


### Semgrep SAST

Static Application Security Testing was integrated using Semgrep to identify insecure coding patterns.


### Gitleaks

Implemented secret scanning to detect accidentally exposed credentials or sensitive information.


### Docker Security

The pipeline automatically builds the application container image.


### Trivy

Container vulnerability scanning was implemented to identify HIGH and CRITICAL vulnerabilities.


## Challenges Solved

### Jenkins Java Compatibility

Problem:

Jenkins required Java 21.

Solution:

Installed OpenJDK 21.


### Python PEP 668

Problem:

Ubuntu 24.04 blocks global pip installations.

Solution:

Created isolated Python virtual environment during pipeline execution.


### Docker Permission

Problem:

Jenkins user could not access Docker daemon.

Solution:

Added Jenkins user to docker group.


## Final Result

The Enterprise DevSecOps Pipeline now supports:

- Automated testing
- Static code analysis
- Secret detection
- Container build
- Container vulnerability scanning

Pipeline status:

SUCCESS ✅