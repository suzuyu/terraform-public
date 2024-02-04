# フォルダの作成
resource "google_folder" "folder" {
  display_name = var.folder_name
  parent       = data.terraform_remote_state.state.outputs.organization_service_folder_id # 組織のサービス向けフォルダ配下にフォルダを作成する
}
