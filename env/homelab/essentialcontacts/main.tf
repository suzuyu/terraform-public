provider "google" {
}

provider "google-beta" {
}

terraform {
  backend "gcs" {
    bucket = "xxxx" # Your Terraofmr State GCS Bucket
    prefix = "homelab/essentialcontacts"
  }
}
