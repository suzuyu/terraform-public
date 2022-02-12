# org_id (下記で出力される "ID" を "org_id" の値にする)
## gcloud organizations list
# billing_account (下記で出力される "ACCOUNT_ID" を "billing_account" の値にする)
## gcloud beta billing accounts list
# gcp-terraform-admin@[xxx.xxx]
## 組織で使用するドメイン(xxx.xxx)の Cloud Identity で事前に Terraform 管理ユーザグループのアカウントグループを作成しておく(同じ権限にして切り分けよう)
# org_name
## 組織の識別子、プロジェクトの命名に必要なだけで何でも良い
# [xxx.xxx:ドメイン名], domain
## 環境のドメイン名(例：example.com)を入力する

variable "gcp_common" {
  type = object({
    org_name        = string
    org_id          = string
    billing_account = string
    region          = string
    zone            = string
  })
  default = {
    org_name        = "xxxxxx"
    org_id          = "xxxxxxxxxxxx"
    billing_account = "xxxxxx-xxxxxx-xxxxxx"
    region          = "us-west1"
    zone            = "us-west1-b"
  }

  validation {
    condition     = (length(regexall(var.gcp_common.region, var.gcp_common.zone)) > 0)
    error_message = "Zone must be in region."
  }
}

variable "terraform-service-accounts" {
  type    = string
  default = "terraform@[terraform管理プロジェクト名].iam.gserviceaccount.com"
}

variable "organization_admin_group" {
  type = object({
    email = string
  })
  default = {
    email = "gcp-organization-admin@[xxx.xxx:ドメイン名]"
  }
}

variable "network_admin_group" {
  type = object({
    email = string
  })
  default = {
    email = "gcp-network-admin@[xxx.xxx:ドメイン名]"
  }
}

variable "host_project_admin_group" {
  type = object({
    email = string
  })
  default = {
    email = "gcp-network-admin@[xxx.xxx:ドメイン名]"
  }
}

variable "service1_project_admin_group" {
  type = object({
    email = string
  })
  default = {
    email = "gcp-service1-admin@[xxx.xxx:ドメイン名]"
  }
}

variable "host_pj" {
  type = object({
    service_name = string
  })
  default = {
    # 命名規則: A-Z, a-z, 0-9 のみ
    service_name = "host"
  }
}

variable "service1_pj" {
  type = object({
    service_name    = string
    gke_master_ipv4 = string
  })
  default = {
    # 命名規則: A-Z, a-z, 0-9 のみ
    service_name    = "service1"
    gke_master_ipv4 = "172.18.2.0/28"
  }
}

variable "domain" {
  type    = string
  default = "xxx.xxx"
}

variable "gce_ssh" {
  type = object({
    user             = string
    pub_ssh_key_file = string
  })
  default = {
    user             = "xxxxx"
    pub_ssh_key_file = "id_rsa.pub"
  }
}


variable "vpn" {
  type = object({
    peer_global_ip_address  = string
    peer_private_ip_address = string
    shared_secret           = string
    peer_asn                = number
    asn                     = number
  })
  default = {
    peer_global_ip_address  = "自宅ラボ側グローバルIP"
    peer_private_ip_address = "自宅ラボ側ルータ プライベートIP"
    shared_secret           = "シークレット(右コメントで生成)" # openssl rand -base64 24
    peer_asn                = 65001
    asn                     = 65101
  }
}


variable "essentinal_contacts_domains" {
  type    = list(string)
  default = ["@xxx.xxx"]
}
