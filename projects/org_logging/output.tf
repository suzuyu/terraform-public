output "org_aggregate_log_bucket" {
  value = google_logging_project_bucket_config.logging_log_bucket.id
}
