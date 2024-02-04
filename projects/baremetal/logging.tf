# log 短期閲覧用バケット
resource "google_logging_project_bucket_config" "logging_log_bucket" {
  project        = google_project.main.name
  location       = var.location
  retention_days = var.logging_retention_days
  bucket_id      = "custom-bucket"
}

# audit 系のデフォルト長期保存系以外を短期保存用バケットに入れる
resource "google_logging_project_sink" "default-log-bucket-sink" {
  project     = google_project.main.name
  name        = "default-logbucket-sink"
  description = "default logging"
  destination = "logging.googleapis.com/${google_logging_project_bucket_config.logging_log_bucket.id}"
  # same _Default
  filter                 = "NOT LOG_ID(\"cloudaudit.googleapis.com/activity\") AND NOT LOG_ID(\"externalaudit.googleapis.com/activity\") AND NOT LOG_ID(\"cloudaudit.googleapis.com/system_event\") AND NOT LOG_ID(\"externalaudit.googleapis.com/system_event\") AND NOT LOG_ID(\"cloudaudit.googleapis.com/access_transparency\") AND NOT LOG_ID(\"externalaudit.googleapis.com/access_transparency\") AND NOT LOG_ID(\"anthosgke.googleapis.com\")"
  unique_writer_identity = true
  exclusions {
    disabled = false
    filter   = <<-EOT
      protoPayload.serviceName="anthosgke.googleapis.com"
      severity=DEFAULT
    EOT
    name     = "anthos_default"
  }
}

# audit 系のデフォルト長期保存系以外を長期保存用バケットに入れる
resource "google_logging_project_sink" "default-gcs-sink" {
  project     = google_project.main.name
  name        = "default-gcs-sink"
  description = "default logging to gcs bucket"
  destination = "storage.googleapis.com/${google_storage_bucket.gs_log_bueckt.name}"
  # same _Default
  filter                 = "NOT LOG_ID(\"cloudaudit.googleapis.com/activity\") AND NOT LOG_ID(\"externalaudit.googleapis.com/activity\") AND NOT LOG_ID(\"cloudaudit.googleapis.com/system_event\") AND NOT LOG_ID(\"externalaudit.googleapis.com/system_event\") AND NOT LOG_ID(\"cloudaudit.googleapis.com/access_transparency\") AND NOT LOG_ID(\"externalaudit.googleapis.com/access_transparency\")"
  unique_writer_identity = true
  exclusions {
    disabled = false
    filter   = <<-EOT
      protoPayload.serviceName="anthosgke.googleapis.com"
      severity=DEFAULT
    EOT
    name     = "anthos_default"
  }
}
