# GCE
resource "google_compute_instance" "service1_gce1" {
  name         = join("-", [var.service1_pj.service_name, "bastion-sv01"])
  machine_type = "e2-micro" #"f1-micro"
  zone         = var.gcp_common.zone
  project      = google_project.service1.name

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.service1-gce-subnets.id

    access_config {
      // Ephemeral IP
    }
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.service1_public_account.email
    scopes = ["cloud-platform"]
  }

  resource_policies = [
    google_compute_resource_policy.service1_gce1.id,
  ]

  metadata = {
    ssh-keys = "${var.gce_ssh.user}:${file(var.gce_ssh.pub_ssh_key_file)}"
  }
}

output "service1_gce1_global_ip" {
  value = google_compute_instance.service1_gce1.network_interface[0].access_config[0].nat_ip
}

# VM Restart Scheduler
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_resource_policy#example-usage---resource-policy-instance-schedule-policy

resource "google_compute_resource_policy" "service1_gce1" {
  name        = "midnightstop"
  region      = var.gcp_common.region
  project     = google_project.service1.name
  description = "Start and stop instances"
  instance_schedule_policy {
    vm_stop_schedule {
      schedule = "0 3 * * *" # AM 3:00 stop
    }
    vm_start_schedule {
      schedule = "0 7 * * *" # AM 7:00 start
    }
    time_zone = "Asia/Tokyo" # JST +9
  }
}
