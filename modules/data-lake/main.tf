###############################################################################
# data-lake module
#
# Provisions the S3 storage layers for a medallion-style data lake
# (raw -> curated -> analytics) with encryption, versioning, blocked public
# access, and optional lifecycle expiration. One bucket per layer.
###############################################################################

locals {
  # Deterministic, unique bucket name per layer.
  buckets = {
    for layer in var.layers :
    layer => "${var.name_prefix}-${layer}-${var.environment}"
  }
}

resource "aws_s3_bucket" "this" {
  for_each = local.buckets

  bucket        = each.value
  force_destroy = var.force_destroy

  tags = merge(
    var.tags,
    {
      Layer       = each.key
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      # Use KMS when a key is supplied, otherwise fall back to SSE-S3.
      sse_algorithm     = var.kms_key_arn == null ? "AES256" : "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
    bucket_key_enabled = var.kms_key_arn != null
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  # Only manage a lifecycle rule when an expiration window is requested.
  for_each = var.lifecycle_expiration_days > 0 ? aws_s3_bucket.this : {}

  bucket = each.value.id

  rule {
    id     = "expire-noncurrent-and-incomplete"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = var.lifecycle_expiration_days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
