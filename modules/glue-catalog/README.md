# glue-catalog

Creates a Glue Data Catalog database and a crawler over an S3 target, with a
least-privilege IAM role that can read only the crawled prefix.

## Usage

```hcl
module "glue" {
  source = "../../modules/glue-catalog"

  database_name        = "acme_analytics"
  crawler_name         = "acme-raw-crawler"
  s3_target_path       = "s3://acme-analytics-raw-prod/"
  s3_target_bucket_arn = module.data_lake.bucket_arns["raw"]
  schedule             = "cron(0 2 * * ? *)"

  tags = {
    Owner = "platform-team"
  }
}
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| database_name | Glue catalog database name | string | n/a |
| crawler_name | Crawler name (derives role/policy names) | string | n/a |
| s3_target_path | S3 URI to crawl | string | n/a |
| s3_target_bucket_arn | ARN of the target bucket (scopes IAM) | string | n/a |
| schedule | Cron schedule (null = on demand) | string | null |
| tags | Extra tags | map(string) | {} |

## Outputs

| Name | Description |
|------|-------------|
| database_name | Glue database name |
| crawler_name | Glue crawler name |
| crawler_role_arn | Crawler IAM role ARN |
