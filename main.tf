provider "google" {
    project     = "test-project"
    region      = var.google_region
}

# Create a VPC network
resource "google_compute_network" "peering_network" {
  name = "peering-network"
}

# Create an IP address
resource "google_compute_global_address" "private_ip_alloc" {
  name          = "private-ip-alloc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.peering_network.id
}

# Create a private connection
resource "google_service_networking_connection" "default" {
  network                 = google_compute_network.peering_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
}

# Create a service account
resource "google_service_account" "default" {
  account_id   = "vm-service-account"
  display_name = "Custom SA for VM Instance"
}

# Create a vm
resource "google_compute_instance" "app_server" {
  name         = "my-instance"
  machine_type = "n2-standard-2"
  zone         = var.google_region

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "NVME"
  }

  network_interface {
    network = "default"
  }

  metadata = {
    foo = "bar"
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}

# Create Cloud storage
resource "google_storage_bucket" "files-storage" {
  name          = "${var.file_name_prefix}-files"
  location      = var.google_storage_region_name
  force_destroy = true
}