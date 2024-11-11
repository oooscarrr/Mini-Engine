resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection     = false

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

resource "google_container_node_pool" "se_cloud_node_pool" {
  name       = "se-cloud-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.self_link
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = var.machine_type
    disk_size_gb = 50
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 5
  }

}

resource "google_container_node_pool" "se_server_node_pool" {
  name       = "se-server-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.self_link
  node_count = 1

  node_config {
    preemptible  = false
    machine_type = "e2-medium"
    disk_size_gb = 30
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }

  depends_on = [ google_container_node_pool.se_cloud_node_pool ]
}