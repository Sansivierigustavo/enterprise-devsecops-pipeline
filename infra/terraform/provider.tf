terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Credenciais NAO ficam aqui - sao lidas das variaveis de ambiente
# AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY, injetadas pelo Jenkins
# a partir do Credentials Store (ver Jenkinsfile).
provider "aws" {
  region = var.aws_region
}