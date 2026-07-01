output "bucket_ids" {
  description = "Map of layer name to S3 bucket ID."
  value       = { for layer, bucket in aws_s3_bucket.this : layer => bucket.id }
}

output "bucket_arns" {
  description = "Map of layer name to S3 bucket ARN."
  value       = { for layer, bucket in aws_s3_bucket.this : layer => bucket.arn }
}

output "bucket_names" {
  description = "List of all bucket names created by this module."
  value       = [for bucket in aws_s3_bucket.this : bucket.bucket]
}
