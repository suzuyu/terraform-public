terraform {
  required_version = "1.1.7"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "=4.52.0" # 2023.02.12 Latest https://registry.terraform.io/providers/hashicorp/google/4.52.0
    }
  }
  backend "gcs" {
    bucket = "xxxxxxxxxxx" # env manage terraform state bucket
    prefix = "terraform/projects/org_logging/state"       # env manage terraform state file
  }
}


provider "google" {
  # export GOOGLE_APPLICATION_CREDENTIALS=YOUR_CREDENTIALS_PATS
}
