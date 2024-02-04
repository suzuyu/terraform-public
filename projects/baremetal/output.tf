
output "anthos-baremetal-gcr" {
  value       = join("", ["gcloud --project ${google_project.main.name} iam service-accounts keys create anthos-baremetal-gcr.json --iam-account ", google_service_account.anthos-baremetal-gcr.email])
  description = "Service Account for Anthos anthos-baremetal-gcr"
}

output "anthos-baremetal-connect" {
  value       = join("", ["gcloud --project ${google_project.main.name} iam service-accounts keys create connect-agent.json --iam-account ", google_service_account.anthos-baremetal-connect.email])
  description = "Service Account for Anthos anthos-baremetal-connect"
}

output "anthos-baremetal-register" {
  value       = join("", ["gcloud --project ${google_project.main.name} iam service-accounts keys create connect-register.json --iam-account ", google_service_account.anthos-baremetal-register.email])
  description = "Service Account for Anthos anthos-baremetal-register"
}

output "anthos-baremetal-cloud-ops" {
  value       = join("", ["gcloud --project ${google_project.main.name} iam service-accounts keys create anthos-baremetal-cloud-ops.json --iam-account ", google_service_account.anthos-baremetal-cloud-ops.email])
  description = "Service Account for Anthos anthos-baremetal-cloud-ops"
}

# https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/installing/configure-sa#bucket-sa
output "anthos-baremetal-snapshotupload" {
  value       = join("", ["gcloud --project ${google_project.main.name} iam service-accounts keys create anthos-baremetal-ssupload.json --iam-account ", google_service_account.anthos-baremetal-snapshotupload.email])
  description = "Service Account for Anthos anthos-baremetal-snapshotupload"
}

# Cloud Run for Anthos
output "cloudrun-anthos-baremetal" {
  value       = join("", ["gcloud --project ${google_project.main.name} iam service-accounts keys create cloudrun-anthos-baremetal.json --iam-account ", google_service_account.cloudrun-anthos-baremetal.email])
  description = "Service Account for Anthos Cloud Run cloudrun-anthos-baremetal"
}
