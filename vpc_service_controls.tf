resource "google_access_context_manager_access_policy" "access-policy" {
  parent = "organizations/${var.gcp_common.org_id}"
  title  = "my policy"

  depends_on = [
    google_organization_iam_binding.organization_org_admin,
  ]
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/access_context_manager_service_perimeters
resource "google_access_context_manager_service_perimeters" "service-perimeter" {
  parent = "accessPolicies/${google_access_context_manager_access_policy.access-policy.name}"

  service_perimeters {
    name           = "accessPolicies/${google_access_context_manager_access_policy.access-policy.name}/servicePerimeters/Perimeter1"
    title          = "Service Production Perimeter1"
    perimeter_type = "PERIMETER_TYPE_REGULAR"
    status {
      restricted_services = [
        "storage.googleapis.com",
        "container.googleapis.com",         # GKE
        "containerregistry.googleapis.com", # Container Registory
        "artifactregistry.googleapis.com",  # Artifact Registry
        "monitoring.googleapis.com",        # Monitoring
        "logging.googleapis.com",           # Logging
      ]
      resources = concat([
        "projects/${google_project.host_project.number}",
        "projects/${google_project.service1.number}",
        ],
        var.vpc_sc_perimeter_internal_project_list,
      )
      access_levels = [
        google_access_context_manager_access_level.homelab.id,
        # google_access_context_manager_access_level.org_log_writer.id,
      ]
      ingress_policies {
        ingress_from {
          identities = [
            google_logging_organization_sink.all_log.writer_identity,
          ]
          sources {
            access_level = google_access_context_manager_access_level.org_log_writer.id
          }
        }
        ingress_to {
          resources = [
            var.org_aggregate_log_bucket_project_num,
          ]
          operations {
            service_name = "logging.googleapis.com"
            method_selectors {
              method = "*"
            }
          }
        }
      }
    }
  }
}

resource "google_access_context_manager_access_level" "homelab" {
  parent = "accessPolicies/${google_access_context_manager_access_policy.access-policy.name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.access-policy.name}/accessLevels/homelab"
  title  = "homelab"
  basic {
    conditions {
      ip_subnetworks = [var.vpn.peer_global_ip_address, ]
    }
    # regions = [
    #   "JP",
    # ]
  }
}

resource "google_access_context_manager_access_level" "org_log_writer" {
  parent = "accessPolicies/${google_access_context_manager_access_policy.access-policy.name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.access-policy.name}/accessLevels/org_log_writer"
  title  = "org_log_writer"
  basic {
    conditions {
      members = [google_logging_organization_sink.all_log.writer_identity, ]
    }
  }
}

# resource "google_access_context_manager_access_level" "access-level" {
#   parent = "accessPolicies/${google_access_context_manager_access_policy.access-policy.name}"
#   name   = "accessPolicies/${google_access_context_manager_access_policy.access-policy.name}/accessLevels/device_jp"
#   title  = "device-jp"
#   basic {
#     conditions {
#       device_policy {
#         require_screen_lock = true
#         os_constraints {
#           os_type = "DESKTOP_CHROME_OS"
#         }
#         os_constraints {
#           os_type = "DESKTOP_MAC"
#         }
#         os_constraints {
#           os_type = "DESKTOP_WINDOWS"
#         }
#         os_constraints {
#           os_type = "DESKTOP_LINUX"
#         }
#       }
#       regions = [
#         "JP",
#       ]
#     }
#   }
# }
