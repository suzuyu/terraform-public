# ステートファイルの参照
data "terraform_remote_state" "state" {
  backend   = "gcs"
  workspace = var.organization_terraform_state_workspace # workspace を使用している場合は指定する. workspace を使用してない場合は指定不要
  config = {
    bucket = var.organization_terraform_state_bucket_name # 参照する GCS を指定する
    prefix = var.organization_terraform_state_prefix      # 参照する Terraform が指定している prefix を記載する
  }
}
