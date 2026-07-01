output "data_lake_buckets" {
  description = "Map of data-lake layer to bucket name."
  value       = module.data_lake.bucket_ids
}

output "glue_database" {
  description = "Glue catalog database name."
  value       = module.glue.database_name
}

output "athena_workgroup" {
  description = "Athena workgroup name."
  value       = module.athena.workgroup_name
}

output "athena_results_location" {
  description = "S3 location where Athena writes query results."
  value       = module.athena.results_output_location
}
