# org_id (下記で出力される "ID" を "org_id" の値にする)
## gcloud organizations list
# billing_account (下記で出力される "ACCOUNT_ID" を "billing_account" の値にする)
## gcloud beta billing accounts list
# gcp-terraform-admin@[xxx.xxx]
## 組織で使用するドメイン(xxx.xxx)の Cloud Identity で事前に Terraform 管理ユーザグループのアカウントグループを作成しておく(同じ権限にして切り分けよう)
# org_name
## 組織の識別子、プロジェクトの命名に必要なだけで何でも良い

variable "gcp_common" {
  type = object({
    org_name        = string
    org_id          = string
    billing_account = string
  })
  default = {
    org_name        = "xxxxxx"
    org_id          = "xxxxxxxxxxxx"
    billing_account = "xxxxxx-xxxxxx-xxxxxx"
  }
}

variable "admin_user_group" {
  type = object({
    email = string
  })
  default = {
    email = "gcp-terraform-admin@[xxx.xxx]"
  }
}

variable "terraform_pj" {
  type = object({
    identity_name = string
  })
  default = {
    identity_name = "terraformadmin"
  }
}
