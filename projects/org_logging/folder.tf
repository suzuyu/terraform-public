# 組織ログ管理向けフォルダ
resource "google_folder" "folder" {
  display_name = var.folder_name
  parent       = var.parent_folder_name
}
