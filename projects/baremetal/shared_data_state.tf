# 共通ステートファイルの参照
data "terraform_remote_state" "state" {
  backend   = "gcs"
  workspace = "dev" # workspace を使用している場合は指定する
  config = {
    bucket = var.terraform_state_bucket_name
    prefix = "terraform/state"
  }
}
