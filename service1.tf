## フォルダ作成
resource "google_folder" "service1" {
  display_name = "service1"
  parent       = google_folder.organization_service_folder.name

  depends_on = [
    google_folder.organization_service_folder,
  ]
}

## サービス1プロジェクト作成
resource "google_project" "service1" {
  name       = join("-", [var.gcp_common.org_name, var.service1_pj.service_name, terraform.workspace])
  project_id = join("-", [var.gcp_common.org_name, var.service1_pj.service_name, terraform.workspace])
  #  org_id          = var.gcp_common.org_id
  billing_account = var.gcp_common.billing_account
  folder_id       = google_folder.service1.name

  depends_on = [
    google_folder.service1,
  ]
}


# サービス1プロジェクトの API 管理
resource "google_project_service" "service1_api_enable" {
  project                    = google_project.service1.id
  disable_dependent_services = true

  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "cloudidentity.googleapis.com",
    "cloudbilling.googleapis.com",
    "iam.googleapis.com",
    "compute.googleapis.com",              # ShareVPC 有効化時に必要
    "container.googleapis.com",            # Subnet を Kubernetes で利用させるときにホスト側でも必要
    "dns.googleapis.com",                  # CloudDNS
    "accesscontextmanager.googleapis.com", # VPC Service Controls に必要
    "essentialcontacts.googleapis.com",    # essentialcontacts

  ])
  service = each.value
  depends_on = [
    google_project.service1,
  ]
}

# IAM 設定
resource "google_folder_iam_binding" "service1_admin" {
  folder = google_folder.service1.name
  for_each = toset([
    "roles/storage.admin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/container.admin",
    "roles/container.clusterAdmin",
  ])

  role = each.value

  members = [
    join(":", ["group", var.service1_project_admin_group.email]),
  ]

  depends_on = [
    google_project.service1,
  ]
}

# デフォルトで editor role があるサービスアカウントの明記
resource "google_project_iam_binding" "service1_editor" {
  project = google_project.service1.id
  for_each = toset([
    "roles/editor",
  ])

  role = each.value

  members = [
    join(":", ["group", var.service1_project_admin_group.email]),
    join(":", ["serviceAccount", "${google_project.service1.number}@cloudservices.gserviceaccount.com"]),                      # GKE など実施するアカウント、デフォルト作成アカウント、削除防止
    join(":", ["serviceAccount", "service-${google_project.service1.number}@container-engine-robot.iam.gserviceaccount.com"]), # GKE など実施するアカウント、デフォルト作成アカウント、削除防止
  ]

  depends_on = [
    google_project.service1,
    google_project_service.service1_api_enable,
  ]
}

resource "google_project_iam_binding" "service1_compute_instanceadmin_v1" {
  project = google_project.service1.id

  role = "roles/compute.instanceAdmin.v1"

  members = [
    "serviceAccount:service-${google_project.service1.number}@compute-system.iam.gserviceaccount.com"
  ]
}


# サービスプロジェクト設定
resource "google_compute_shared_vpc_service_project" "service1" {
  host_project    = google_project.host_project.name
  service_project = google_project.service1.name

  depends_on = [
    google_project_service.service1_api_enable,
    google_compute_shared_vpc_host_project.host,
  ]
}

# サービスアカウント
## Public 向け
resource "google_service_account" "service1_public_account" {
  account_id   = "service1-public-account-id"
  display_name = "Service1 Public Account"
  project      = google_project.service1.name
}
## Private 向け
resource "google_service_account" "service1_private_account" {
  account_id   = "service1-private-account-id"
  display_name = "Service1 Private Account"
  project      = google_project.service1.name
}
