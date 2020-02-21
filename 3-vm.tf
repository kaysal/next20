
# web servers
#------------------------------------

# us-east4

locals {
  web_us_init = templatefile("scripts/web.sh.tpl", {
    db_ip = "10.1.1.100:3306"
  })
}

resource "google_compute_instance" "web_us" {
  name                      = "web-us"
  machine_type              = "n1-standard-2"
  zone                      = "us-east4-b"
  metadata_startup_script   = local.web_us_init
  allow_stopping_for_update = true
  tags                      = ["allow-hc"]

  boot_disk {
    initialize_params {
      image = "debian-9"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet1.self_link
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# europe-west2

locals {
  web_eu_init = templatefile("scripts/web.sh.tpl", {
    db_ip = "10.1.2.100:3306"
  })
}

resource "google_compute_instance" "web_eu" {
  name                      = "web-eu"
  machine_type              = "n1-standard-2"
  zone                      = "europe-west2-b"
  metadata_startup_script   = local.web_eu_init
  allow_stopping_for_update = true
  tags                      = ["allow-hc"]

  boot_disk {
    initialize_params {
      image = "debian-9"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet2.self_link
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}


# db servers
#------------------------------------

# us-east4

locals {
  db_us_init = templatefile("scripts/db.sh.tpl", {
    remote_db_ip = "10.1.2.100:3306"
  })
}

resource "google_compute_instance" "db_us" {
  name                      = "db-us"
  machine_type              = "n1-standard-2"
  zone                      = "us-east4-c"
  metadata_startup_script   = local.db_us_init
  allow_stopping_for_update = true
  tags                      = ["db-tier"]

  boot_disk {
    initialize_params {
      image = "debian-9"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet1.self_link
    network_ip = "10.1.1.100"
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# europe-west2

locals {
  db_eu_init = templatefile("scripts/db.sh.tpl", {
    remote_db_ip = "10.1.1.100:3306"
  })
}

resource "google_compute_instance" "db_eu" {
  name                      = "db-eu"
  machine_type              = "n1-standard-2"
  zone                      = "europe-west2-c"
  metadata_startup_script   = local.db_eu_init
  allow_stopping_for_update = true
  tags                      = ["db-tier"]

  boot_disk {
    initialize_params {
      image = "debian-9"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet2.self_link
    network_ip = "10.1.2.100"
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
