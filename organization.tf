## 組織ポリシー
### デフォルトネットワーク作成の無効化
resource "google_organization_policy" "skipDefaultNetworkCreation" {
  org_id     = var.gcp_common.org_id
  constraint = "compute.skipDefaultNetworkCreation"

  boolean_policy {
    enforced = true
  }
}

### VM インスタンス用に許可される外部 IP を定義する
resource "google_organization_policy" "vmExternalIpAccess" {
  org_id     = var.gcp_common.org_id
  constraint = "compute.vmExternalIpAccess"

  list_policy {
    allow {
      values = [google_compute_instance.service1_gce1.id]
    }
  }
}

### 共有 VPC ホスト プロジェクトの制限
#### Service1 Floder 配下は共有 VPC を制限
resource "google_folder_organization_policy" "service1_restrictSharedVpcHostProjects" {
  folder     = google_folder.organization_service_folder.id
  constraint = "compute.restrictSharedVpcHostProjects"

  list_policy {
    allow {
      values = [google_project.host_project.id]
    }
  }
}

### Dedicated Interconnect の使用の制限
resource "google_organization_policy" "restrictDedicatedInterconnectUsage" {
  org_id     = var.gcp_common.org_id
  constraint = "compute.restrictDedicatedInterconnectUsage"

  list_policy {
    deny {
      values = ["under:${google_folder.organization_service_folder.id}"]
    }
  }
}

### Partner Interconnect の使用の制限
resource "google_organization_policy" "restrictPartnerInterconnectUsage" {
  org_id     = var.gcp_common.org_id
  constraint = "compute.restrictPartnerInterconnectUsage"

  list_policy {
    deny {
      values = ["under:${google_folder.organization_service_folder.id}"]
    }
  }
}

### VPN ピア IP の制限
resource "google_organization_policy" "restrictVpnPeerIPs" {
  org_id     = var.gcp_common.org_id
  constraint = "compute.restrictVpnPeerIPs"

  list_policy {
    allow {
      values = [var.vpn.peer_global_ip_address]
    }
  }
}

### VPC ピアリング使用量の制限
resource "google_organization_policy" "restrictVpcPeering" {
  org_id     = var.gcp_common.org_id
  constraint = "compute.restrictVpcPeering"

  list_policy {
    deny {
      values = ["under:${google_folder.organization_service_folder.id}"]
    }
  }
}

### ロードバランサの種類に基づいてロードバランサの作成を制限する
resource "google_organization_policy" "restrictLoadBalancerCreationForTypes" {
  org_id     = var.gcp_common.org_id
  constraint = "compute.restrictLoadBalancerCreationForTypes"

  list_policy {
    allow {
      values = ["is:INTERNAL_TCP_UDP", "is:INTERNAL_HTTP_HTTPS"]
    }
  }
}

### インターネット ネットワーク エンドポイント グループの無効化
resource "google_organization_policy" "disableInternetNetworkEndpointGroup" {
  org_id     = var.gcp_common.org_id
  constraint = "compute.disableInternetNetworkEndpointGroup"

  boolean_policy {
    enforced = true
  }
}

### IP アドレスの種類に基づいてプロトコル転送を制限する
resource "google_organization_policy" "restrictProtocolForwardingCreationForTypes" {
  org_id     = var.gcp_common.org_id
  constraint = "compute.restrictProtocolForwardingCreationForTypes"

  list_policy {
    allow {
      values = ["is:INTERNAL"]
    }
  }
}

### Cloud NAT の使用制限
resource "google_organization_policy" "restrictCloudNATUsage" {
  org_id     = var.gcp_common.org_id
  constraint = "compute.restrictCloudNATUsage"

  list_policy {
    deny {
      values = ["under:${google_folder.organization_service_folder.id}"]
    }
  }
}

