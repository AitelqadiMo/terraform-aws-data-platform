###############################################################################
# Complete example
#
# Wires the three modules into a working data platform:
#   data-lake (raw/curated/analytics) -> glue-catalog (crawl raw) -> athena
###############################################################################

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  name_prefix = "${var.project}-${var.environment}"

  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

module "data_lake" {
  source = "../../modules/data-lake"

  name_prefix               = var.project
  environment               = var.environment
  layers                    = ["raw", "curated", "analytics"]
  enable_versioning         = true
  lifecycle_expiration_days = 90

  tags = local.common_tags
}

module "glue" {
  source = "../../modules/glue-catalog"

  database_name        = replace("${var.project}_${var.environment}", "-", "_")
  crawler_name         = "${local.name_prefix}-raw-crawler"
  s3_target_path       = "s3://${module.data_lake.bucket_ids["raw"]}/"
  s3_target_bucket_arn = module.data_lake.bucket_arns["raw"]
  schedule             = "cron(0 2 * * ? *)"

  tags = local.common_tags
}

module "athena" {
  source = "../../modules/athena"

  workgroup_name      = local.name_prefix
  results_bucket_name = "${local.name_prefix}-athena-results"

  tags = local.common_tags
}
