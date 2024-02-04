
# フォルダ IAM 設定
resource "google_folder_iam_binding" "admin" {
  folder = google_folder.folder.name
  for_each = toset([
    "roles/storage.admin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/logging.admin",
  ])

  role = each.value

  members = [
    join(":", ["group", var.org_logging_admin_group_email]),
  ]
}

resource "google_project_iam_member" "logging_bucketwriter" {
  project = google_project.main.id
  role    = "roles/logging.bucketWriter"
  member  = var.all_log_writer_identity
}

resource "google_project_iam_binding" "servicenetworking_serviceagent" {
  project = google_project.main.id

  role = "roles/servicenetworking.serviceAgent"

  members = [
    "serviceAccount:service-${google_project.main.number}@gcp-sa-cloudasset.iam.gserviceaccount.com"
  ]
  depends_on = [
    google_project_service_identity.cloudasset_sa,
  ]
}

resource "google_project_iam_binding" "storage_objectadmin" {
  project = google_project.main.id

  role = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:service-${google_project.main.number}@gcp-sa-cloudasset.iam.gserviceaccount.com"
  ]
  depends_on = [
    google_project_service_identity.cloudasset_sa,
  ]
}
