provider "google" {
  project = "k8s-worshop"
  region  = "europe-west1"
  version = "1.10"
}

resource "google_container_cluster" "workshop-cluster" {
  name = "workshop-cluster"
  zone = "europe-west1-c"
  initial_node_count = 1

  additional_zones = [
    "europe-west1-d"
  ]

  master_auth {
    username = "admin"
    password = "${var.cluster_password}"
  }

  node_config {
    machine_type = "n1-standard-2"
    disk_size_gb = "100"

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_write",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"
    ]
  }
}
