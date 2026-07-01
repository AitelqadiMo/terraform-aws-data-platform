output "workgroup_name" {
  description = "Name of the Athena workgroup."
  value       = aws_athena_workgroup.this.name
}

output "results_bucket" {
  description = "Name of the S3 bucket storing query results."
  value       = aws_s3_bucket.results.bucket
}

output "results_output_location" {
  description = "Full S3 output location enforced by the workgroup."
  value       = "s3://${aws_s3_bucket.results.bucket}/output/"
}