### リソースロケーションの制限
resource "google_organization_policy" "gcp_resourceLocations" {
  org_id     = var.gcp_common.org_id
  constraint = "gcp.resourceLocations"

  list_policy {
    allow {
      values = [
        "in:asia-northeast1-locations",
        "in:asia-northeast2-locations",
        "is:ASIA1",
        "in:us-west1-locations",
        "in:us-west2-locations",
      ]
    }
  }
}

### ドメインで制限された共有
resource "google_organization_policy" "iam_allowedPolicyMemberDomains" {
  org_id     = var.gcp_common.org_id
  constraint = "iam.allowedPolicyMemberDomains"

  list_policy {
    allow {
      values = [var.google_admin_customer_id]
    }
  }
}

### ドメインで制限された共有
resource "google_organization_policy" "sql_restrictPublicIp" {
  org_id     = var.gcp_common.org_id
  constraint = "sql.restrictPublicIp"

  boolean_policy {
    enforced = true
  }
}

### 公開アクセスの防止を適用する
resource "google_organization_policy" "storage_publicAccessPrevention" {
  org_id     = var.gcp_common.org_id
  constraint = "storage.publicAccessPrevention"

  boolean_policy {
    enforced = true
  }
}

### コンシューマ向け Private Service Connect の組織全体での Google APIS 以外の無効化
resource "google_organization_policy" "disablePrivateServiceConnectCreationForConsumers" {
  org_id     = var.gcp_common.org_id
  constraint = "compute.disablePrivateServiceConnectCreationForConsumers"

  list_policy {
    deny {
      values = ["is:SERVICE_PRODUCERS"]
    }
  }
}

### コンシューマ向け Private Service Connect のサービスプロジェクトでの無効化
resource "google_folder_organization_policy" "service1_disablePrivateServiceConnectCreationForConsumers" {
  folder     = google_folder.organization_service_folder.id
  constraint = "compute.disablePrivateServiceConnectCreationForConsumers"

  list_policy {
    deny {
      values = ["is:GOOGLE_APIS", "is:SERVICE_PRODUCERS"]
    }
  }
}

### [重要な連絡先] に追加できるメールアドレスのドメインのセットを定義
resource "google_organization_policy" "essentialcontacts_allowedContactDomains" {
  org_id     = var.gcp_common.org_id
  constraint = "essentialcontacts.allowedContactDomains"

  list_policy {
    allow {
      values = var.essentinal_contacts_domains
    }
  }
}

### 許可される Google Cloud API とサービスを制限する [現状 deny と特定 API しかうまくいかない]
resource "google_folder_organization_policy" "service_serviceuser_services" {
  folder     = google_folder.organization_service_folder.id
  constraint = "serviceuser.services"

  list_policy {
    suggested_value = "compute.googleapis.com"

    deny {
      values = [
        "doubleclicksearch.googleapis.com",
        "replicapool.googleapis.com",
        "replicapoolupdater.googleapis.com",
        "resourceviews.googleapis.com",
      ]
    }
  }
}

### デフォルトのサービス アカウントに対する IAM ロールの自動付与の無効化
resource "google_organization_policy" "automaticIamGrantsForDefaultServiceAccounts" {
  org_id     = var.gcp_common.org_id
  constraint = "iam.automaticIamGrantsForDefaultServiceAccounts"

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
    "roles/axt.admin",                        # https://cloud.google.com/assured-workloads/access-transparency/docs/enable?hl=ja&authuser=1#configuring
    "roles/accessapproval.configEditor",      # https://cloud.google.com/assured-workloads/access-approval/docs/access-control?hl=ja#update-configuration
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

output "organization_infrastructure_folder_id" {
  value = google_folder.organization_infrastructure_folder.id
}

# サービス向けフォルダ
resource "google_folder" "organization_service_folder" {
  display_name = "service"
  parent       = join("/", ["organizations", var.gcp_common.org_id])

  depends_on = [
    google_organization_policy.skipDefaultNetworkCreation,
  ]
}

output "organization_service_folder_id" {
  value = google_folder.organization_service_folder.id
}
