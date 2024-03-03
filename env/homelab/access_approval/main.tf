terraform {
  required_version = "1.7.4"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "=5.18.0" # 2024.03.03 Latest https://registry.terraform.io/providers/hashicorp/google/5.18.0/docs
    }
  }
  backend "gcs" {
    # bucket = "XXXXX" # Terraform State Bucket Name # terraform init -backend-config=../backend.hcl
    prefix = "terraform/state/access_approval" # env manage terraform state file
  }
}


provider "google" {
  # export GOOGLE_APPLICATION_CREDENTIALS=YOUR_CREDENTIALS_PATS
}
