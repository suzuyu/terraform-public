output "A001_Terraform_Service_Account" {
  value       = google_service_account.terraform.email
  description = "Terraform Account"
}

output "A002_GCP_BACKEND" {
  value = join("\n", [
    "cat > backend.tf << EOF",
    "terraform {",
    "  backend \"gcs\" {",
    "    bucket = \"${google_storage_bucket.terraform.name}\"",
    "    prefix = \"terraform/state\"",
    "  }",
    "}",
    "EOF",
    "mv backend.tf ../",
  ])
}

output "A003_Next_Commands" {
  value       = join("", ["gcloud iam service-accounts keys create terraform_serviceacoount_credential.json --iam-account ", google_service_account.terraform.email, ";cp terraform_serviceacoount_credential.json ../;cd ../"])
  description = "Next"
}
