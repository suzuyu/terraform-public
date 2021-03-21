# Subnet 設定
resource "google_compute_subnetwork" "service1-gce-subnets" {
  name                     = "service1-gce-subnetwork"
  ip_cidr_range            = "172.18.0.0/24"
  region                   = var.gcp_common.region
  network                  = google_compute_network.host_sharedvpc.id
  private_ip_google_access = true
  project                  = google_project.host_project.name
}

resource "google_compute_subnetwork_iam_binding" "service1-gce-subnets" {
  project    = google_compute_subnetwork.service1-gce-subnets.project
  region     = google_compute_subnetwork.service1-gce-subnets.region
  subnetwork = google_compute_subnetwork.service1-gce-subnets.name
  role       = "roles/compute.networkUser"
  members = [
    join(":", ["group", var.service1_project_admin_group.email]),
  ]
}

# # GKE Subnet 設定
# resource "google_compute_subnetwork" "service1-gke-subnet" {
#   name                     = join("-", ["gke-service1", "primary"])
#   project                  = google_project.host_project.name
#   network                  = google_compute_network.host_sharedvpc.id
#   ip_cidr_range            = "172.18.1.0/24"
#   region                   = var.gcp_common.region
#   private_ip_google_access = true

#   dynamic "secondary_ip_range" {
#     for_each = {
#       pod     = "10.2.0.0/20"
#       service = "10.2.16.0/20"
#     }
#     content {
#       range_name    = join("-", [secondary_ip_range.key, "secondary"])
#       ip_cidr_range = secondary_ip_range.value
#     }
#   }
# }

# # 共有 VPC で GKE を作成する際に必要な権限のアサイン
# ## https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-shared-vpc
# resource "google_compute_subnetwork_iam_binding" "service1-gke-subnet" {
#   project    = google_compute_subnetwork.service1-gke-subnet.project
#   region     = google_compute_subnetwork.service1-gke-subnet.region
#   subnetwork = google_compute_subnetwork.service1-gke-subnet.name
#   role       = "roles/compute.networkUser"
#   members = [
#     join(":", ["group", var.service1_project_admin_group.email]),
#     join(":", ["serviceAccount", "${google_project.service1.number}@cloudservices.gserviceaccount.com"]),
#     join(":", ["serviceAccount", "service-${google_project.service1.number}@container-engine-robot.iam.gserviceaccount.com"]),
#   ]

#   depends_on = [
#     google_compute_subnetwork.service1-gke-subnet,
#     google_project_service.service1_api_enable,
#     google_project.host_project,
#     google_project.service1,
#   ]
# }
