# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service_identity
resource "google_project_service_identity" "cloudasset_sa" {
  provider = google-beta
  project  = google_project.main.name

  service = "cloudasset.googleapis.com"
  depends_on = [
    google_project_service.main,
  ]
}
