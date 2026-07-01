# Complete example

Deploys the full data platform: a three-layer data lake, a Glue database and
crawler over the raw layer, and an Athena workgroup for querying.

## Run

```bash
terraform init
terraform plan -var="project=acme-analytics" -var="environment=dev"
terraform apply
```

## What you get

- S3 buckets: `acme-analytics-raw-dev`, `acme-analytics-curated-dev`, `acme-analytics-analytics-dev`
- Glue database `acme_analytics_dev` and a scheduled crawler over the raw layer
- Athena workgroup `acme-analytics-dev` with an encrypted results bucket

> Note: applying this creates billable AWS resources. Run `terraform destroy`
> when you are done experimenting.
