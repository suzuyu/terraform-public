# Cloud NAT
## NAT Router
resource "google_compute_router" "nat_router" {
  name    = "nat-router"
  project = google_project.host_project.name
  region  = var.gcp_common.region
  network = google_compute_network.host_sharedvpc.self_link

  depends_on = [
    google_project.host_project,
  ]
}

## CloudNAT
resource "google_compute_router_nat" "nat" {
  name                               = "nat-router-nat"
  project                            = google_project.host_project.name
  region                             = var.gcp_common.region
  router                             = google_compute_router.nat_router.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  dynamic "subnetwork" {
    for_each = {
      service1-gce-subnets = google_compute_subnetwork.service1-gce-subnets.id
    }
    content {
      name                    = subnetwork.value
      source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    }
  }
  depends_on = [
    google_compute_router.nat_router,
  ]
}
