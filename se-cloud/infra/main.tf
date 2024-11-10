resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection     = false

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  node_config {
    service_account = "oooscarrr@cmu14848-435323.iam.gserviceaccount.com"
  }
}

resource "google_container_node_pool" "main_node_pool" {
  name       = var.node_pool
  location   = var.region
  cluster    = google_container_cluster.primary.self_link
  node_count = 1

  node_config {
    preemptible  = false
    machine_type = var.machine_type
    disk_size_gb = 50
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }
}

resource "null_resource" "deploy_services" {
  depends_on = [ google_container_node_pool.main_node_pool ]
  
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region=${google_container_cluster.primary.location}"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/kubernetes-manifests/se-cloud-deployment.yaml"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/kubernetes-manifests/service-se-cloud-lb.yaml"
  }
}