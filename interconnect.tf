# # Router
# resource "google_compute_router" "interconnect" {
#   count   = 2
#   name    = "my-router-${count.index + 1}"
#   network = google_compute_network.host_sharedvpc.name
#   project = google_project.host_project.name
#   region  = var.gcp_common.region
#   bgp {
#     asn               = 16550
#     advertise_mode    = "CUSTOM"
#     advertised_groups = ["ALL_SUBNETS"]
#     dynamic "advertised_ip_ranges" {
#       for_each = {
#         privategoogle    = "199.36.153.8/30"
#         restrictedgoogle = "199.36.153.4/30"
#       }
#       content {
#         range = advertised_ip_ranges.value
#       }
#     }
#   }
# }

# resource "google_compute_interconnect_attachment" "on_prem" {
#   count = 2
#   # mtu                      = 1500
#   name                     = "my-interconnect-${count.index + 1}"
#   router                   = element(google_compute_router.interconnect.*.self_link, count.index)
#   type                     = "PARTNER"
#   edge_availability_domain = "AVAILABILITY_DOMAIN_${count.index + 1}"
#   project                  = google_project.host_project.name
#   region                   = element(google_compute_router.interconnect.*.region, count.index)
# }

# output "pairing_key1" {
#   value = google_compute_interconnect_attachment.on_prem.0.pairing_key
# }

# output "pairing_key2" {
#   value = google_compute_interconnect_attachment.on_prem.1.pairing_key
# }
