###############################################################################
# glue-catalog module
#
# Creates a Glue Data Catalog database and a crawler that indexes an S3 target,
# together with a least-privilege IAM role scoped to the crawled prefix.
###############################################################################

data "aws_partition" "current" {}

# Trust policy: only the Glue service may assume this role.
data "aws_iam_policy_document" "assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

# Least-privilege read access to just the crawled S3 location.
data "aws_iam_policy_document" "crawler" {
  statement {
    sid    = "ReadCrawledPrefix"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]
    resources = [
      var.s3_target_bucket_arn,
      "${var.s3_target_bucket_arn}/*",
    ]
  }
}

resource "aws_iam_role" "crawler" {
  name               = "${var.crawler_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = var.tags
}

# AWS-managed baseline for Glue service operations (logging, catalog access).
resource "aws_iam_role_policy_attachment" "service" {
  role       = aws_iam_role.crawler.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "crawler_s3" {
  name   = "${var.crawler_name}-s3-read"
  role   = aws_iam_role.crawler.id
  policy = data.aws_iam_policy_document.crawler.json
}

resource "aws_glue_catalog_database" "this" {
  name        = var.database_name
  description = "Data catalog database managed by terraform-aws-data-platform."
}

resource "aws_glue_crawler" "this" {
  name          = var.crawler_name
  role          = aws_iam_role.crawler.arn
  database_name = aws_glue_catalog_database.this.name
  schedule      = var.schedule
  tags          = var.tags

  s3_target {
    path = var.s3_target_path
  }

  # Keep the catalog in sync when the source schema changes.
  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }
}
