# プロジェクト作成
resource "google_project" "main" {
  name            = var.project_id
  project_id      = var.project_id
  billing_account = data.terraform_remote_state.state.outputs.host_billing_account # SharedVPC のプロジェクトと同じ課金アカウントを使用する
  folder_id       = google_folder.folder.name

  depends_on = [
    google_folder.folder,
  ]
}

output "google_project_id" {
  value = google_project.main.id
}
