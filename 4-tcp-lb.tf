
# unmanaged instance groups

resource "google_compute_instance_group" "ig_us" {
  name      = "ig-us"
  zone      = "us-east4-b"
  instances = [google_compute_instance.web_us.self_link]

  named_port {
    name = "tcp110"
    port = "110"
  }
}

resource "google_compute_instance_group" "ig_eu" {
  name      = "ig-eu"
  zone      = "europe-west2-b"
  instances = [google_compute_instance.web_eu.self_link]

  named_port {
    name = "tcp110"
    port = "110"
  }
}

# http health check

resource "google_compute_health_check" "my_tcp_health_check" {
  name = "my-tcp-health-check"

  http_health_check {
    port = "110"
  }

  check_interval_sec  = "10"
  timeout_sec         = "10"
  healthy_threshold   = "3"
  unhealthy_threshold = "2"
}

# instance groups

resource "google_compute_backend_service" "my_tcp_lb" {
  provider  = google-beta
  name      = "my-tcp-lb"
  port_name = "tcp110"
  protocol  = "TCP"

  backend {
    group           = google_compute_instance_group.ig_us.self_link
    balancing_mode  = "UTILIZATION"
    max_utilization = "0.8"
    capacity_scaler = "1"
  }

  backend {
    group           = google_compute_instance_group.ig_eu.self_link
    balancing_mode  = "UTILIZATION"
    max_utilization = "0.8"
    capacity_scaler = "1"
  }


  health_checks = [google_compute_health_check.my_tcp_health_check.self_link]
}

# tcp proxy frontend

resource "google_compute_target_tcp_proxy" "my_tcp_lb_target_proxy" {
  name            = "my-tcp-lb-target-proxy"
  backend_service = google_compute_backend_service.my_tcp_lb.self_link
}

# load balancer vip

resource "google_compute_global_address" "tcp_lb_static_ipv4" {
  name        = "tcp-lb-static-ipv4"
  description = "static ipv4 address for tcp proxy"
}


# forwarding rule

resource "google_compute_global_forwarding_rule" "my_tcp_lb_ipv4_forwarding_rule" {
  name        = "my-tcp-lb-ipv4-forwarding-rule"
  target      = google_compute_target_tcp_proxy.my_tcp_lb_target_proxy.self_link
  ip_address  = google_compute_global_address.tcp_lb_static_ipv4.address
  ip_protocol = "TCP"
  port_range  = "110"
}
