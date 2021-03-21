resource "google_access_context_manager_access_policy" "access-policy" {
  parent = "organizations/${var.gcp_common.org_id}"
  title  = "my policy"

  depends_on = [
    google_organization_iam_binding.organization_org_admin,
  ]
}

resource "google_access_context_manager_service_perimeters" "service-perimeter" {
  parent = "accessPolicies/${google_access_context_manager_access_policy.access-policy.name}"

  service_perimeters {
    name           = "accessPolicies/${google_access_context_manager_access_policy.access-policy.name}/servicePerimeters/Perimeter1"
    title          = "Service Production Perimeter1"
    perimeter_type = "PERIMETER_TYPE_REGULAR"
    status {
      restricted_services = ["storage.googleapis.com"]
      resources = [
        "projects/${google_project.host_project.number}",
        "projects/${google_project.service1.number}",
      ]
    }
  }
}
