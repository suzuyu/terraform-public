
# フォルダ IAM 設定
resource "google_folder_iam_binding" "admin" {
  folder = google_folder.folder.name
  for_each = toset([
    "roles/storage.admin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/logging.admin",
    # https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/installing/configure-sa#before_you_begin
    "roles/compute.viewer",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.securityAdmin",
    "roles/iam.serviceAccountKeyAdmin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/gkeonprem.admin",
    "roles/gkehub.viewer",
    "roles/container.viewer",
    # Monitoring 閲覧のため追加
    "roles/monitoring.viewer",
    # # https://cloud.google.com/anthos/docs/concepts/security-monitoring#required_roles
    # "roles/servicesecurityinsights.securityInsightsViewer",
    # # https://cloud.google.com/kubernetes-engine/docs/how-to/protect-workload-configuration?hl=ja#before_you_begin
    # "roles/containersecurity.viewer",

    ## https://cloud.google.com/anthos/run/docs/install/outside-gcp/prerequisites?hl=ja
    "roles/gkehub.admin",
    # https://cloud.google.com/service-mesh/docs/installation-permissions?hl=ja
    # "roles/gkehub.admin",
    # "roles/serviceusage.serviceUsageAdmin",
    # "roles/privateca.admin", # CA Service 管理者 - このロールは、CA Service と統合する場合にのみ必要です。
    "roles/container.admin",
    "roles/meshconfig.admin",
    "roles/resourcemanager.projectIamAdmin",
    # "roles/iam.serviceAccountAdmin",
    "roles/servicemanagement.admin",
    # "roles/serviceusage.serviceUsageAdmin",
    "roles/run.admin",
    # https://cloud.google.com/anthos/docs/concepts/security-monitoring?hl=ja#required_roles
    # "roles/monitoring.viewer", # Already Setting
    # "roles/logging.viewer", # Already Setting logging.admin
    # "roles/serviceusage.serviceUsageViewer", # Already Setting roles/serviceusage.serviceUsageAdmin
    "roles/servicesecurityinsights.securityInsightsViewer",
    # https://cloud.google.com/network-intelligence-center/docs/connectivity-tests/concepts/access-control?hl=ja#networkmanagement-roles
    "roles/networkmanagement.admin",
  ])

  role = each.value

  members = [
    join(":", ["group", var.admin_group_email]),
  ]
}
