# terraform-aws-data-platform

Reusable Terraform modules for standing up an AWS data and analytics platform:
a medallion-style S3 data lake, a Glue Data Catalog with crawlers, and Athena
for serverless SQL. Built to be composed, environment-parameterised, and safe
by default (encryption on, public access off, cost guardrails in place).

I built this to mirror the kind of self-service data infrastructure I design at
work: reusable modules teams can consume without re-solving encryption, IAM, and
lifecycle policy every time.

## Architecture

```
        ┌─────────────┐      ┌──────────────┐      ┌───────────┐
  data  │  data-lake  │      │ glue-catalog │      │  athena   │
  ───▶  │ raw/curated │ ───▶ │  db+crawler  │ ───▶ │ workgroup │ ──▶ SQL
        │  analytics  │      │   over raw   │      │ (results) │
        └─────────────┘      └──────────────┘      └───────────┘
             S3                   Glue                Athena
```

## Modules

| Module | Purpose |
|--------|---------|
| [`data-lake`](modules/data-lake) | S3 buckets per layer with versioning, SSE, blocked public access, lifecycle rules |
| [`glue-catalog`](modules/glue-catalog) | Glue database + crawler + least-privilege IAM scoped to the crawled prefix |
| [`athena`](modules/athena) | Athena workgroup with enforced encrypted results and a per-query scan limit |

## Quick start

```bash
cd examples/complete
terraform init
terraform plan  -var="project=acme-analytics" -var="environment=dev"
terraform apply
```

See [`examples/complete`](examples/complete) for a full wiring of all three
modules.

## Design choices

- **Safe by default.** Every bucket blocks public access and enables SSE. Athena
  enforces its workgroup config so ad-hoc queries cannot bypass the encrypted
  results location or the scan-cost guardrail.
- **Least privilege.** The Glue crawler role can read only the exact S3 prefix
  it crawls, not the whole account.
- **Composable, not monolithic.** Each module stands alone and exposes clean
  outputs so it can be wired into existing infrastructure.
- **Parameterised by environment.** Names and tags derive from `project` and
  `environment`, so the same code deploys dev, staging, and prod.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws provider | >= 5.0 |

## CI

Every push and pull request runs `terraform fmt -check`, `terraform validate`
across the modules and example, and `tflint`. See
[`.github/workflows/terraform-ci.yml`](.github/workflows/terraform-ci.yml).

## License

MIT. See [LICENSE](LICENSE).
