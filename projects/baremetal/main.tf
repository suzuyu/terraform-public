terraform {
  required_version = "1.1.7"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "=4.67.0" # 2023.06.04 Latest https://registry.terraform.io/providers/hashicorp/google/4.67.0
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "=4.67.0" # 2023.06.04 Latest https://registry.terraform.io/providers/hashicorp/google/4.67.0
    }
  }
  backend "gcs" {
    # bucket = "XXXXX" # Terraform State Bucket Name # terraform init -backend-config=../../backend.hcl
    prefix = "terraform/projects/baremetal/state" # env manage terraform state file
  }
}


provider "google" {
  # export GOOGLE_APPLICATION_CREDENTIALS=YOUR_CREDENTIALS_PATS
}
