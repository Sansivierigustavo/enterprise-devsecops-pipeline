# Enterprise DevSecOps Pipeline

![DevSecOps](https://img.shields.io/badge/DevSecOps-Security%20Pipeline-orange)
![Docker](https://img.shields.io/badge/Docker-Containerized-blue)
![Python](https://img.shields.io/badge/Python-3.12-yellow)
![Linux](https://img.shields.io/badge/Linux-Ubuntu%2024.04-purple)

## Overview

Enterprise DevSecOps Pipeline is a hands-on security engineering project designed to simulate a real-world software delivery lifecycle, integrating development, security automation, containerization, and continuous integration practices.

The objective is to build a secure application pipeline following the DevSecOps methodology:

> Build security into every stage of the software development lifecycle.

The project demonstrates how development teams can automate security validations before deploying applications into production environments.

---

# Project Architecture

```text
Developer
    |
    v
GitHub Repository
    |
    v
GitHub Actions CI/CD
    |
    +----------------+
    | Security Tests |
    +----------------+
          |
          |
          +--> SAST Analysis (Semgrep)
          |
          +--> Secret Detection (Gitleaks)
          |
          +--> Dependency Scanning (Trivy)
          |
          +--> Container Security (Trivy Image)
          
    |
    v

Docker Build

    |
    v

Ubuntu Linux Server

    |
    v

Containerized Application
```

---

# Technologies Used

## Application

* Python 3.12
* Flask
* REST API

## Containerization

* Docker
* Docker Engine
* Dockerfile best practices

## Security Tools

* Trivy - Vulnerability scanning
* Semgrep - Static Application Security Testing (SAST)
* Gitleaks - Secrets detection

## Infrastructure

* Ubuntu Server 24.04 LTS
* Linux administration
* Git/GitHub workflow

---

# Current Features

## Application API

The project contains a Flask API with health monitoring endpoints.

### Application Status

```
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

---

### Health Check

```
GET /health
```

Example response:

```json
{
  "status": "healthy"
}
```

---

# Container Security

Security hardening was applied to the Docker image.

Implemented practices:

* Minimal Python base image (`python:3.12-slim`)
* `.dockerignore` implementation
* Non-root container execution
* Dedicated application user

Container validation:

```bash
docker exec enterprise-api whoami
```

Result:

```text
appuser
```

The application runs without root privileges following container security best practices.

---

# Vulnerability Assessment

Docker image security scanning was performed using Trivy.

Command:

```bash
trivy image enterprise-api:latest
```

Initial assessment:

```
CRITICAL: 0
HIGH: 0
MEDIUM: 4
LOW: 1
```

Findings were analyzed and will be continuously improved through the security pipeline.

---

# Project Roadmap

## Completed

* [x] Flask application creation
* [x] GitHub repository setup
* [x] Docker containerization
* [x] Linux server deployment
* [x] Container hardening
* [x] Trivy vulnerability scanning

## In Progress

* [ ] Automated security pipeline with GitHub Actions
* [ ] SAST implementation with Semgrep
* [ ] Secret scanning with Gitleaks
* [ ] Dependency security scanning
* [ ] Security gates and pipeline policies

## Future Improvements

* [ ] Jenkins CI/CD integration
* [ ] Infrastructure as Code with Terraform
* [ ] Terraform security validation with Checkov
* [ ] Kubernetes deployment
* [ ] Cloud security implementation
* [ ] Monitoring and observability integration

---

# Security Mindset

This project follows the principles of:

* Shift Left Security
* Continuous Security Validation
* Infrastructure Automation
* Least Privilege
* Secure Software Supply Chain

---

# Author

Gustavo Sansivieri

Cybersecurity Analyst | DevSecOps Enthusiast

Focused on:

* Application Security
* Cloud Security
* Security Automation
* Blue Team Engineering
* DevSecOps Practices
