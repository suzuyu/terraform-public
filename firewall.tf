resource "google_compute_firewall" "private-permit" {
  name        = "private-private-001"
  description = "Private Subnet Permit"
  network     = google_compute_network.host_sharedvpc.name
  priority    = 1000
  direction   = "INGRESS"
  project     = google_project.host_project.name

  source_ranges = ["192.168.0.0/16", "172.16.0.0/12", "10.0.0.0/8"]
  target_service_accounts = [
    google_service_account.service1_public_account.email,
    google_service_account.service1_private_account.email,
  ]


  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  depends_on = [
    google_compute_network.host_sharedvpc,
    google_project_service.host_api_enable,
    google_service_account.service1_public_account,
    google_service_account.service1_private_account,
  ]

}

resource "google_compute_firewall" "softbank-mobile" {
  name        = "internet-public-001"
  description = "Softbank Moible Global Address Permit"
  network     = google_compute_network.host_sharedvpc.name
  priority    = 1000
  direction   = "INGRESS"
  project     = google_project.host_project.name
  # https://www.support.softbankmobile.co.jp/partner/home_tech1/index.cfm
  # 2021.03.20 時点
  source_ranges = [
    "123.108.237.128/28",
    "123.108.239.240/28",
    "126.32.80.0/21",
    "126.32.88.0/24",
    "126.32.90.0/23",
    "126.32.92.0/23",
    "126.34.0.0/18",
    "126.34.96.0/19",
    "126.133.192.0/18",
    "126.152.152.0/21",
    "126.152.160.0/21",
    "126.152.168.0/21",
    "126.152.176.0/21",
    "126.152.184.0/21",
    "126.156.128.0/19",
    "126.156.160.0/19",
    "126.156.192.0/19",
    "126.156.224.0/19",
    "126.157.64.0/20",
    "126.157.80.0/20",
    "126.157.96.0/20",
    "126.157.112.0/20",
    "126.157.128.0/20",
    "126.157.144.0/20",
    "126.157.160.0/20",
    "126.157.176.0/20",
    "126.157.192.0/20",
    "126.157.208.0/20",
    "126.157.224.0/20",
    "126.157.240.0/20",
    "126.158.0.0/19",
    "126.158.32.0/19",
    "126.158.64.0/19",
    "126.158.96.0/19",
    "126.158.128.0/19",
    "126.158.160.0/19",
    "126.158.192.0/19",
    "126.158.224.0/19",
    "126.161.0.0/20",
    "126.161.16.0/23",
    "126.161.18.0/23",
    "126.161.20.0/23",
    "126.161.22.0/23",
    "126.161.24.0/23",
    "126.161.26.0/23",
    "126.161.28.0/23",
    "126.161.30.0/23",
    "126.161.32.0/20",
    "126.161.48.0/23",
    "126.161.50.0/23",
    "126.161.52.0/23",
    "126.161.54.0/23",
    "126.161.56.0/23",
    "126.161.58.0/23",
    "126.161.60.0/23",
    "126.161.62.0/23",
    "126.161.64.0/21",
    "126.161.80.0/21",
    "126.161.96.0/19",
    "126.161.104.0/22",
    "126.166.128.0/19",
    "126.166.160.0/19",
    "126.166.192.0/19",
    "126.166.224.0/19",
    "126.167.216.0/21",
    "126.167.64.0/20",
    "126.167.80.0/20",
    "126.167.96.0/20",
    "126.167.112.0/20",
    "126.179.0.0/18",
    "126.179.96.0/19",
    "126.179.128.0/18",
    "126.179.224.0/19",
    "126.186.32.0/19",
    "126.186.96.0/19",
    "126.186.128.0/21",
    "126.186.136.0/21",
    "126.186.144.0/21",
    "126.186.152.0/21",
    "126.186.160.0/21",
    "126.186.168.0/21",
    "126.186.176.0/21",
    "126.186.184.0/21",
    "126.193.128.0/18",
    "126.193.208.0/21",
    "126.193.216.0/22",
    "126.194.64.0/19",
    "126.194.96.0/20",
    "126.194.112.0/20",
    "126.194.192.0/19",
    "126.194.224.0/20",
    "126.194.240.0/20",
    "126.200.0.0/18",
    "126.200.96.0/19",
    "126.204.0.0/17",
    "126.204.128.0/18",
    "126.204.192.0/21",
    "126.204.200.0/21",
    "126.204.208.0/21",
    "126.204.216.0/21",
    "126.204.224.0/21",
    "126.204.232.0/21",
    "126.204.240.0/20",
    "126.208.128.0/17",
    "126.211.0.0/18",
    "126.211.186.0/25",
    "126.211.186.128/25",
    "126.211.96.0/19",
    "126.212.128.0/18",
    "126.212.224.0/19",
    "126.229.0.0/18",
    "126.229.64.0/19",
    "126.234.0.0/18",
    "126.234.96.0/19",
    "126.236.0.0/20",
    "126.236.16.0/20",
    "126.236.32.0/20",
    "126.236.48.0/20",
    "126.236.128.0/20",
    "126.236.144.0/20",
    "126.236.160.0/20",
    "126.236.176.0/20",
    "126.237.0.0/20",
    "126.237.16.0/23",
    "126.237.18.0/23",
    "126.237.20.0/23",
    "126.237.22.0/23",
    "126.237.24.0/23",
    "126.237.26.0/23",
    "126.237.28.0/23",
    "126.237.30.0/23",
    "126.237.32.0/20",
    "126.237.48.0/23",
    "126.237.50.0/23",
    "126.237.52.0/23",
    "126.237.54.0/23",
    "126.237.56.0/23",
    "126.237.58.0/23",
    "126.237.60.0/23",
    "126.237.62.0/23",
    "126.237.64.0/21",
    "126.237.80.0/21",
    "126.237.96.0/22",
    "126.237.104.0/22",
    "126.240.56.0/25",
    "126.240.56.128/25",
    "126.240.57.0/25",
    "126.240.57.128/25",
    "126.253.0.0/19",
    "126.253.32.0/19",
    "126.253.64.0/19",
    "126.253.96.0/19",
    "126.253.128.0/19",
    "126.253.160.0/19",
    "126.253.192.0/19",
    "126.253.224.0/19",
    "126.255.0.0/17",
    "126.255.128.0/18",
    "126.255.192.0/21",
    "126.255.200.0/21",
    "126.255.208.0/21",
    "126.255.216.0/21",
    "126.255.224.0/21",
    "126.255.232.0/21",
    "126.255.240.0/21",
    "126.255.248.0/21",
    "202.253.96.160/28",
    "202.253.99.160/28",
    "210.228.189.196/30",
  ]
  target_service_accounts = [
    google_service_account.service1_public_account.email,
  ]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  depends_on = [
    google_compute_network.host_sharedvpc,
    google_project_service.host_api_enable,
    google_service_account.service1_public_account,
    google_service_account.service1_private_account,
  ]
}
