
# us-east 4

resource "google_compute_router" "router_us" {
  name    = "router-us"
  region  = "us-east4"
  network = google_compute_network.vpc.self_link

  bgp {
    asn = "65310"
  }
}

resource "google_compute_router_nat" "nat_us" {
  name                               = "nat-us"
  router                             = google_compute_router.router_us.name
  region                             = "us-east4"
  nat_ip_allocate_option             = "AUTO_ONLY"
  min_ports_per_vm                   = "28672"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}


# europe-west2

resource "google_compute_router" "router_eu" {
  name    = "router-eu"
  region  = "europe-west2"
  network = google_compute_network.vpc.self_link

  bgp {
    asn = "65320"
  }
}

resource "google_compute_router_nat" "nat_eu" {
  name                               = "nat-eu"
  router                             = google_compute_router.router_eu.name
  region                             = "europe-west2"
  nat_ip_allocate_option             = "AUTO_ONLY"
  min_ports_per_vm                   = "28672"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
