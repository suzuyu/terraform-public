# ホストプロジェクトの API 管理
resource "google_project_service" "main" {
  project                    = google_project.main.id
  disable_dependent_services = true

  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "cloudidentity.googleapis.com",
    "cloudbilling.googleapis.com",
    "iam.googleapis.com",
    "monitoring.googleapis.com",
    "essentialcontacts.googleapis.com", # essentialcontacts
    "logging.googleapis.com",
    "cloudasset.googleapis.com",
  ])
  service = each.value
}
