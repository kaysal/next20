
# vpc network

resource "google_compute_network" "vpc" {
  name                    = "vpc"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# vpc subnets

resource "google_compute_subnetwork" "subnet1" {
  name          = "subnet1"
  ip_cidr_range = "10.1.1.0/24"
  region        = "us-east4"
  network       = google_compute_network.vpc.self_link
}

resource "google_compute_subnetwork" "subnet2" {
  name          = "subnet2"
  ip_cidr_range = "10.1.2.0/24"
  region        = "europe-west2"
  network       = google_compute_network.vpc.self_link
}

resource "google_compute_subnetwork" "subnet3" {
  name          = "subnet3"
  ip_cidr_range = "10.1.3.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc.self_link
}

# vpc firewall rules

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_rfc1918" {
  name    = "allow-rfc1918"
  network = google_compute_network.vpc.self_link

  allow {
    protocol = "all"
  }

  source_ranges = ["10.0.0.0/8", ]
}

resource "google_compute_firewall" "allow_health_checks" {
  name    = "allow-health-checks"
  network = google_compute_network.vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["110"]
  }

  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]

  target_tags = ["allow-hc"]
}

resource "google_compute_firewall" "deny_tcp" {
  name     = "deny-tcp"
  network  = google_compute_network.vpc.self_link
  priority = "1000"

  deny {
    protocol = "all"
  }

  source_ranges = ["10.1.1.0/24", ]
  target_tags   = ["db-tier"]
}
