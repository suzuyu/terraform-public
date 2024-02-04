# ホストプロジェクト向けフォルダ
resource "google_folder" "host_host_folder" {
  display_name = "host"
  parent       = google_folder.organization_infrastructure_folder.name

  depends_on = [
    google_folder.organization_infrastructure_folder,
  ]
}

# ホストプロジェクト作成
resource "google_project" "host_project" {
  name            = join("-", [var.gcp_common.org_name, var.host_pj.service_name, terraform.workspace])
  project_id      = join("-", [var.gcp_common.org_name, var.host_pj.service_name, terraform.workspace])
  billing_account = var.gcp_common.billing_account
  folder_id       = google_folder.host_host_folder.name

  depends_on = [
    google_folder.host_host_folder,
  ]
}

output "host_billing_account" {
  value = google_project.host_project.billing_account
}

output "host_project_id" {
  value = google_project.host_project.id
}

# ホストプロジェクトの API 管理
resource "google_project_service" "host_api_enable" {
  project                    = google_project.host_project.id
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
    google_project.host_project,
  ]
}

# フォルダ IAM 設定
resource "google_folder_iam_binding" "host_admin" {
  folder = google_folder.host_host_folder.name
  for_each = toset([
    "roles/storage.admin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/editor",
    "roles/dns.admin", #CloudDNS
  ])

  role = each.value

  members = [
    join(":", ["group", var.network_admin_group.email]),
  ]

  depends_on = [
    google_project.host_project,
  ]
}

resource "google_project_iam_binding" "host_networkUser" {
  project = google_project.host_project.id
  for_each = toset([
    "roles/compute.networkUser"
  ])

  role = each.value

  members = [
    join(":", ["group", var.network_admin_group.email]),
    join(":", ["serviceAccount", var.terraform-service-accounts]),
  ]

  depends_on = [
    google_project.host_project,
  ]
}

# 共有 VPC で GKE を作成する際に必要な権限のアサイン
## https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-shared-vpc
resource "google_project_iam_binding" "host_hostServiceAgentUser" {
  project = google_project.host_project.id
  for_each = toset([
    "roles/container.hostServiceAgentUser",
  ])

  role = each.value

  members = [
    join(":", ["serviceAccount", "service-${google_project.service1.number}@container-engine-robot.iam.gserviceaccount.com"]),
  ]

  depends_on = [
    google_project.host_project,
    google_project.service1,
  ]
}

# VPC 作成
resource "google_compute_network" "host_sharedvpc" {
  name                    = "sharedvpc"
  mtu                     = 1500
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
  project                 = google_project.host_project.name

  depends_on = [
    google_project.host_project,
  ]
}

# 共有 VPC の有効化
resource "google_compute_shared_vpc_host_project" "host" {
  project = google_project.host_project.name

  depends_on = [
    google_project.host_project,
    google_project_service.host_api_enable,
  ]
}
