
locals {
  probe_us_init = templatefile("scripts/probe.sh.tpl", {
    lb_vip = google_compute_global_address.tcp_lb_static_ipv4.address
  })
}

resource "google_compute_instance" "probe_us" {
  name                      = "probe-us"
  machine_type              = "n1-standard-2"
  zone                      = "us-central1-b"
  metadata_startup_script   = local.probe_us_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-9"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet3.self_link
    network_ip = "10.1.3.100"
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  depends_on = [google_compute_global_forwarding_rule.my_tcp_lb_ipv4_forwarding_rule]
}
