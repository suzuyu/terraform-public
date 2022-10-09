# # GKE
# resource "google_container_cluster" "servie1_gke" {
#   # provider        = google-beta
#   # networking_mode = "VPC_NATIVE"
#   name       = join("-", [var.service1_pj.service_name, "gke-cluster"])
#   location   = var.gcp_common.region
#   project    = google_project.service1.name
#   network    = google_compute_network.host_sharedvpc.id
#   subnetwork = google_compute_subnetwork.service1-gke-subnet.id

#   release_channel {
#     channel = "STABLE"
#   }

#   # remove_default_node_pool = true
#   initial_node_count = 1


#   ip_allocation_policy {
#     cluster_secondary_range_name  = google_compute_subnetwork.service1-gke-subnet.secondary_ip_range[0].range_name
#     services_secondary_range_name = google_compute_subnetwork.service1-gke-subnet.secondary_ip_range[1].range_name
#   }

#   private_cluster_config {
#     enable_private_endpoint = "true"
#     enable_private_nodes    = "true"
#     master_ipv4_cidr_block  = var.service1_pj.gke_master_ipv4
#   }

#   master_authorized_networks_config {
#     dynamic "cidr_blocks" {
#       for_each = {
#         private1 = "192.168.0.0/16"
#       }
#       content {
#         cidr_block   = cidr_blocks.value
#         display_name = cidr_blocks.key
#       }
#     }
#   }

#   workload_identity_config {
#     identity_namespace = "${google_project.service1.name}.svc.id.goog"
#   }

#   depends_on = [
#     google_compute_subnetwork_iam_binding.service1-gke-subnet,
#     google_project_iam_binding.host_hostServiceAgentUser,
#     google_compute_subnetwork_iam_binding.service1-gke-subnet,
#     google_project_iam_binding.service1_editor,
#   ]
# }
