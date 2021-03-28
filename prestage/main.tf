## 内容
# Terraform 用のプロジェクトを作成する
# 参照 https://cloud.google.com/community/tutorials/managing-gcp-projects-with-terraform
## 前提
# 組織を作成済み
# 課金アカウント作成済み
# 管理ユーザグループを admin.google で作成済み
## 組織管理者が課金アカウントへ権限付与できるようにする
# gcloud config set account [課金アカウントのアドミンアカウント]
# gcloud beta billing accounts list
# gcloud beta billing accounts add-iam-policy-binding [var.gcp_common.billing_account] --member=user:[org admin user account] --role roles/billing.admin
## 組織管理者のアカウントで gcloud コマンドを利用できるようにする
# gcloud auth login [org admin user account]
# gcloud config set account [org admin user account]
# gcloud auth application-default login
## 組織管理者が組織ポリシーを編集できるようにする
# gcloud organizations list
# gcloud organizations add-iam-policy-binding [var.gcp_common.org_id] --member=user:[org admin user account] --role=roles/orgpolicy.policyAdmin
## workspace を "dev", "prd" などにする
# terraform workspace new dev

provider "google" {}

# Terraform Project 作成
resource "google_project" "terraform" {
  name                = join("-", [var.gcp_common.org_name, var.terraform_pj.identity_name, terraform.workspace])
  project_id          = join("-", [var.gcp_common.org_name, var.terraform_pj.identity_name, terraform.workspace])
  org_id              = var.gcp_common.org_id
  billing_account     = var.gcp_common.billing_account
  auto_create_network = false
}

# Sevice API 有効化 (google_project と同じ terraform で実施が必須)
resource "google_project_service" "terraform" {
  project                    = google_project.terraform.id
  disable_dependent_services = true

  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "cloudidentity.googleapis.com",
    "cloudbilling.googleapis.com",
    "iam.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "accesscontextmanager.googleapis.com", # VPC Service Controls に必要
  ])
  service = each.value

  depends_on = [
    google_project.terraform,
  ]
}

# Terraform サービスアカウントの作成
resource "google_service_account" "terraform" {
  account_id   = "terraform"
  display_name = "Terraform IaC Account"
  project      = google_project.terraform.project_id

  depends_on = [
    google_project.terraform,
  ]
}

# Terraform へホストプロジェクトの閲覧ロールを付与
resource "google_project_iam_binding" "storage_serviceusage" {
  project = google_project.terraform.project_id
  for_each = toset([
    "roles/storage.admin",
    "roles/serviceusage.serviceUsageAdmin",
  ])

  role = each.value

  members = [
    join(":", ["serviceAccount", google_service_account.terraform.email]),
    join(":", ["group", var.admin_user_group.email]),
  ]

  depends_on = [
    google_service_account.terraform,
  ]
}

# Terraform へホストプロジェクトの閲覧ロールを付与
resource "google_project_iam_binding" "viewer" {
  project = google_project.terraform.project_id
  for_each = toset([
    "roles/viewer",
  ])

  role = each.value

  members = [
    join(":", ["serviceAccount", google_service_account.terraform.email]),
  ]

  depends_on = [
    google_service_account.terraform,
  ]
}

# Terraform へホストプロジェクトの編集ロールを付与
resource "google_project_iam_binding" "editor" {
  project = google_project.terraform.project_id
  for_each = toset([
    "roles/editor",
  ])

  role = each.value

  members = [
    join(":", ["group", var.admin_user_group.email]),
  ]

  depends_on = [
    google_service_account.terraform,
  ]
}

# Terraform へ組織内のプロジェクト作成権限を付与
resource "google_organization_iam_binding" "terraform" {
  org_id = google_project.terraform.org_id
  for_each = toset([
    "roles/resourcemanager.projectCreator",
    #    "roles/billing.projectManager",
    "roles/billing.user",
    "roles/compute.xpnAdmin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/resourcemanager.organizationAdmin",
    "roles/orgpolicy.policyAdmin",
    "roles/resourcemanager.folderAdmin",
    "roles/accesscontextmanager.policyAdmin", # VPC SC 時に必要
  ])
  role = each.value

  members = [
    join(":", ["serviceAccount", google_service_account.terraform.email]),
    join(":", ["group", var.admin_user_group.email])
  ]

  depends_on = [
    google_project.terraform,
    google_service_account.terraform,
  ]
}

# Terraform へ課金アカウントの利用権限を付与
resource "google_billing_account_iam_binding" "user" {
  billing_account_id = google_project.terraform.billing_account
  role               = "roles/billing.user"
  members = [
    join(":", ["serviceAccount", google_service_account.terraform.email]),
    join(":", ["group", var.admin_user_group.email])
  ]

  depends_on = [
    google_project.terraform,
  ]
}

# Terraform のステートファイル置き場の作成
resource "google_storage_bucket" "terraform" {
  name          = join("-", [google_project.terraform.project_id, "terraform-backet"])
  project       = google_project.terraform.project_id
  location      = "US"
  force_destroy = true
  storage_class = "STANDARD"

  lifecycle_rule {
    condition {
      num_newer_versions = 5
    }
    action {
      type = "Delete"
    }
  }

  depends_on = [
    google_project.terraform,
  ]
}


## destroy 後に、その前の状態に戻すには...
# gcloud organizations add-iam-policy-binding [var.gcp_common.org_id] --member=user:[org admin user account] --role=roles/resourcemanager.organizationAdmin
# gcloud organizations add-iam-policy-binding [var.gcp_common.org_id] --member=domain:[domain] --role=roles/billing.creator
# gcloud organizations add-iam-policy-binding [var.gcp_common.org_id] --member=domain:[domain] --role=roles/resourcemanager.projectCreator
# gcloud organizations remove-iam-policy-binding [var.gcp_common.org_id] --member=domain:[domain] --role=roles/orgpolicy.policyAdmin
