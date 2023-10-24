terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.3.0" # Specify the desired version here
    }
  }
}

provider "google" {
  credentials = file("./rentyaar-91ccb59c2c51.json")
  project    = "rentyaar"
  region     = "us-central1"
}

resource "google_compute_network" "gcp-vpc" {
  name = "terraform-vpc"
}

resource "google_compute_subnetwork" "vpc-subnetwork" {
  name          = "terraform-subnet"
  network       = google_compute_network.gcp-vpc.name
  ip_cidr_range = "10.0.0.0/24" # Define your desired IP range
}


resource "google_compute_instance" "vm_debian" {
  name         = "terraform-vm"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  tags = ["gcloud", "vm-instance"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = google_compute_network.gcp-vpc.name
    subnetwork = google_compute_subnetwork.vpc-subnetwork.name
    access_config {}
  }
}

resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh"
  network = google_compute_network.gcp-vpc.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow-http" {
  name    = "allow-http"
  network = google_compute_network.gcp-vpc.name
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
}


output "public_ip" {
  value = google_compute_instance.vm_debian.network_interface.0.access_config.0.nat_ip
}
