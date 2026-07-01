# data-lake

Creates the S3 storage layers for a medallion-style data lake (`raw`, `curated`,
`analytics` by default), each as its own bucket with:

- Object versioning (toggle with `enable_versioning`)
- Server-side encryption: SSE-KMS when `kms_key_arn` is set, otherwise SSE-S3
- Public access fully blocked
- Optional lifecycle expiration of noncurrent versions and abort of incomplete
  multipart uploads

## Usage

```hcl
module "data_lake" {
  source = "../../modules/data-lake"

  name_prefix               = "acme-analytics"
  environment               = "prod"
  layers                    = ["raw", "curated", "analytics"]
  enable_versioning         = true
  lifecycle_expiration_days = 90

  tags = {
    Owner = "platform-team"
  }
}
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name_prefix | Prefix for every bucket name | string | n/a |
| environment | Environment suffix and tag | string | n/a |
| layers | Layers to create a bucket for | list(string) | ["raw","curated","analytics"] |
| enable_versioning | Enable object versioning | bool | true |
| kms_key_arn | KMS key ARN for SSE-KMS (null = SSE-S3) | string | null |
| lifecycle_expiration_days | Expire noncurrent versions after N days (0 = off) | number | 0 |
| force_destroy | Allow destroying non-empty buckets | bool | false |
| tags | Extra tags | map(string) | {} |

## Outputs

| Name | Description |
|------|-------------|
| bucket_ids | Map of layer to bucket ID |
| bucket_arns | Map of layer to bucket ARN |
| bucket_names | List of all bucket names |
