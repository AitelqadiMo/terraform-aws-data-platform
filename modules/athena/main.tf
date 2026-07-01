###############################################################################
# athena module
#
# Creates an Athena workgroup with an enforced, encrypted results location.
# The results bucket is created and locked down (no public access, SSE enabled).
###############################################################################

resource "aws_s3_bucket" "results" {
  bucket        = var.results_bucket_name
  force_destroy = var.force_destroy
  tags          = var.tags
}

resource "aws_s3_bucket_public_access_block" "results" {
  bucket = aws_s3_bucket.results.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "results" {
  bucket = aws_s3_bucket.results.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_arn == null ? "AES256" : "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
  }
}

resource "aws_athena_workgroup" "this" {
  name = var.workgroup_name
  tags = var.tags

  configuration {
    # Force every query to use the managed results location and limits below.
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true
    bytes_scanned_cutoff_per_query     = var.bytes_scanned_cutoff

    result_configuration {
      output_location = "s3://${aws_s3_bucket.results.bucket}/output/"

      encryption_configuration {
        encryption_option = var.kms_key_arn == null ? "SSE_S3" : "SSE_KMS"
        kms_key_arn       = var.kms_key_arn
      }
    }
  }
}
