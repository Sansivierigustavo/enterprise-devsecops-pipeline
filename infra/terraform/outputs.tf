output "bucket_name" {
  value = aws_s3_bucket.app_data.id
}

output "iam_role_arn" {
  value = aws_iam_role.app_role.arn
}

output "iam_policy_arn" {
  value = aws_iam_policy.app_policy.arn
}