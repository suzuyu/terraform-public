## 組織ポリシー
### デフォルトネットワーク作成の無効化
resource "google_organization_policy" "skipDefaultNetworkCreation" {
  org_id     = var.gcp_common.org_id
  constraint = "compute.skipDefaultNetworkCreation"

  boolean_policy {
    enforced = true
  }
}

# ドメインユーザに組織・フォルダ構成の閲覧権限付与
resource "google_organization_iam_binding" "organization_domain_viewer" {
  org_id = var.gcp_common.org_id
  for_each = toset([
    "roles/resourcemanager.organizationViewer",
    "roles/resourcemanager.folderViewer",
  ])
  role = each.value

  members = [
    join(":", ["domain", var.domain]),
  ]
}

# 組織管理者への管理権限付与
resource "google_organization_iam_binding" "organization_org_admin" {
  org_id = var.gcp_common.org_id
  for_each = toset([
    "roles/resourcemanager.organizationAdmin",
    "roles/billing.admin",
    "roles/resourcemanager.folderAdmin",
    "roles/resourcemanager.projectCreator",
    "roles/iam.organizationRoleAdmin",
    "roles/orgpolicy.policyAdmin",            # 組織ポリシー管理者
    "roles/accesscontextmanager.policyAdmin", # VPC SC 時に必要
  ])
  role = each.value

  members = [
    join(":", ["group", var.organization_admin_group.email]),
    join(":", ["serviceAccount", var.terraform-service-accounts]),
  ]

  # 削除すると管理者が削除されてしまうので偶発的な破壊を防ぐ
  # 全体を削除する場合は、管理系を手動で逃してあげる必要がある
  lifecycle {
    prevent_destroy = true
    # ignore_changes = all
  }
}

# ネットワーク管理者への共有VPC等の権限付与
resource "google_organization_iam_binding" "organization_network_admin" {
  org_id = var.gcp_common.org_id
  for_each = toset([
    "roles/compute.networkAdmin",
    "roles/compute.xpnAdmin",
    "roles/compute.securityAdmin",
  ])
  role = each.value

  members = [
    join(":", ["group", var.network_admin_group.email]),
    join(":", ["serviceAccount", var.terraform-service-accounts]),
  ]
}

# インフラ向けフォルダ
resource "google_folder" "organization_infrastructure_folder" {
  display_name = "infrastructure"
  parent       = join("/", ["organizations", var.gcp_common.org_id])

  depends_on = [
    google_organization_policy.skipDefaultNetworkCreation,
  ]
}

# サービス向けフォルダ
resource "google_folder" "organization_service_folder" {
  display_name = "service"
  parent       = join("/", ["organizations", var.gcp_common.org_id])

  depends_on = [
    google_organization_policy.skipDefaultNetworkCreation,
  ]
}
