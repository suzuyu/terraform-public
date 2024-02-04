# https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/installing/configure-sa#configure_service_accounts_manually
resource "google_project_iam_binding" "gkehub_connect" {
  project = google_project.main.id

  role = "roles/gkehub.connect"

  members = [
    "serviceAccount:${google_service_account.anthos-baremetal-connect.email}",
  ]
}

resource "google_project_iam_binding" "gkehub_admin" {
  project = google_project.main.id

  role = "roles/gkehub.admin"

  members = [
    "serviceAccount:${google_service_account.anthos-baremetal-register.email}",
  ]
}
resource "google_project_iam_binding" "logging_logwriter" {
  project = google_project.main.id

  role = "roles/logging.logWriter"

  members = [
    "serviceAccount:${google_service_account.anthos-baremetal-cloud-ops.email}",
  ]
}
resource "google_project_iam_binding" "monitoring_metricwriter" {
  project = google_project.main.id

  role = "roles/monitoring.metricWriter"

  members = [
    "serviceAccount:${google_service_account.anthos-baremetal-cloud-ops.email}",
    "serviceAccount:${google_service_account.cloudrun-anthos-baremetal.email}", # # Cloud Run for Anthos
  ]
}

resource "google_project_iam_binding" "resourcemetadata_writer" {
  project = google_project.main.id

  role = "roles/stackdriver.resourceMetadata.writer"

  members = [
    "serviceAccount:${google_service_account.anthos-baremetal-cloud-ops.email}",
  ]
}

resource "google_project_iam_binding" "opsconfigmonitoring_resourcemetadata_writer" {
  project = google_project.main.id

  role = "roles/opsconfigmonitoring.resourceMetadata.writer"

  members = [
    "serviceAccount:${google_service_account.anthos-baremetal-cloud-ops.email}",
  ]
}

resource "google_project_iam_binding" "monitoring_dashboardeditor" {
  project = google_project.main.id

  role = "roles/monitoring.dashboardEditor"

  members = [
    "serviceAccount:${google_service_account.anthos-baremetal-cloud-ops.email}",
  ]
}

# https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/installing/configure-sa#bucket-sa
resource "google_project_iam_custom_role" "snapshotupload" {
  project     = google_project.main.name
  role_id     = "snapshotUpload"
  title       = "snapshotUpload"
  description = "Anthos Baremetal Snapshot Upload"
  permissions = [
    "storage.buckets.create",
    "storage.buckets.get",
    "storage.buckets.list",
    "storage.objects.create",
  ]
}

resource "google_project_iam_binding" "snapshotupload" {
  project = google_project.main.id

  role = google_project_iam_custom_role.snapshotupload.id

  members = [
    "serviceAccount:${google_service_account.anthos-baremetal-snapshotupload.email}",
  ]
}

# logging
# resource "google_project_iam_binding" "servicenetworking_serviceagent" {
#   project = google_project.main.id

#   role = "roles/servicenetworking.serviceAgent"

#   members = [
#     "serviceAccount:service-${google_project.main.number}@gcp-sa-cloudasset.iam.gserviceaccount.com"
#   ]
#   depends_on = [
#     google_project_service_identity.cloudasset,
#   ]
# }

# resource "google_project_iam_binding" "storage_objectadmin" {
#   project = google_project.main.id

#   role = "roles/storage.objectAdmin"

#   members = [
#     "serviceAccount:service-${google_project.main.number}@gcp-sa-cloudasset.iam.gserviceaccount.com"
#   ]
#   depends_on = [
#     google_project_service_identity.cloudasset,
#   ]
# }

resource "google_project_iam_binding" "storage_objectcreator" {
  project = google_project.main.id
  role    = "roles/storage.objectCreator"

  members = [
    google_logging_project_sink.default-gcs-sink.writer_identity,
  ]
}
