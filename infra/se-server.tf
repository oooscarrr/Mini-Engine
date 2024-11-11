resource "null_resource" "build_push_se_server" {
  depends_on = [ google_container_node_pool.se_server_node_pool ]

  # Authenticate Docker
  provisioner "local-exec" {
    command = "gcloud auth configure-docker"
  }

  # Create a buildx builder
  provisioner "local-exec" {
    command = <<EOT
      docker buildx create --name mybuilder --use || docker buildx use mybuilder
      docker buildx inspect mybuilder --bootstrap
    EOT
  }

  # Build and push to Docker Hub and GCR
  provisioner "local-exec" {
    command = <<EOT
      docker buildx build --no-cache --platform linux/amd64,linux/arm64 -t gcr.io/${var.project_id}/${var.dockerhub_username}/se-server:latest --push ../se-server
    EOT
  }
}

resource "null_resource" "apply_se_server_k8s" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region=${google_container_cluster.primary.location}"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ./kubernetes-manifests/se-server-deployment.yaml"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ./kubernetes-manifests/service-se-server-lb.yaml"
  }

  provisioner "local-exec" {
    command = "kubectl rollout restart deployment se-server"
  }
  
  depends_on = [null_resource.build_push_se_server]
}
