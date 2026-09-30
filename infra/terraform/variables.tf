variable "project_name" {
  description = "Nome do projeto, usado como prefixo dos recursos"
  type        = string
  default     = "terraform-security-pipeline"
}

variable "bucket_name" {
  description = "Prefixo do nome do bucket S3 (o Account ID e adicionado automaticamente para garantir nome globalmente unico na AWS)"
  type        = string
  default     = "tsp-app-data-bucket"
}

variable "aws_region" {
  description = "Regiao AWS onde os recursos serao criados"
  type        = string
  default     = "us-east-1"
}