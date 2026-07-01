variable "database_name" {
  description = "Name of the Glue Data Catalog database."
  type        = string
}

variable "crawler_name" {
  description = "Name of the Glue crawler (also used to derive IAM role and policy names)."
  type        = string
}

variable "s3_target_path" {
  description = "S3 URI the crawler scans, for example s3://my-bucket/raw/."
  type        = string

  validation {
    condition     = startswith(var.s3_target_path, "s3://")
    error_message = "s3_target_path must be an S3 URI starting with s3://."
  }
}

variable "s3_target_bucket_arn" {
  description = "ARN of the bucket backing s3_target_path, used to scope the crawler IAM policy."
  type        = string
}

variable "schedule" {
  description = "Optional cron schedule for the crawler (for example cron(0 2 * * ? *)). Null runs on demand."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to the crawler and IAM role."
  type        = map(string)
  default     = {}
}
