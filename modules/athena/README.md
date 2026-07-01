# athena

Creates an Athena workgroup with an enforced, encrypted results location and a
per-query scan limit to guard against runaway cost. The results bucket is
created and locked down (public access blocked, SSE enabled).

## Usage

```hcl
module "athena" {
  source = "../../modules/athena"

  workgroup_name      = "acme-analytics"
  results_bucket_name = "acme-analytics-athena-results-prod"
  bytes_scanned_cutoff = 21474836480 # 20 GB

  tags = {
    Owner = "platform-team"
  }
}
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| workgroup_name | Athena workgroup name | string | n/a |
| results_bucket_name | Results bucket name (globally unique) | string | n/a |
| kms_key_arn | KMS key ARN for SSE-KMS (null = SSE-S3) | string | null |
| bytes_scanned_cutoff | Per-query scan limit in bytes | number | 10737418240 |
| force_destroy | Allow destroying non-empty results bucket | bool | false |
| tags | Extra tags | map(string) | {} |

## Outputs

| Name | Description |
|------|-------------|
| workgroup_name | Athena workgroup name |
| results_bucket | Results bucket name |
| results_output_location | Enforced S3 output location |
