# log 長期保存用バケット
resource "google_storage_bucket" "gs_log_bueckt" {
  project       = google_project.main.name
  name          = join("-", [google_project.main.name, "logging-bucket"])
  storage_class = var.log_storage_class
  location      = var.location
  force_destroy = true

  lifecycle_rule {
    condition {
      age = var.log_storage_delete_age
    }
    action {
      type = "Delete"
    }
  }
}
