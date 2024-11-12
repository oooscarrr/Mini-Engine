provider "google" {
  project = var.project_id
  region = var.region
  zone = var.zone
  credentials = var.credentials_json
}

provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = "gke_${var.project_id}_${var.region}_${var.cluster_name}"
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command = "gke-gcloud-auth-plugin"
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    config_context = "gke_${var.project_id}_${var.region}_${var.cluster_name}"
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command = "gke-gcloud-auth-plugin"
    }
  }
}