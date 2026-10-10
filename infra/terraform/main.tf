data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "app_data" {
  # Riscos aceitos conscientemente (bucket de demonstracao, sem dados de producao):
  # checkov:skip=CKV_AWS_18: Access logging exigiria um segundo bucket so para logs, desproporcional para uma demo
  # checkov:skip=CKV_AWS_144: Replicacao cross-region e requisito de disaster recovery de producao, fora do escopo
  # checkov:skip=CKV2_AWS_62: Nao ha consumidores de eventos (SNS/SQS/Lambda) neste projeto
  bucket = "${var.bucket_name}-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_acl" "app_data_acl" {
  bucket = aws_s3_bucket.app_data.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "app_data_block" {
  bucket = aws_s3_bucket.app_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app_data_encryption" {
  bucket = aws_s3_bucket.app_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "app_data_versioning" {
  bucket = aws_s3_bucket.app_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "app_data_lifecycle" {
  bucket     = aws_s3_bucket.app_data.id
  depends_on = [aws_s3_bucket_versioning.app_data_versioning]

  rule {
    id     = "cleanup-old-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_iam_role" "app_role" {
  name = "${var.project_name}-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "app_policy" {
  name = "${var.project_name}-app-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ]
      Resource = [
        aws_s3_bucket.app_data.arn,
        "${aws_s3_bucket.app_data.arn}/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.app_role.name
  policy_arn = aws_iam_policy.app_policy.arn
}