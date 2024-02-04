# サービスアカウント作成
## https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/installing/configure-sa#configure_service_accounts_manually
resource "google_service_account" "anthos-baremetal-gcr" {
  account_id   = "anthos-baremetal-gcr"
  display_name = "anthos-baremetal-gcr"
  project      = google_project.main.name
}

resource "google_service_account" "anthos-baremetal-connect" {
  account_id   = "anthos-baremetal-connect"
  display_name = "anthos-baremetal-connect"
  project      = google_project.main.name
}

resource "google_service_account" "anthos-baremetal-register" {
  account_id   = "anthos-baremetal-register"
  display_name = "anthos-baremetal-register"
  project      = google_project.main.name
}

resource "google_service_account" "anthos-baremetal-cloud-ops" {
  account_id   = "anthos-baremetal-cloud-ops"
  display_name = "anthos-baremetal-cloud-ops"
  project      = google_project.main.name
}

## https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/installing/configure-sa#bucket-sa
resource "google_service_account" "anthos-baremetal-snapshotupload" {
  account_id   = "anthos-baremetal-ssupload"
  display_name = "anthos-baremetal-snapshotupload"
  project      = google_project.main.name
}

# Cloud Run for Anthos
## https://cloud.google.com/anthos/run/docs/install/outside-gcp?hl=ja#configure_your_cloudrun_custom_resource
resource "google_service_account" "cloudrun-anthos-baremetal" {
  account_id   = "cloudrun-anthos-baremetal"
  display_name = "cloudrun-anthos-baremetal"
  project      = google_project.main.name
}

