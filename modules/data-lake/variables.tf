variable "name_prefix" {
  description = "Prefix applied to every bucket name (for example the project or team name)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name_prefix))
    error_message = "name_prefix must be lowercase alphanumeric with hyphens only."
  }
}

variable "environment" {
  description = "Deployment environment, used as a suffix and tag (for example dev, staging, prod)."
  type        = string
}

variable "layers" {
  description = "Ordered list of data-lake layers to create one bucket for."
  type        = list(string)
  default     = ["raw", "curated", "analytics"]
}

variable "enable_versioning" {
  description = "Whether to enable object versioning on every layer bucket."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "Optional KMS key ARN for SSE-KMS. When null, buckets use SSE-S3 (AES256)."
  type        = string
  default     = null
}

variable "lifecycle_expiration_days" {
  description = "Expire noncurrent object versions after this many days. Set to 0 to disable lifecycle management."
  type        = number
  default     = 0
}

variable "force_destroy" {
  description = "Allow Terraform to destroy non-empty buckets. Keep false in production."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
