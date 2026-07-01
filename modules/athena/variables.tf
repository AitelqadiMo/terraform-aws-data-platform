variable "workgroup_name" {
  description = "Name of the Athena workgroup."
  type        = string
}

variable "results_bucket_name" {
  description = "Globally unique name for the S3 bucket that stores query results."
  type        = string
}

variable "kms_key_arn" {
  description = "Optional KMS key ARN for SSE-KMS on results. When null, SSE-S3 is used."
  type        = string
  default     = null
}

variable "bytes_scanned_cutoff" {
  description = "Per-query data scan limit in bytes (guardrail against runaway cost). Minimum 10 MB."
  type        = number
  default     = 10737418240 # 10 GB

  validation {
    condition     = var.bytes_scanned_cutoff >= 10485760
    error_message = "bytes_scanned_cutoff must be at least 10485760 bytes (10 MB)."
  }
}

variable "force_destroy" {
  description = "Allow Terraform to destroy the non-empty results bucket. Keep false in production."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to the workgroup and results bucket."
  type        = map(string)
  default     = {}
}
