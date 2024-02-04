# プロジェクトの API 管理
resource "google_project_service" "main" {
  project                    = google_project.main.id
  disable_dependent_services = true

  for_each = toset([
    # https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/installing/configure-sa#enable_apis
    "anthos.googleapis.com",
    "anthosaudit.googleapis.com",
    "anthosgke.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "connectgateway.googleapis.com",
    "container.googleapis.com",
    "gkeconnect.googleapis.com",
    "gkehub.googleapis.com",
    "gkeonprem.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "opsconfigmonitoring.googleapis.com",
    "serviceusage.googleapis.com",
    "stackdriver.googleapis.com",
    "storage.googleapis.com",
    "cloudasset.googleapis.com",
    # https://cloud.google.com/kubernetes-engine/docs/how-to/protect-workload-configuration?hl=ja#before_you_begin
    "containersecurity.googleapis.com",
    # https://cloud.google.com/service-mesh/docs/unified-install/project-cluster-setup#required_apis
    "mesh.googleapis.com",
    "meshconfig.googleapis.com",
    "meshca.googleapis.com",
    # "container.googleapis.com", 
    # "gkehub.googleapis.com",
    # "monitoring.googleapis.com", 
    # "stackdriver.googleapis.com", 
    # "opsconfigmonitoring.googleapis.com", 
    # "connectgateway.googleapis.com", 
    "trafficdirector.googleapis.com",
    "networkservices.googleapis.com",
    # "networksecurity.googleapis.com", # for security posture
    "networkmanagement.googleapis.com", # Connectivity Tests で必要, Network Analyzer の対象先で有効化が必要
  ])
  service = each.value
}
