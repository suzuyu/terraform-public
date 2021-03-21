# googleapis
## https://cloud.google.com/vpc/docs/configure-private-google-access?hl=ja
resource "google_dns_managed_zone" "googleapis" {
  name        = "googleapis"
  project     = google_project.host_project.name
  dns_name    = "googleapis.com."
  description = "Private Access googleapis"

  visibility = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.host_sharedvpc.id
    }
  }
  depends_on = [
    google_project.host_project,
  ]
}


resource "google_dns_record_set" "googleapis_restricted_a" {
  name         = "restricted.googleapis.com."
  managed_zone = google_dns_managed_zone.googleapis.name
  type         = "A"
  ttl          = 300
  project      = google_project.host_project.name

  rrdatas = ["199.36.153.4", "199.36.153.5", "199.36.153.6", "199.36.153.7"]

  depends_on = [
    google_dns_managed_zone.googleapis,
  ]
}

resource "google_dns_record_set" "googleapis_private_a" {
  name         = "private.googleapis.com."
  managed_zone = google_dns_managed_zone.googleapis.name
  type         = "A"
  ttl          = 300
  project      = google_project.host_project.name

  rrdatas = ["199.36.153.8", "199.36.153.9", "199.36.153.10", "199.36.153.11"]

  depends_on = [
    google_dns_managed_zone.googleapis,
    google_dns_record_set.googleapis_restricted_a,
  ]
}

resource "google_dns_record_set" "googleapis_cname" {
  name         = "*.googleapis.com."
  managed_zone = google_dns_managed_zone.googleapis.name
  type         = "CNAME"
  ttl          = 300
  project      = google_project.host_project.name
  rrdatas      = ["restricted.googleapis.com."]
  depends_on = [
    google_dns_managed_zone.googleapis,
    google_dns_record_set.googleapis_private_a,
  ]
}

# cloudbilling へのサクセスがプライベートで作業時に必要なため追加
resource "google_dns_record_set" "googleapis_cname2" {
  name         = "cloudbilling.googleapis.com."
  managed_zone = google_dns_managed_zone.googleapis.name
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["private.googleapis.com."]
  project      = google_project.host_project.name
  depends_on = [
    google_dns_managed_zone.googleapis,
    google_dns_record_set.googleapis_cname,
  ]
}

resource "google_dns_policy" "googleapis_apipolicy" {
  name                      = "apipolicy"
  enable_inbound_forwarding = true
  project                   = google_project.host_project.name

  enable_logging = false

  networks {
    network_url = google_compute_network.host_sharedvpc.id
  }
  depends_on = [
    google_dns_managed_zone.googleapis,
    google_dns_record_set.googleapis_cname2,
  ]
}

# gcr.io
## https://cloud.google.com/vpc/docs/configure-private-google-access?hl=ja#config-domain
resource "google_dns_managed_zone" "gcrio" {
  name        = "gcrio"
  project     = google_project.host_project.name
  dns_name    = "gcr.io."
  description = "Private Google Cloud Registry"

  visibility = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.host_sharedvpc.id
    }
  }
  depends_on = [
    google_project.host_project,
  ]
}

resource "google_dns_record_set" "gcrio_private_a" {
  name         = "gcr.io."
  managed_zone = google_dns_managed_zone.gcrio.name
  type         = "A"
  ttl          = 300
  project      = google_project.host_project.name

  rrdatas = ["199.36.153.8", "199.36.153.9", "199.36.153.10", "199.36.153.11"]

  depends_on = [
    google_dns_managed_zone.gcrio,
  ]
}

resource "google_dns_record_set" "gcrio_cname" {
  name         = "*.gcr.io."
  managed_zone = google_dns_managed_zone.gcrio.name
  type         = "CNAME"
  ttl          = 300
  project      = google_project.host_project.name
  rrdatas      = ["gcr.io."]
  depends_on = [
    google_dns_managed_zone.gcrio,
    google_dns_record_set.gcrio_private_a,
  ]
}
