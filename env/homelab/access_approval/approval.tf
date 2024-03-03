# インフラ管理フォルダ
resource "google_folder_access_approval_settings" "infrastructure_folder" {
  folder_id           = trim(data.terraform_remote_state.state.outputs.organization_infrastructure_folder_id, "folders/")
  notification_emails = var.infrastructure_email_list

  enrolled_services {
    cloud_product = "all"
  }
}

# サービス管理フォルダ
resource "google_folder_access_approval_settings" "service_folder" {
  folder_id           = trim(data.terraform_remote_state.state.outputs.organization_service_folder_id, "folders/")
  notification_emails = var.service_email_list

  enrolled_services {
    cloud_product = "all"
  }
}
