# Day 03 - Application Containerization and Security

## Overview

Implemented application containerization using Docker and deployed the API on an Ubuntu Linux server.

## Application

Technology:
- Python 3.12
- Flask

Endpoints:

GET /
- Returns application status information

GET /health
- Health check endpoint

## Docker Implementation

Created Docker image:

enterprise-api:latest

Dockerfile features:

- Python slim base image
- Dependency installation
- Non-root container execution
- Minimal runtime configuration

## Container Security Hardening

Implemented:

- Created dedicated application user
- Removed root execution
- Added .dockerignore

Validation:

Command:

docker exec enterprise-api whoami

Result:

appuser

## Vulnerability Assessment

Tool:

Trivy Image Scanner

Command:

trivy image enterprise-api:latest

Result:

CRITICAL: 0
HIGH: 0
MEDIUM: 4
LOW: 1

Findings:

All detected vulnerabilities were related to pip package manager metadata.

Remediation will be performed in the next iteration.

## Current Architecture

Developer Machine
        |
        v
GitHub Repository
        |
        v
Ubuntu Server
        |
        v
Docker Container
        |
        v
Flask API