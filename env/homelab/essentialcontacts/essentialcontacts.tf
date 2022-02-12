# resource "google_project_service" "essentialcontacts_api_enable" {
#   project                    = google_project.target_project.id
#   disable_dependent_services = true

#   service = "essentialcontacts.googleapis.com"
# }

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/folder
data "google_folder" "infrastructure_folder" {
  folder              = var.infrastructure_folder_id
  lookup_organization = true
}

data "google_folder" "service1_folder" {
  folder = var.service1_folder_id
}


# IAM admin
## https://cloud.google.com/resource-manager/docs/managing-notification-contacts#manage-permissions
resource "google_organization_iam_binding" "org_essentialcontacts_admin" {
  org_id = split("/", data.google_folder.infrastructure_folder.organization)[1]
  role   = "roles/essentialcontacts.admin"

  members = [
    "group:${var.org_admin_group_account}",
    "serviceAccount:${var.terraform_service_accounts}",
  ]
}

# IAM viewer
## https://cloud.google.com/resource-manager/docs/managing-notification-contacts#view-permissions
resource "google_folder_iam_binding" "infra_essentialcontacts_viewer" {
  folder = data.google_folder.infrastructure_folder.id
  role   = "roles/essentialcontacts.viewer"

  members = [
    "group:${var.infrastructure_admin_group_account}",
  ]
}

resource "google_folder_iam_binding" "service1_essentialcontacts_viewer" {
  folder = data.google_folder.service1_folder.id
  role   = "roles/essentialcontacts.viewer"

  members = [
    "group:${var.service1_admin_group_account}",
  ]
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/essential_contacts_contact
# https://cloud.google.com/resource-manager/docs/managing-notification-contacts#terraform
resource "google_essential_contacts_contact" "org_contact" {
  parent                              = data.google_folder.infrastructure_folder.organization
  email                               = var.org_admin_email
  language_tag                        = "ja"                               # https://cloud.google.com/resource-manager/docs/managing-notification-contacts#expandable-1
  notification_category_subscriptions = ["BILLING", "LEGAL", "SECURITY", ] # ALL, BILLING, LEGAL, PRODUCT_UPDATES, SECURITY, SUSPENSION, TECHNICAL, TECHNICAL_INCIDENTS
}

resource "google_essential_contacts_contact" "infrastructure_contact" {
  parent                              = data.google_folder.infrastructure_folder.id
  email                               = var.infrastructure_admin_email
  language_tag                        = "ja"
  notification_category_subscriptions = ["ALL", ] # ALL, BILLING, LEGAL, PRODUCT_UPDATES, SECURITY, SUSPENSION, TECHNICAL, TECHNICAL_INCIDENTS
}

resource "google_essential_contacts_contact" "service1_contact" {
  parent                              = data.google_folder.service1_folder.id
  email                               = var.service1_admin_email
  language_tag                        = "ja"
  notification_category_subscriptions = ["ALL", ] # ALL, BILLING, LEGAL, PRODUCT_UPDATES, SECURITY, SUSPENSION, TECHNICAL, TECHNICAL_INCIDENTS
}
