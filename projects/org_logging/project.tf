# プロジェクト作成
resource "google_project" "main" {
  name            = var.project_id
  project_id      = var.project_id
  billing_account = var.billing_account
  folder_id       = google_folder.folder.name

  depends_on = [
    google_folder.folder,
  ]
}
