## 前提
# prestage実施済
## plan/apply前に実施
# terraform init
# terraform workspace new dev

provider "google" {
  credentials = file("terraform_serviceacoount_credential.json")
  #  user_project_override = true
}

# provider "google-beta" {
#   credentials = file("terraform_serviceacoount_credential.json")
# }
